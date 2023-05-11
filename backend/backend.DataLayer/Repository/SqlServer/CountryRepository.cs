using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;

namespace backend.DataLayer.Repository.SqlServer
{
    public class CountryRepository : Repository, ICountryRepository
    {
        public CountryRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public CountryRepository()
        {
        }

        public virtual async Task<IEnumerable<Country>> GetAllCountries(int configurationId)
        {
            IEnumerable<Country> countries;

            var command = CreateCommand("dbo.SP_Country_GetAll");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);

            using (var reader = await command.ExecuteReaderAsync())
            {
                countries = await DatabaseMapper.Instance.FromReaderAsync<Country>(reader);
            }

            return countries;
        }

        public virtual async Task<CountryInfo> GetCountryInfo(int configurationId, int countryId)
        {
            CountryInfo countryInfo = new CountryInfo();
            var names = new List<CountryNameInfo>();

            var command = CreateCommand("dbo.SP_Country_GetDetails");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@countryId", countryId);
            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    countryInfo.CountryID = reader.GetInt32(0);
                    countryInfo.Description = reader.GetString(1);
                    countryInfo.RegionID = reader.GetInt32(2);

                    CountryNameInfo name = new CountryNameInfo();
                    name.CountrySpellingID = reader.GetInt32(3);
                    name.LanguageID = reader.GetInt32(4);
                    name.Language = reader.GetString(5).ToLower();
                    name.CountryName = reader.GetString(6);
                    names.Add(name);
                }
                countryInfo.names = names;
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return countryInfo;
        }

        public virtual async Task<IEnumerable<Language>> GetSelectedLanguages(int configurationId)
        {
            IEnumerable<Language> languages;
            var command = CreateCommand("cust.SP_Global_GetSelectedLanguages");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                languages = await DatabaseMapper.Instance.FromReaderAsync<Language>(reader);
            }
            return languages;
        }

        public virtual async Task<int> UpdateCountry(int configurationId, int countryId, string description, int regionId)
        {
            var command = CreateCommand("[dbo].[SP_Country_UpdateDetails]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@countryId", countryId);
            command.Parameters.AddWithValue("@description", description);
            command.Parameters.AddWithValue("@regionId", regionId);
            int result = await command.ExecuteNonQueryAsync();
            return result > 0 ? 1 : 0;
        }

        public virtual async Task<int> UpdateCountrySpelling(int configurationId, int spellingId, int languageId, string countryName)
        {
            var command = CreateCommand("[dbo].[SP_Country_UpdateCountrySpelling]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@spellingId", spellingId);
            command.Parameters.AddWithValue("@languageId", languageId);
            command.Parameters.AddWithValue("@countryName", countryName);

            int result = await command.ExecuteNonQueryAsync();
            return result > 0 ? 1 : 0;
        }


        public virtual async Task<int> AddCountry(int configurationId, string description, int regionId)
        {
            try {
                var command = CreateCommand("[dbo].[SP_Country_Add]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@description", description);
                command.Parameters.AddWithValue("@regionId", regionId);


                int result = -1;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        result = reader.GetInt32(0);
                    }
                }
                return result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
       

        public virtual async Task<int> AddCountryDetails(int configurationId, int countryId, int languageId, string countryName)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_Country_AddCountryDetails]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@countryId", countryId);
                command.Parameters.AddWithValue("@languageId", languageId);
                command.Parameters.AddWithValue("@countryName",Convert.ToString(countryName));
                int result = -1;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        result = reader.GetInt32(0);
                    }
                }
                return result;
            }
            
            catch(Exception ex)
            {
                throw ex;
            }
        }

    }
}
