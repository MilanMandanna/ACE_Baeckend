using backend.Worker.Data;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Repository.Extensions;
using System.Linq;
using backend.DataLayer.Models.Configuration;
using System.IO;
using System.Xml.Linq;
using backend.DataLayer.Helpers.Database;
using System.Data.SqlClient;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.ASXInfo;
using backend.Worker.Helper;
using backend.DataLayer.Helpers;
using System.Diagnostics;
using Microsoft.Azure.WebJobs;
using backend.Mappers.DataTransferObjects.ASXSwg;
using System.Text;
using System.Xml;

namespace backend.Worker.Tasks
{
    public class TaskDevelopmentExport
    {
        // storage for the list of languages being exported, determined when the custom.xml file is generated
        private List<Language> exportLanguages;

        /**
         * Helper function to generate a query to read all the contents of a table associated with a given configurationid
         */
        private async Task<SqlDataReader> GetMappedReader<T>(IUnitOfWorkAdapter context, int configurationId)
        {
            var sql = DatabaseMapper.Instance.GenerateMappedStoredProcedure(typeof(T));
            var command = context.Repositories.AircraftRepository.CreateCommand(sql);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        /**
         * Extracts the languages a configuration is set to use based on the language xml data embedded in the custom.xml file.
         * Will then query the database and retrieve all the language information that will later be used
         * for exporting additional data
         */
        public async Task<List<Language>> ExtractLanguages(IUnitOfWorkAdapter uow, string languageXml, int configurationId)
        {
            XDocument tree = XDocument.Parse(languageXml);

            string[] allLanguages = tree.Root.Element("language_set").Value.Split(",");
            var dbLanguages = await uow.Repositories.Simple<Language>().FilterMappedAsync(configurationId);

            List<Language> result = new List<Language>();
            for (int i = 0; i < allLanguages.Length; ++i)
            {
                var expectedName = allLanguages[i].Trim().ToUpper().Substring(1);
                var record = dbLanguages.Where(x => x.Name == expectedName).FirstOrDefault();
                if (record == null) continue;
                result.Add(record);
            }

            return result;
        }

        /**
         * Helper function for converting ints from the database
         */
        private int IntHelper(object value)
        {
            if (value is System.DBNull) return 0;
            return int.Parse(value.ToString());
        }

        /**
         * Generates the asxinfo.sqlite3 file in the output folder
         */
        public async Task<int> GenerateASXInfoDatabase(TaskEnvironment environment, int configurationId)
        {
            /* check for the necessary inputs needed to build the database */
            var tempSqlPath = environment.GetTempPath("asxinfo.sqlite3.sql");
            var assetCreateSchemaPath = environment.GetLocalAssetPath("data/asxinfo/asxinfo.sqlite3.schema.sql");
            var languageSchemaPath = environment.GetLocalAssetPath("data/asxinfo/asxinfo.sqlite3.languageschema.sql");
            int returnValue = 0;
            string copyFilePath = environment.GetOutputPath() + @"\TempSqlPath";



            if (!File.Exists(assetCreateSchemaPath))
            {
                environment.Logger.LogError("missing database schema file");
                return -1;
            }

            if (!File.Exists(languageSchemaPath))
            {
                environment.Logger.LogError("missing language schema file");
                return -1;
            }

            await environment.UpdateDetailedStatus("building ASXIInfo database schema");

            /* copy the database schema to the final location */
            environment.CopyFile(assetCreateSchemaPath, tempSqlPath);

            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
            var repos = context.Repositories;
            var sqlOut = environment.OpenWriter(tempSqlPath, true, System.Text.Encoding.UTF8);
            int count = 0;

            /* get the language column schema */
            var languageSchema = File.ReadAllText(languageSchemaPath);

            /* add the language columns to those tables that need it, we will only add the languages as specified in the configuration */
            var tables = new string[] { "tbgeorefid", "tbregion", "tbinfospelling", "tbcountry" };
            var global = await repos.Simple<ConfigGlobal>().FirstMappedAsync(configurationId);
            exportLanguages = await ExtractLanguages(context, global.Global, configurationId);

            if (exportLanguages.Count == 0)
            {
                environment.Logger.LogError("Languages are missing");
                return -1;
            }
            for (int i = 0; i < tables.Length; ++i)
            {
                foreach (var language in exportLanguages)
                {
                    sqlOut.WriteLine($"ALTER TABLE {tables[i]} ADD COLUMN Lang_{language.TwoLetterID_ASXi.ToUpper()} {languageSchema};");
                }
            }

            var batch = new SqlOutputBatch(sqlOut);

            /**
             * tbairportinfo
             **/

            await environment.UpdateDetailedStatus("Started generating tbairportinfo");
            var reader = await GetMappedReader<AirportInfo>(context, configurationId);
            AirportInfo airportInfo = new AirportInfo();
            ASXInfoAirportInfo asxAirport = new ASXInfoAirportInfo();
            batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxAirport)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxAirport)})");

            while (await reader.ReadAsync())
            {
                DatabaseMapper.Instance.FromReader(reader, airportInfo);
                environment.Mapper.Map<AirportInfo, ASXInfoAirportInfo>(airportInfo, asxAirport);
                var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxAirport);
                batch.WriteBatchedInsert(rawSql);
                count++;
            }

            batch.EndBatchInsert();
            await reader.CloseAsync();

            /**
             * tbcountry
             **/
            await environment.UpdateDetailedStatus("Started generating tbcountry");
            var countries = await context.Repositories.Simple<Country>().FilterMappedAsync(configurationId);
            var countrySpellingRepository = context.Repositories.CountrySpellings;
            var columnNames = exportLanguages.Select(x => $"Lang_{x.TwoLetterID_ASXi.ToUpper()}").ToList();
            var twoLetterCodes = exportLanguages.Select(x => x.TwoLetterID_ASXi.ToUpper()).ToList();
            var columnSql = string.Join(", ", columnNames);
            var asxCountry = new ASXInfoCountry();
            var countrySqlPart1 = $"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxCountry)} (CountryId, {columnSql}) ";

            if (exportLanguages.Count > 0)
            {
                reader = await countrySpellingRepository.GetAllCountrySpellings(configurationId, exportLanguages);


                batch.BeginBatchInsert(countrySqlPart1);
                while (await reader.ReadAsync())
                {
                    string valuesSql = reader["CountryID"].ToString() + ", " + string.Join(", ", twoLetterCodes.Select(x => "\"" + reader[x] + "\""));
                    batch.WriteBatchedInsert(valuesSql);
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();
            }

            /**
             * tbfont
             **/
            await environment.UpdateDetailedStatus("Started generating tblfont");
            reader = await GetMappedReader<Font>(context, configurationId);
            Font font = new Font();
            ASXInfoFont asxFont = new ASXInfoFont();
            batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxFont)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxFont)})");

            while (await reader.ReadAsync())
            {
                DatabaseMapper.Instance.FromReader(reader, font);
                environment.Mapper.Map<Font, ASXInfoFont>(font, asxFont);
                var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxFont);
                batch.WriteBatchedInsert(rawSql);
            }
            batch.EndBatchInsert();
            reader.Close();

            /**
             * tbfontcategory
             **/
            await environment.UpdateDetailedStatus("Started generating tbfontcategory");
            reader = await GetMappedReader<FontCategory>(context, configurationId);
            FontCategory fontCategory = new FontCategory();
            ASXInfoFontCategory asxFontCategory = new ASXInfoFontCategory();
            batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxFontCategory)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxFontCategory)})");
            while (await reader.ReadAsync())
            {
                DatabaseMapper.Instance.FromReader(reader, fontCategory);
                environment.Mapper.Map<FontCategory, ASXInfoFontCategory>(fontCategory, asxFontCategory);
                var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxFontCategory);
                batch.WriteBatchedInsert(rawSql);
            }
            batch.EndBatchInsert();
            await reader.CloseAsync();

            /**
             * tbfontfamily
             **/
            await environment.UpdateDetailedStatus("Started generating tbfontfamily");
            reader = await GetMappedReader<FontFamily>(context, configurationId);
            FontFamily fontFamily = new FontFamily();
            ASXInfoFontFamily asxFontFamily = new ASXInfoFontFamily();
            batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxFontFamily)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxFontFamily)})");
            while (await reader.ReadAsync())
            {
                DatabaseMapper.Instance.FromReader(reader, fontFamily);
                environment.Mapper.Map<FontFamily, ASXInfoFontFamily>(fontFamily, asxFontFamily);
                var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxFontFamily);
                batch.WriteBatchedInsert(rawSql);
            }
            batch.EndBatchInsert();
            await reader.CloseAsync();

            /**
             * tbfontmarker
             */
            await environment.UpdateDetailedStatus("Started generating tbfontmarker");
            reader = await GetMappedReader<FontMarker>(context, configurationId);
            FontMarker fontMarker = new FontMarker();
            ASXInfoFontMarker asxFontMarker = new ASXInfoFontMarker();
            batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxFontMarker)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxFontMarker)})");
            while (await reader.ReadAsync())
            {
                DatabaseMapper.Instance.FromReader(reader, fontMarker);
                environment.Mapper.Map<FontMarker, ASXInfoFontMarker>(fontMarker, asxFontMarker);
                var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxFontMarker);
                batch.WriteBatchedInsert(rawSql);
            }
            batch.EndBatchInsert();
            await reader.CloseAsync();

            /**
             * tbgeorefid
             **/
            await environment.UpdateDetailedStatus("Started generating tbgeorefid");
            if (exportLanguages.Count > 0)
            {
                reader = await context.Repositories.GeoRefs.GetExportASXInfoGeoRefSpellings(configurationId, exportLanguages);
                var asxGeoRef = new ASXInfoGeoRefId();
                var geoRef = new GeoRef();
                var baseSql = DatabaseMapper.Instance.GenerateInsertColumns(asxGeoRef);
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxGeoRef)} ({baseSql}, {columnSql})");
                while (await reader.ReadAsync())
                {
                    DatabaseMapper.Instance.FromReader(reader, geoRef);
                    environment.Mapper.Map<GeoRef, ASXInfoGeoRefId>(geoRef, asxGeoRef);
                    object value = DbHelper.IntFromDb(reader["population"]);
                    asxGeoRef.Population = (int)(value == null ? 0 : value);
                    value = DbHelper.IntFromDb(reader["elevation"]);
                    asxGeoRef.Elevation = (int)(value == null ? 0 : value);
                    string georefValuesSql = DatabaseMapper.Instance.GenerateInsertValues(asxGeoRef);
                    string spellingsValuesSql = String.Join(", ", twoLetterCodes.Select(x => DatabaseMapper.Instance.FormatSqlString(reader[x].ToString())));
                    batch.WriteBatchedInsert($"{georefValuesSql}, {spellingsValuesSql}");
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();
            }

            /**
             * inclusion
             * This is done as a seperate process, we probably could do it during georef processing above by combining two pivot queries
             * but that is probably more complicated than what is needed, we'll just do the inclusions as a seperate
             * block of update statements
             */
            reader = await context.Repositories.GeoRefs.GetExportASXInfoAppearance(configurationId);
            while (await reader.ReadAsync())
            {
                int inclusion = 0;
                inclusion |= (((IntHelper(reader["15360"])) == 0) ? 0x1 : 0x0);
                inclusion |= (((IntHelper(reader["7680"])) == 0) ? 0x2 : 0x0);
                inclusion |= (((IntHelper(reader["3840"])) == 0) ? 0x4 : 0x0);
                inclusion |= (((IntHelper(reader["1920"])) == 0) ? 0x8 : 0x0);
                inclusion |= (((IntHelper(reader["960"])) == 0) ? 0x10 : 0x0);
                inclusion |= (((IntHelper(reader["480"])) == 0) ? 0x20 : 0x0);
                inclusion |= (((IntHelper(reader["240"])) == 0) ? 0x40 : 0x0);
                inclusion |= (((IntHelper(reader["120"])) == 0) ? 0x60 : 0x0);
                inclusion |= (((IntHelper(reader["60"])) == 0) ? 0x80 : 0x0);
                inclusion |= (((IntHelper(reader["30"])) == 0) ? 0x100 : 0x0);
                // not sure why the swops tool exports a "15" setting for the inclusion field and not the others
                // (likely a mistake in the swops tool) present here for compatibility
                inclusion |= (((IntHelper(reader["15"])) == 0) ? 0x200 : 0x0);

                sqlOut.WriteLine($"UPDATE tbgeorefid SET Inclusion = {inclusion} WHERE GeoRefID = {reader["georefid"]};");
            }
            await reader.CloseAsync();

            /**
             * latitude and longitude
             */
            await environment.UpdateDetailedStatus("Started generating Latitude and longitude");
            reader = await context.Repositories.GeoRefs.GetExportASXInfoLatLon(configurationId);
            while (await reader.ReadAsync())
            {
                int geoRefId = int.Parse(reader["georefid"].ToString());
                float lat = float.Parse(reader["lat"].ToString());
                float lon = float.Parse(reader["lon"].ToString());
                sqlOut.WriteLine($"UPDATE tbgeorefid SET Lat = {lat}, Lon = {lon} WHERE georefid = {geoRefId};");
            }
            await reader.CloseAsync();

            /**
             * tbgeorefidcategorytype
             **/
            await environment.UpdateDetailedStatus("Started generating tbgeorefidcategorytype");
            var categories = await context.Repositories.Simple<GeoRefCategoryType>().FindAllAsync();
            ASXInfoGeoRefIdCateType asxCategory = new ASXInfoGeoRefIdCateType();
            batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxCategory)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxCategory)})");
            foreach (var category in categories)
            {
                environment.Mapper.Map<GeoRefCategoryType, ASXInfoGeoRefIdCateType>(category, asxCategory);
                var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxCategory);
                batch.WriteBatchedInsert(rawSql);
            }
            batch.EndBatchInsert();

            /**
             * tbinfospelling
             **/
            await environment.UpdateDetailedStatus("Started generating tbinfospelling");
            if (exportLanguages.Count > 0)
            {
                var asxInfoSpelling = new ASXInfoInfoSpelling();
                reader = await context.Repositories.InfoSpellings.GetExportSpellingsForConfig(configurationId, exportLanguages);
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxInfoSpelling)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxInfoSpelling)}, {columnSql})");
                while (await reader.ReadAsync())
                {
                    string valuesSql = reader["infoid"].ToString();
                    string spellingsSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{valuesSql}, {spellingsSql}");
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();
            }
            /**
             * tblanguage
             **/
            await environment.UpdateDetailedStatus("Started generating tblanguage");
            ASXInfoLanguage asxLanguage = new ASXInfoLanguage();
            batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxLanguage)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxLanguage)})");
            foreach (var language in exportLanguages)
            {
                environment.Mapper.Map<Language, ASXInfoLanguage>(language, asxLanguage);
                var sql = DatabaseMapper.Instance.GenerateInsertValues(asxLanguage);
                batch.WriteBatchedInsert(sql);
            }
            batch.EndBatchInsert();

            /**
             * tbregion
             **/
            await environment.UpdateDetailedStatus("Started generating tbregion");
            if (exportLanguages.Count > 0)
            {
                var asxRegion = new ASXInfoRegion();
                reader = await context.Repositories.RegionSpellings.GetExportASXInfoRegionSpellings(configurationId, exportLanguages);
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxRegion)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxRegion)}, {columnSql})");
                while (await reader.ReadAsync())
                {
                    string valuesSql = reader["regionid"].ToString();
                    string spellingsValuesSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{valuesSql}, {spellingsValuesSql}");
                }
                batch.EndBatchInsert();
                reader.Close();
            }

            /**
             * tbtzstrip
             **/
            await environment.UpdateDetailedStatus("Started generating tbtzstrip");
            reader = await context.Repositories.GeoRefs.GetExportASXInfoTimezoneStrips(configurationId);
            var asxTZStrip = new ASXInfoTZStrip();
            batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxTZStrip)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxTZStrip)})");
            while (await reader.ReadAsync())
            {
                string sql = $"{reader["georefid"].ToString()}, {reader["tzstripid"].ToString()}";
                batch.WriteBatchedInsert(sql);
            }
            batch.EndBatchInsert();
            await reader.CloseAsync();

            sqlOut.Close();

            await environment.UpdateDetailedStatus("building database");
            returnValue = GenerateDatabase(environment, "asxinfo");
            if (Directory.Exists(copyFilePath))
                Directory.Delete(copyFilePath, true);
            Directory.CreateDirectory(copyFilePath);
            BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
            string filehelp = string.Empty;
            string sourcePath = environment.TempStoragePath;
            string[] fileEntries = Directory.GetFiles(sourcePath, "*.sql", SearchOption.AllDirectories);
            string path = new FileInfo(fileEntries[0]).Directory.FullName;

            foreach (string newPath in Directory.GetFiles(path, "*.sql*", SearchOption.AllDirectories))
            {
                File.Copy(newPath, newPath.Replace(path, copyFilePath), true);
            }
            return returnValue;
        }

        /// <summary>
        /// 1]Generates the asxairport.sqlite3 file in the output folder
        /// 2]accepts 2 parameter 
        /// 3]based on the path checks whether it exists or not if exists it builds schema
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<int> GenerateASXIAirportinfoDatabase(TaskEnvironment environment, int configurationId)
        {
            /* check for the necessary inputs needed to build the database */
            var tempSqlPath = environment.GetTempPath("asxairport.sqlite3.sql");
            Console.WriteLine(tempSqlPath.ToString());
            var assetCreateSchemaPath = environment.GetLocalAssetPath("data/asxiairport/asxairport.sqlite3.schema.sql");
            string copyFilePath = environment.GetOutputPath() + @"\TempSqlPath";
            if (!File.Exists(assetCreateSchemaPath))
            {
                environment.Logger.LogError("missing database schema file");
                return -1;
            }
            await environment.UpdateDetailedStatus("building ASXIAirportinfo database schema");

            /* copy the database schema to the final location */
            environment.CopyFile(assetCreateSchemaPath, tempSqlPath);
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
            var sqlOut = environment.OpenWriter(tempSqlPath, true, System.Text.Encoding.UTF8);
            int count = 0;
            var batch = new SqlOutputBatch(sqlOut);
            /**
             * tbairportinfo
             **/
            try
            {
                await environment.UpdateDetailedStatus("Started generating tbairportinfo");
                var reader = await GetMappedReader<AirportInfo>(context, configurationId);
                AirportInfo airportInfo = new AirportInfo();
                ASXInfoAirportInfo asxAirport = new ASXInfoAirportInfo();
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxAirport)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxAirport)})");

                while (await reader.ReadAsync())
                {
                    DatabaseMapper.Instance.FromReader(reader, airportInfo);
                    environment.Mapper.Map<AirportInfo, ASXInfoAirportInfo>(airportInfo, asxAirport);
                    var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxAirport);
                    batch.WriteBatchedInsert(rawSql);
                    count++;
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();
                sqlOut.Close();
                await environment.UpdateDetailedStatus("building database");
                int returnValue = 0;
                await environment.UpdateDetailedStatus("Before GenerateDatabase");
                returnValue = GenerateDatabase(environment, "asxairport");
                await environment.UpdateDetailedStatus("After GenerateDatabase");
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                if (!Directory.Exists(copyFilePath))
                {
                    Directory.CreateDirectory(copyFilePath);
                }
                string[] fileEntries = Directory.GetFiles(environment.TempStoragePath, "*.sql", SearchOption.AllDirectories);
                string path = new FileInfo(fileEntries[0]).Directory.FullName;

                foreach (string newPath in Directory.GetFiles(path, "*.sql*", SearchOption.AllDirectories))
                {
                    File.Copy(newPath, newPath.Replace(path, copyFilePath), true);
                }
                return returnValue;
            }
            catch (Exception ex)
            {
                environment.Logger.LogError($"Error {ex}");
                throw (ex);
            }
        }
        /// <summary>
        /// 1]Generates the asxswg.sqlite3 file in the output folder
        /// 2]this method accepts 2 parameters
        /// 3]checks for the path if present then builds schema 
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<int> GenerateASXIaswginfoDatabase(TaskEnvironment environment, int configurationId)
        {
            /* check for the necessary inputs needed to build the database */
            var tempSqlPath = environment.GetTempPath("asxwg.sqlite3.sql");
            var assetCreateSchemaPath = environment.GetLocalAssetPath("data/asxwg/asxwg.sqlite3.schema.sql");
            string copyFilePath = environment.GetOutputPath() + @"\TempSqlPath";
            if (!File.Exists(assetCreateSchemaPath))
            {
                environment.Logger.LogError("missing database schema file");
                return -1;
            }

            await environment.UpdateDetailedStatus("building ASXI WG Info database schema");

            /* copy the database schema to the final location */
            environment.CopyFile(assetCreateSchemaPath, tempSqlPath);

            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
            var sqlOut = environment.OpenWriter(tempSqlPath, true, System.Text.Encoding.UTF8);
            int count = 0;


            var batch = new SqlOutputBatch(sqlOut);

            /**
             * tbwgcontent
             **/
            try
            {
                await environment.UpdateDetailedStatus("Started generating tbwgcontent");
                var reader = await GetMappedReader<WorldGuideContent>(context, configurationId);
                WorldGuideContent worldGuideContent = new WorldGuideContent();
                ASXIWorldGuideContent asxWorldguide = new ASXIWorldGuideContent();
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxWorldguide)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxWorldguide)})");

                while (await reader.ReadAsync())
                {
                    DatabaseMapper.Instance.FromReader(reader, worldGuideContent);
                    environment.Mapper.Map<WorldGuideContent, ASXIWorldGuideContent>(worldGuideContent, asxWorldguide);
                    var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxWorldguide);
                    batch.WriteBatchedInsert(rawSql);
                    count++;
                }

                batch.EndBatchInsert();
                await reader.CloseAsync();



                /**
                 * tbwgimage
                 **/
                await environment.UpdateDetailedStatus("Started generating tbwgimage");
                reader = await GetMappedReader<WorldGuideImage>(context, configurationId);
                WorldGuideImage image = new WorldGuideImage();
                ASXIWorlguideImage asxImage = new ASXIWorlguideImage();
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxImage)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxImage)})");

                while (await reader.ReadAsync())
                {
                    DatabaseMapper.Instance.FromReader(reader, image);
                    environment.Mapper.Map<WorldGuideImage, ASXIWorlguideImage>(image, asxImage);
                    var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxImage);
                    batch.WriteBatchedInsert(rawSql);
                }
                batch.EndBatchInsert();
                reader.Close();

                /**
                 * tbwgtext
                 **/
                await environment.UpdateDetailedStatus("Started generating tbwgtext");
                reader = await GetMappedReader<WorldGuideText>(context, configurationId);
                WorldGuideText text = new WorldGuideText();
                ASXIWorldGuideText asxtext = new ASXIWorldGuideText();
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxtext)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxtext)})");
                while (await reader.ReadAsync())
                {
                    DatabaseMapper.Instance.FromReader(reader, text);
                    environment.Mapper.Map<WorldGuideText, ASXIWorldGuideText>(text, asxtext);
                    var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxtext);
                    batch.WriteBatchedInsert(rawSql);
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();

                /**
                 * tbwgtype
                 **/
                await environment.UpdateDetailedStatus("Started generating tbwgtype");
                reader = await GetMappedReader<WorldGuideType>(context, configurationId);
                WorldGuideType Type = new WorldGuideType();
                ASXIWorldGuideType asxType = new ASXIWorldGuideType();
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxType)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxType)})");
                while (await reader.ReadAsync())
                {
                    DatabaseMapper.Instance.FromReader(reader, Type);
                    environment.Mapper.Map<WorldGuideType, ASXIWorldGuideType>(Type, asxType);
                    var rawSql = DatabaseMapper.Instance.GenerateInsertValues(asxType);
                    batch.WriteBatchedInsert(rawSql);
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();
                sqlOut.Close();
                await environment.UpdateDetailedStatus("building database");
                int returnValue = 0;

                returnValue = GenerateDatabase(environment, "asxwg");

                if (!Directory.Exists(copyFilePath))
                {
                    Directory.CreateDirectory(copyFilePath);
                }
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                string[] fileEntries = Directory.GetFiles(environment.TempStoragePath, "*.sql", SearchOption.AllDirectories);
                string path = new FileInfo(fileEntries[0]).Directory.FullName;

                foreach (string newPath in Directory.GetFiles(path, "*.sql*", SearchOption.AllDirectories))
                {
                    File.Copy(newPath, newPath.Replace(path, copyFilePath), true);
                }
                return returnValue;
            }
            catch (Exception ex)
            {
                environment.Logger.LogError($"Error {ex}");
                throw ex;
            }
        }

        /**
         * Helper function to run the specified command using the windows batch processor
         */
        static void ExecuteCommand(TaskEnvironment environment, string command)
        {
            var processInfo = new ProcessStartInfo("cmd.exe", "/c " + command);
            processInfo.CreateNoWindow = true;
            processInfo.UseShellExecute = false;
            processInfo.RedirectStandardError = true;
            processInfo.RedirectStandardOutput = true;

            var process = Process.Start(processInfo);

            process.OutputDataReceived += (object sender, DataReceivedEventArgs e) =>
                environment.Logger.LogInfo("output>>" + e.Data);
            process.BeginOutputReadLine();

            process.ErrorDataReceived += (object sender, DataReceivedEventArgs e) =>
                environment.Logger.LogError("error>>" + e.Data);
            process.BeginErrorReadLine();

            process.WaitForExit();

            Console.WriteLine("ExitCode: {0}", process.ExitCode);
            process.Close();
        }

        /**
         * Creates the necessary command files and invokes sqlite3.exe in order to generate the asxinfo.sqlite3 file
         * from the generated asxinfo.sqlite3.sql,asxwg.sqlite3,airportinfo.sqlite3 file
         */
        public int GenerateDatabase(TaskEnvironment environment, string fileName)
        {
            var commandsPath = environment.GetTempPath("sqlite3.commands.txt");
            var commandsFile = environment.OpenWriter(commandsPath, false, System.Text.Encoding.ASCII);
            var databaseLocation = Path.GetFullPath(environment.GetOutputPath(fileName + ".sqlite3"));

            environment.UpdateDetailedStatus("databaseLocation =" + $".save \"" + databaseLocation.Replace("\\", @"//") + "\"");
            environment.UpdateDetailedStatus($".read \"" + Path.GetFullPath(environment.GetTempPath(fileName + ".sqlite3.sql")).Replace("\\", @"//") + "\"");

            commandsFile.WriteLine($".read \"" + Path.GetFullPath(environment.GetTempPath(fileName + ".sqlite3.sql")).Replace("\\", @"//") + "\"");
            commandsFile.WriteLine($".save \"" + databaseLocation.Replace("\\", @"//") + "\"");
            commandsFile.WriteLine(".q");
            commandsFile.Close();

            var batchPath = Path.GetFullPath(environment.GetTempPath("sqlite3.exe.bat"));
            var batchFile = environment.OpenWriter(batchPath, System.Text.Encoding.ASCII);
            if (!File.Exists(environment.GetTempPath("sqlite3.exe")))
            {
                File.Copy(environment.GetLocalAssetPath("bin\\sqlite3.exe"), environment.GetTempPath("sqlite3.exe"));
            }
            //batchFile.WriteLine($"{Path.GetFullPath(environment.GetTempPath("sqlite3.exe"))} < {Path.GetFullPath(commandsPath)}");
            batchFile.WriteLine("\"" + Path.GetFullPath(environment.GetTempPath("sqlite3.exe")).Replace("\\", @"//") + "\" < " + "\"" + Path.GetFullPath(commandsPath).Replace("\\", @"//") + "\"");

            batchFile.Close();

            ExecuteCommand(environment, batchPath.Replace("\\", @"//"));

            return 0;
        }

        /**
         * Main execution routine for the task.
         */
        public async Task<int> Run(TaskEnvironment environment, List<string> arguments)
        {
            // get a references to the database
            var work = environment.NewUnitOfWork();
            using var context = work.Create;
            var repos = context.Repositories;

            // validate that the build configuration identified is something we can use
            var configurationId = environment.CurrentTask.ConfigurationID;
            var configuration = await repos.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (configuration == null)
            {
                //environment.Logger.LogError($"configuration {configurationId} could not be found");
                return -1;
            }


            var asxinfoSqlitePath = environment.GetOutputPath("asxinfo.sqlite3");
            var asxiairportPath = environment.GetOutputPath("asxairport.sqlite3");
            var asxiaxwgPath = environment.GetOutputPath("asxwg.sqlite3");


            // get all the pieces that will go into the custom.xml file




            // generate the asxinfo.sqlite3 database
            int databaseResult = await GenerateASXInfoDatabase(environment, configurationId);
            if (databaseResult != 0)
            {
                //environment.Logger.LogInfo("failed to generate database");
                return databaseResult;
            }
            // generate the aswg.sqlite3 database
            int databaseResults = await GenerateASXIaswginfoDatabase(environment, configurationId);
            if (databaseResults != 0)
            {
                //environment.Logger.LogInfo("failed to generate database");
                return databaseResults;
            }
            // generate the airportimfo.sqlite3 database
            int databaseResultsairport = await GenerateASXIAirportinfoDatabase(environment, configurationId);
            if (databaseResultsairport != 0)
            {
                //environment.Logger.LogInfo("failed to generate database");
                return databaseResultsairport;
            }

            await GenerateCustomXML(environment, false);

            return 0;
        }

        public async Task GenerateCustomXML(TaskEnvironment environment, bool isVenuHybrid)
        {

            var work = environment.NewUnitOfWork();
            using var context = work.Create;
            var repos = context.Repositories;

            var tempCustomXMLPath = environment.GetTempPath("custom.xml");
            var customXMLPath = environment.GetOutputPath("custom.xml");

            int configurationId = environment.CurrentTask.ConfigurationID;

            var flyoverAlert = await repos.Simple<ConfigFlyOverAlert>().FirstMappedAsync(configurationId);
            var global = await repos.Simple<ConfigGlobal>().FirstMappedAsync(configurationId);
            var handset = await repos.Simple<ConfigHandset>().FirstMappedAsync(configurationId);
            var html5 = await repos.Simple<ConfigHTML5>().FirstMappedAsync(configurationId);
            var makkah = await repos.Simple<ConfigMakkah>().FirstMappedAsync(configurationId);
            var maps = await repos.Simple<ConfigMaps>().FirstMappedAsync(configurationId);
            var menus = await repos.Simple<ConfigMenu>().FilterMappedAsync(configurationId);
            var miqat = await repos.Simple<ConfigMiqat>().FirstMappedAsync(configurationId);
            var modeDefs = await repos.Simple<ConfigModeDefs>().FirstMappedAsync(configurationId);
            var personality = await repos.Simple<ConfigPersonalityList>().FirstMappedAsync(configurationId);
            var resolution = await repos.Simple<ConfigResolution>().FirstMappedAsync(configurationId);
            var rli = await repos.Simple<ConfigRLI>().FirstMappedAsync(configurationId);
            var scriptDefs = await repos.Simple<ConfigScriptDefs>().FirstMappedAsync(configurationId);
            var ticker = await repos.Simple<ConfigTicker>().FirstMappedAsync(configurationId);
            var tzPlaceNames = await repos.Simple<ConfigTimeZoneGlobePlaceNames>().FirstMappedAsync(configurationId);
            var triggers = await repos.Simple<ConfigTrigger>().FirstMappedAsync(configurationId);
            var tzPOIs = await repos.Simple<ConfigTzPois>().FirstMappedAsync(configurationId);
            var webMain = await repos.Simple<ConfigWebMain>().FirstMappedAsync(configurationId);
            var worldClockCities = await repos.Simple<ConfigWorldClockCities>().FirstMappedAsync(configurationId);
            var worldMapCities = await repos.Simple<ConfigWorldMapCities>().FirstMappedAsync(configurationId);
            var worldMapPlaceNames = await repos.Simple<ConfigWorldMapPlaceNames>().FirstMappedAsync(configurationId);
            var worldTimeZonePlaceNames = await repos.Simple<ConfigWorldTimeZonePlaceNames>().FirstMappedAsync(configurationId);

            // determine which languages are being supported with this configuration
            exportLanguages = await ExtractLanguages(context, global.Global, configurationId);

            await environment.UpdateDetailedStatus("building custom.xml");
            // generate the unformatted custom.xml file
            StreamWriter text = environment.OpenWriter(tempCustomXMLPath);
            text.Write("<?xml version=\"1.0\" encoding=\"utf-8\"?>");

            text.Write("<!-- development export -->");
            text.Write($"<!-- created on {DateTime.Now.ToString()} -->");
            text.Write($"<!-- configuration id: {configurationId} -->");

            text.Write("<asxi>");
            text.Write("<!--Build Information");
            text.WriteLine();
            text.Write("Editor: ASXi Configuration Tool 4.0.7.10188");
            text.WriteLine();
            text.Write($"Date: {DateTime.Now.ToString()}");
            text.WriteLine();
            text.Write("User: Son on SON-PC");
            text.WriteLine();
            text.Write("Customer: AIRSHOW MOBILE");
            text.WriteLine();
            text.Write($"SW PN:");
            text.WriteLine();
            text.Write("Configuration Version: 4.0.1");
            text.WriteLine();
            text.Write("Database Version:");
            text.WriteLine();
            text.Write("Database Platform:");
            text.WriteLine();
            text.Write("Database Creator:");
            text.WriteLine();
            text.Write("Database Customer:");
            text.WriteLine();
            text.Write("Comment:");
            text.WriteLine();
            text.Write("-->");

            if (isVenuHybrid)
                text.Write(" <cfgver>3.0 3D Hybrid</cfgver>");
            else
                text.Write("<cfgver>4.4</cfgver>");
            text.Write("<global>");
            if (global != null)
            {
                if (!isVenuHybrid)
                {
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(global.Global);
                    text.Write(xmlDoc.DocumentElement.InnerXml);
                }
                else
                {
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(global.Global);

                    var root = xmlDoc.FirstChild;

                    foreach (System.Xml.XmlNode child in root.ChildNodes)
                    {
                        if (child.Attributes["interactive_clock"] != null)
                            child.Attributes.Remove(child.Attributes["interactive_clock"]);
                        if (child.Attributes["interactive_units"] != null)
                            child.Attributes.Remove(child.Attributes["interactive_units"]);
                        if (child.Attributes["grouping "] != null)
                            child.Attributes.Remove(child.Attributes["grouping "]);
                        if (child.Attributes["decimal "] != null)
                            child.Attributes.Remove(child.Attributes["decimal "]);
                    }

                    text.Write(xmlDoc.DocumentElement.InnerXml);
                }
                text.Write(global.AirportLanguage);
            }
            text.Write("</global>");
            text.Write("<webmain>");
            if (webMain != null)
            {
                XmlDocument xmlDoc = new XmlDocument();
                if (webMain.WebMainItems != null)
                {
                    xmlDoc.LoadXml(webMain.WebMainItems);
                    text.Write(xmlDoc.DocumentElement.InnerXml);
                }

                if (webMain.InfoItems != null)
                {
                    text.Write(webMain.InfoItems);
                }
            }
            text.Write("<rli active=\"true\"/>");
            text.Write("</webmain>");
            text.Write("<maps>");
            if (maps != null)
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(maps.MapItems);
                if (isVenuHybrid)
                {
                    if (xmlDoc.SelectSingleNode("maps/map_package") != null)
                    {
                        XmlNode mapPackage = xmlDoc.SelectSingleNode("maps/map_package");
                        if (xmlDoc.SelectSingleNode("maps/borders") != null)
                        {
                            XmlNode borders = xmlDoc.SelectSingleNode("maps/borders");
                            if (borders.Attributes["enabled"] != null)
                            {
                                if (borders.Attributes["enabled"].InnerText == "true")
                                {
                                    mapPackage.InnerText = "tembmborders";
                                } 
                                else
                                {
                                    mapPackage.InnerText = "tembmbordersless";
                                }
                            }
                            else
                            {
                                mapPackage.InnerText = "tembmbordersless";
                            }
                        }
                        else
                        {
                            mapPackage.InnerText = "tembmbordersless";
                        }
                    } 
                    else
                    {
                        XmlNode newNode = xmlDoc.CreateElement("element", "map_package", "");
                        newNode.InnerText = "tembmbordersless";
                        xmlDoc.DocumentElement.AppendChild(newNode);
                    }
                } 
                else
                {
                    if (xmlDoc.SelectSingleNode("maps/map_package") != null)
                    {
                        XmlNode mapPackage = xmlDoc.SelectSingleNode("maps/map_package");
                        mapPackage.InnerText = "temlandsat7";
                    }
                    else
                    {
                        XmlNode newNode = xmlDoc.CreateElement("element", "map_package", "");
                        newNode.InnerText = "temlandsat7";
                        xmlDoc.DocumentElement.AppendChild(newNode);
                    }
                }
                text.Write(xmlDoc.DocumentElement.InnerXml);
                text.Write(maps.HardwareCaps);
                text.Write(maps.Borders);
                text.Write(maps.BroadCastBorders);
            }
            text.Write("</maps>");
            text.Write("<menu on_right=\"true\">");
            var menu = menus.Where((x) => x.IsHTML5 == false).FirstOrDefault();
            if (menu != null)
            {
                text.Write(menu.Perspective);
                text.Write(menu.Layers);
            }
            text.Write("</menu>");
            if (!isVenuHybrid)
            {
                text.Write("<worldclock_cities>");
                if (worldClockCities != null)
                {
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(worldClockCities.WorldClockCities);
                    text.Write(xmlDoc.DocumentElement.InnerXml);
                }
                text.Write("</worldclock_cities>");
            }
            text.Write("<tzpois>");
            if (tzPOIs != null)
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(tzPOIs.TZPois);
                text.Write(xmlDoc.DocumentElement.InnerXml);
            }
            text.Write("</tzpois>");

            // the rli item also includes the enclosing text
            if (rli != null)
            {
                text.Write(rli.Rli);
            }

            if (flyoverAlert != null)
            {
                text.Write(flyoverAlert.FlyOverAlert);
            }

            if (worldMapCities != null)
                text.Write(worldMapCities.WorldMapCities);

            if (triggers != null)
                text.Write(triggers.TriggerDefs);

            if (scriptDefs != null)
                text.Write(scriptDefs.ScriptDefs);

            if (modeDefs != null)
            {
                if (isVenuHybrid)
                {
                    text.Write(modeDefs.ModeDefs.Replace("type=\"digital3d\"", "type=\"digital\""));
                }
                else
                    text.Write(modeDefs.ModeDefs);
            }
            text.Write("<flight_profile>asxiprofile.xml</flight_profile>");
            text.Write("<acars>config/acars.xml</acars>");

            if (miqat != null)
                text.Write(miqat.Miqat);

            if (worldTimeZonePlaceNames != null)
                text.Write(worldTimeZonePlaceNames.PlaceNames);

            if (worldMapPlaceNames != null)
                text.Write(worldMapPlaceNames.PlaceNames);

            if (resolution != null)
                if (isVenuHybrid)
                {
                    if(resolution.Resolution.Contains("1280x720"))
                    {
                        text.Write("<screen_resolution id=\"10035\" is2d=\"False\" is3d=\"False\" map_size=\"\" name=\"1280x720\"/>");
                    }
                    else
                    {
                        text.Write(resolution.Resolution);
                    }
                } 
                else
                    text.Write(resolution.Resolution);

            if (tzPlaceNames != null)
                text.Write(tzPlaceNames.PlaceNames);

            text.Write("<exit_button>false</exit_button>");

            if (makkah != null)
                text.Write(makkah.Makkah);

            if (handset != null)
                text.Write(handset.HandSet);

            if (ticker != null)
                text.Write(ticker.Ticker);


            //text.Write("<html5>");
            //text.Write("<menu>");
            //menu = menus.Where((x) => x.IsHTML5 == true).FirstOrDefault();
            //if (menu != null)
            //{
            //    text.Write(menu.Perspective);
            //}
            //text.Write("</menu>");
            //text.Write("<webmain>");
            //if (html5 != null)
            //{
            //    text.Write(html5.InfoItems);
            //}
            //text.Write("</webmain>");
            //text.Write("</html5>");

            text.Write("</asxi>");
            text.Close();
            text.Dispose();

            await environment.UpdateDetailedStatus("formatting custom.xml");
            StreamReader reader = new StreamReader(File.OpenRead(tempCustomXMLPath));
            XDocument doc = XDocument.Parse(reader.ReadToEnd());
            StreamWriter output = environment.OpenWriter(customXMLPath);
            reader.Close();
            output.WriteLine("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
            output.Write(doc.ToString());
            output.Close();
            output.Dispose();
        }

        public async Task<int> GenerateCustom3dXML(TaskEnvironment environment, List<Language> dbLanguages)
        {
            string custom3dPath = environment.GetOutputPath("custom3d.xml");

            StringBuilder stringBuilder = new StringBuilder();
            XmlDocument xmlDoc = new XmlDocument();

            var unitOfWork = environment.NewUnitOfWork();
            using var context = unitOfWork.Create;

            stringBuilder.Append("<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n");
            stringBuilder.Append("<asxi3d>");

            stringBuilder.Append(@"<!--Build Information
                            Editor: ACE Cloud 4.2.0.20224
                            Date: 4/6/2022 11:12:41 AM
                            User: klfortu5
                            Customer: G6500-60058
                            SW PN: 096-5174-155200
                            Database Version: 1
                            Database Platform: HTSE ");
            stringBuilder.Append("-->");
            stringBuilder.Append("<language>");

            stringBuilder.Append("<autoplay_order>" + string.Join(",", dbLanguages.Select(x => x.Name).ToArray()) + "</autoplay_order>");
            stringBuilder.Append("</language>");

            stringBuilder.Append(@"<airport_language>
                </airport_language> ");

            stringBuilder.Append(@"<camera_scripts>");
            stringBuilder.Append(@"<camera id=""1"" name=""camera_default.xml"" description=""default camera view"" />");
            stringBuilder.Append(@"<camera id=""2"" name=""preflight.xml"" description=""preflight camera view"" />");
            stringBuilder.Append(@"<camera id=""3"" name=""compass.xml"" description=""rli camera view"" />");
            stringBuilder.Append(@"<camera id=""4"" name=""midflight.xml"" description=""midflight camera view"" />");
            stringBuilder.Append(@"<camera id=""5"" name=""global_zoom.xml"" description=""zoom camera view"" />");

            stringBuilder.Append(@"</camera_scripts>");

            stringBuilder.Append(@"<transitions>");

            stringBuilder.Append(@"<transition  id=""1"" type=""eAlphablend"" duration=""300"" />");
            stringBuilder.Append(@"<transition  id=""2"" type=""eAlphablend"" duration=""700"" />");

            stringBuilder.Append(@"</transitions>");

            stringBuilder.Append(@"<scenes>");

            stringBuilder.Append(@"<scene  type=""eDefault"" past=""on"" future=""on"" camera=""1"" transition=""1"" />");
            stringBuilder.Append(@"<scene  type=""ePreflight"" past=""on"" future=""on"" camera=""1"" transition=""1"" />");
            stringBuilder.Append(@"<scene  type=""eMidflight"" past=""on"" future=""on"" camera=""1"" transition=""1"" />");
            stringBuilder.Append(@"<scene  type=""eHighestRes"" past=""on"" future=""on"" camera=""1"" transition=""1"" />");
            stringBuilder.Append(@"<scene  type=""eZspace"" past=""on"" future=""on"" camera=""1"" transition=""1"" />");
            stringBuilder.Append(@"<scene  type=""eZoom"" past=""off"" future=""on"" camera=""1"" transition=""1"" />");
            stringBuilder.Append(@"<scene  type=""eRli"" past=""on"" future=""on"" camera=""1"" transition=""1"" />");
            stringBuilder.Append(@"<scene  type=""eTimezone"" past=""on"" future=""on"" camera=""1"" transition=""1"" />");

            stringBuilder.Append(@"</scenes>");

            var colorResult = await context.Repositories.ViewsConfigurationRepository.GetTimezoneColors(environment.CurrentTask.ConfigurationID);
            var list = colorResult.ToList();

            if (list.Count > 0)
                stringBuilder.Append("<timezone_cities depart_color=\"" + list[0] + "\" dest_color=\"" + list[1] + "\" timeatpp_color=\"" + list[2] + "\">");

            var worldTimeZonePlaceNames = await context.Repositories.Simple<ConfigWorldTimeZonePlaceNames>().FirstMappedAsync(environment.CurrentTask.ConfigurationID);

            XmlDocument xmlTimeZoneCity = new XmlDocument();
            if (worldTimeZonePlaceNames != null && !string.IsNullOrWhiteSpace(worldTimeZonePlaceNames.PlaceNames))
            {
                xmlTimeZoneCity.LoadXml(worldTimeZonePlaceNames.PlaceNames);


                XmlNode placeName = xmlTimeZoneCity.SelectSingleNode("world_timezone_placenames");

                XmlNodeList nodeList = placeName.SelectNodes("city");
                var geoRefList = await context.Repositories.CustomContentRepository.GetPlaceNames(environment.CurrentTask.ConfigurationID);

                foreach (XmlNode objXmlNode in nodeList)
                {
                    var geoRefId = Convert.ToInt32(objXmlNode.InnerText);
                    var geoRefName = objXmlNode.Attributes["name"].InnerText;
                    //get info spelling
                    var geoRef = geoRefList.Where(x => x.GeoRefId == geoRefId).ToList();

                    if (geoRef.Count > 0)
                    {
                        var latLon = await context.Repositories.CustomContentRepository.GetLatLonValue(geoRef[0].Id, geoRefId);
                        var spellings = await context.Repositories.CustomContentRepository.GetPlaceNameInfo(environment.CurrentTask.ConfigurationID, geoRef[0].Id);
                        stringBuilder.Append("<city name=\"" + geoRefName + "\" lat=\"" + latLon.Lat1 + "\" " +
                            "lon=\"" + latLon.Lon1 + "\" geoid=\"" + geoRefId + "\" hadjust=\"" + 0.0 + "\" vadjust=\"" + 0.0 + "\">");
                        foreach (var lang in dbLanguages)
                        {
                            var spell = spellings.Where(x => x.LanguageName == lang.Name).ToList();
                            if (spell.Count > 0)
                            {
                                stringBuilder.Append("<lan id=\"" + lang.LanguageID + "\" name=\"" + lang.Name + "\">" + spell[0].PlaceNameValue + "</lan>");
                            }
                        }
                        stringBuilder.Append("</city>");
                    }
                }
            }

            if (list.Count > 0)
                stringBuilder.Append("</timezone_cities>");

            var webMain = await context.Repositories.Simple<ConfigWebMain>().FirstMappedAsync(environment.CurrentTask.ConfigurationID);
            if (webMain != null && !string.IsNullOrWhiteSpace(webMain.InfoItems))
                stringBuilder.Append(webMain.InfoItems);

            var maps = await context.Repositories.Simple<ConfigMaps>().FirstMappedAsync(environment.CurrentTask.ConfigurationID);

            stringBuilder.Append("<maps>");
            if (maps != null)
            {
                if (!string.IsNullOrWhiteSpace(maps.MapItems))
                    stringBuilder.Append(maps.MapItems);
                if (!string.IsNullOrWhiteSpace(maps.HardwareCaps))
                    stringBuilder.Append(maps.HardwareCaps);
                if (!string.IsNullOrWhiteSpace(maps.Borders))
                    stringBuilder.Append(maps.Borders);
                if (!string.IsNullOrWhiteSpace(maps.BroadCastBorders))
                    stringBuilder.Append(maps.BroadCastBorders);
            }
            stringBuilder.Append("</maps>");

            var rli = await context.Repositories.Simple<ConfigRLI>().FirstMappedAsync(environment.CurrentTask.ConfigurationID);

            if (rli != null)
            {
                stringBuilder.Append(rli.Rli);
            }
            stringBuilder.Append("</asxi3d>");
            xmlDoc.LoadXml(stringBuilder.ToString());
            xmlDoc.Save(custom3dPath);

            return 1;
        }


    }
}
