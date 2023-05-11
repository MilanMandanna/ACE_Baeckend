using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;

namespace backend.DataLayer.Repository.SqlServer
{
    public class GlobalConfigurationRepository : Repository, IGlobalConfigurationRepository
    {
      
        public GlobalConfigurationRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }
        public GlobalConfigurationRepository() { }

        public virtual async Task<IEnumerable<FontFile>> GetFonts(int configurationId)
        {                    

            var command = CreateCommand("[dbo].[SP_GetFonts]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                return await DatabaseMapper.Instance.FromReaderAsync<FontFile>(reader);
            }
        }

        public virtual async Task<IEnumerable<Language>> GetAllLanguages()
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_global_GetAllLanguages]");
                command.CommandType = CommandType.StoredProcedure;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    return await DatabaseMapper.Instance.FromReaderAsync<Language>(reader);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<IEnumerable<SelectedLanguage>> GetSelectedLanguages(int configurationId)
        {
            var languageList = new List<SelectedLanguage>();
            IEnumerable<Language> languages;
            try
            {
                var command = CreateCommand("cust.SP_Global_GetSelectedLanguages");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                using (var reader = await command.ExecuteReaderAsync())
                {
                    languages = await DatabaseMapper.Instance.FromReaderAsync<Language>(reader);
                }
                foreach (var language in languages)
                {
                    var prefix = "global/" + language.TwoLetterID_ASXi.ToLower();
                    command = CreateCommand("[dbo].[SP_global_GetSelectLanguage]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@name", 'E' + language.Name.ToUpper());
                    command.Parameters.AddWithValue("@configurationId", configurationId);
                    command.Parameters.AddWithValue("@langprefix", prefix);


                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        var selectedLanguage = new SelectedLanguage();
                        while (await reader.ReadAsync())
                        {
                            selectedLanguage.IsDefault = DbHelper.BoolFromDb(Convert.ToBoolean(reader.GetInt32(0)));
                            selectedLanguage.Clock = DbHelper.DBValueToString(reader.GetString(1));
                            selectedLanguage.Decimal = DbHelper.DBValueToString(reader.GetString(2));
                            selectedLanguage.Grouping = DbHelper.DBValueToString(reader.GetString(3));
                            selectedLanguage.InteractiveClock = DbHelper.DBValueToString(reader.GetString(4));
                            selectedLanguage.InteractiveUnits = DbHelper.DBValueToString(reader.GetString(5));
                            selectedLanguage.Units = DbHelper.DBValueToString(reader.GetString(6));
                            selectedLanguage.TwoLetterLanguageCode = language.TwoLetterID_ASXi;
                            selectedLanguage.Name = language.Name;
                        }

                        languageList.Add(selectedLanguage);
                    }
                }
                return languageList;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> AddLanguages(int configurationId, List<string> twoLetterLanguageCodes)
        {

            var languageSetAddResult = 0;
            var languageElementAddResult = 0;
            try
            {
                var existingLanguageSet = "";
                var command = CreateCommand("[dbo].[SP_global_AddLanguages]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        existingLanguageSet = DbHelper.DBValueToString(reader.GetString(0));
                    }
                }
               

                foreach (var languageCode in twoLetterLanguageCodes)
                {
                    command = CreateCommand("[dbo].[SP_global_AddLanguagesCode]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@languageCode", languageCode);
                    command.Parameters.AddWithValue("@configurationId", configurationId);

                    var language = "";
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            language = DbHelper.DBValueToString(reader["languages"]);
                        }
                    }
                    if (!string.IsNullOrWhiteSpace(language))
                    {
                        language = 'e' + language.Substring(0, 1).ToUpper() + language.Substring(1, language.Length - 1);
                        var languageSetToUpdate = existingLanguageSet + "," + language;
                        command = CreateCommand("[dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]");
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@configurationId", configurationId);
                        command.Parameters.AddWithValue("@languageSetToUpdate",languageSetToUpdate.TrimStart(','));

                        languageSetAddResult = command.ExecuteNonQuery();

                        command = CreateCommand("[dbo].[SP_global_UpdateLanguageSetElements]");
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@configurationId", configurationId);
                        command.Parameters.AddWithValue("@languageCode", languageCode.ToLower());

                        languageElementAddResult = command.ExecuteNonQuery();
                        existingLanguageSet = languageSetToUpdate;
                    }
                    else
                    {
                        return 0;

                    }

                }
                return languageSetAddResult > 0 && languageElementAddResult > 0 ? 1 : 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> RemoveLanguage(int configurationId, string twoLetterLanguageCode)
        {
            var languageSetRemoveResult = 0;
            var languageElementRemoveResult = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_global_AddLanguages]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                var existingLanguageSet = "";
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        existingLanguageSet = reader.GetString(0);
                    }
                }
                command = CreateCommand("[dbo].[SP_global_AddLanguagesCode]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@languageCode", twoLetterLanguageCode);
                command.Parameters.AddWithValue("@configurationId", configurationId);

                var language = "";
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        language = DbHelper.DBValueToString(reader.GetString(0));
                    }
                }
                if (!string.IsNullOrWhiteSpace(language))
                {

                    language = 'e' + language.Substring(0, 1).ToUpper() + language.Substring(1, language.Length - 1);
                    List<String> Items = existingLanguageSet.Split(",").Select(i => i.Trim()).Where(i => i != string.Empty).ToList();
                    if (Items.Contains(language))
                    {
                        Items.Remove(language);
                        string languageSetToUpdate = String.Join(", ", Items.ToArray());
                        command = CreateCommand("[dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]");
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@configurationId", configurationId);
                        command.Parameters.AddWithValue("@languageSetToUpdate", languageSetToUpdate);

                        languageSetRemoveResult = command.ExecuteNonQuery();

                        command = CreateCommand("[dbo].[SP_GlobalRemoveLanguage]");
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@configurationId", configurationId);
                        command.Parameters.AddWithValue("@languageCode", language);
                        languageElementRemoveResult = command.ExecuteNonQuery();
                        return languageSetRemoveResult > 0 && languageElementRemoveResult > 0 ? 1 : 0;
                    }
                    return 0;
                }

                return 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> MoveLanguageCodeToPosition(int configurationId, string languageCode, int position)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_global_AddLanguages]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                var existingLanguageSet = "";
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        existingLanguageSet = DbHelper.DBValueToString(reader.GetString(0));
                    }
                }
                command = CreateCommand("[dbo].[SP_global_AddLanguagesCode]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@languageCode", languageCode);
                command.Parameters.AddWithValue("@configurationId", configurationId);

                var language = "";
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        language = DbHelper.DBValueToString(reader.GetString(0));
                    }
                }
                if (!string.IsNullOrWhiteSpace(language) && position >= 0)
                {
                    language = 'e' + language.Substring(0, 1).ToUpper() + language.Substring(1, language.Length - 1);
                    List<String> Items = existingLanguageSet.Split(",").Select(i => i.Trim()).Where(i => i != string.Empty).ToList();
                    if (Items.Contains(language))
                    {
                        var index = Items.IndexOf(language);
                        Items.RemoveAt(index);
                        Items.Insert(position, language);
                        string languageSetToUpdate = String.Join(", ", Items.ToArray());
                        command = CreateCommand("[dbo].[SP_global_AddLanguagesCodeIsnullOrWhiteSpace]");
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@configurationId", configurationId);
                        command.Parameters.AddWithValue("@languageSetToUpdate", languageSetToUpdate);
                        return command.ExecuteNonQuery();

                    }
                    return 0;
                }
                return 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }

        }

        public virtual async Task<int> UpdateLanguagesSetting(int configurationId, string languageCode, string name, string value)
        {
            var result = 0;
            try
            {
                if (languageCode == "global")
                {
                    IEnumerable<Language> languages;

                    var command = CreateCommand("[dbo].[SP_global_UpdateLanguage]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@configurationId", configurationId);
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        languages = await DatabaseMapper.Instance.FromReaderAsync<Language>(reader);
                    }
                    foreach (var language in languages)
                    {
                        var prefix = "global/" + language.TwoLetterID_ASXi.ToLower();
                        command = CreateCommand("[dbo].[SP_global_UpdateLanguageSetElementsAttributes]");
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@configurationId", configurationId);
                        command.Parameters.AddWithValue("@languagePrefix", prefix);
                        command.Parameters.AddWithValue("@name", name);
                        command.Parameters.AddWithValue("@value", value);
                        result = await command.ExecuteNonQueryAsync();
                        if (result < 0)
                        {
                            return 0;
                        }
                    }

                    return 1;
                }
                else
                {
                    var prefix = "global/" + languageCode.ToLower();
                    var command = CreateCommand("[dbo].[SP_global_UpdateLanguageSetElementsAttributes]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@configurationId", configurationId);
                    command.Parameters.AddWithValue("@languagePrefix", prefix);
                    command.Parameters.AddWithValue("@name", name);
                    command.Parameters.AddWithValue("@value", value);
                    result = await command.ExecuteNonQueryAsync();
                    return result;
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }

        }

        public virtual async Task<int> SetLanguageAsDefault(int configurationId, string languageCode)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_global_AddLanguagesCode]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@languageCode", languageCode);
                command.Parameters.AddWithValue("@configurationId", configurationId);

                var language = "";
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        language = reader.GetString(0);
                    }
                }
                if (!string.IsNullOrWhiteSpace(language))
                {
                    language = 'e' + language.Substring(0, 1).ToUpper() + language.Substring(1, language.Length - 1);

                    command = CreateCommand("[dbo].[SP_global_SetDefaultLanguage]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@configurationId", configurationId);
                    command.Parameters.AddWithValue("@language", language);
                    var result = await command.ExecuteNonQueryAsync();
                    return result;
                }
                return 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
            }
       

    }
}
