using backend.DataLayer.Models.Configuration;
using backend.worker;
using backend.Worker.Data;
using backend.Worker.Helper;
using System;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.IO;
using backend.DataLayer.Repository.Extensions;
using System.Collections.Generic;
using System.Collections;
using System.Diagnostics.CodeAnalysis;
using backend.DataLayer.Models.CustomContent;
using backend.Mappers.DataTransferObjects.ASXInfo;
using backend.DataLayer.Helpers.Database;
using System.Linq;
using backend.DataLayer.Helpers;
using backend.DataLayer.UnitOfWork.Contracts;
using System.Xml.Linq;

namespace backend.Worker.Tasks
{
    public class EBCDICComparer : IComparer<Airport>
    {

        public int Compare([AllowNull] Airport ax, [AllowNull] Airport ay)
        {
            var x = ax.FourLetID;
            var y = ay.FourLetID;

            if (x == y) return 0;
            if (x == null) return -1;
            if (y == null) return 1;

            // ebcdic = characters, numbers, space, symbols
            int index = 0;
            int result = 0;
            int lenx = x.Length;
            int leny = y.Length;
            do
            {
                if (index >= lenx || index >= leny)
                {
                    if (lenx < leny) result = 1;
                    if (lenx > leny) result = -1;
                }
                else
                {
                    var charx = x.Substring(index, 1);
                    var chary = y.Substring(index, 1);
                    int intx;
                    int inty;
                    var charxisnumber = int.TryParse(charx, out intx);
                    var charyisnumber = int.TryParse(chary, out inty);
                    if (charxisnumber && !charyisnumber) return 1;
                    else if (!charxisnumber && charyisnumber) return -1;
                    else
                    {
                        result = charx.CompareTo(chary);
                    }                    

                    index++;
                }

            } while (result == 0);

            return result;
        }
    }

    public class TaskExportProductDatabase
    {
        // offset to add to the version when exporting from ACE, this ensures that the version of databases
        // are distinct from the old exporter version
        public const int ACE_BASE_VERSION = 100;

        public async Task<int> GenerateAS4000SqlFile(TaskEnvironment environment, int configurationId)
        {
            SqlDataReader reader = null;
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;


            try
            {
                var airportPath = environment.GetOutputPath("4LETID.DAT");
                var airportOut = environment.OpenWriter(airportPath, false, System.Text.Encoding.ASCII);
                var airports = await context.Repositories.AirportInfo.GetExportAllAirports(configurationId);
                
                var ids = new List<Airport>();
                ids.AddRange(airports);
                ids.Sort(new EBCDICComparer());

                airportOut.WriteLine("FOUR LETTER ID,   " + ids.Count.ToString());
                airportOut.WriteLine(";--------------------------------------------------------------");
                airportOut.WriteLine("; baggage id names and positions");

                foreach (var id in ids)
                {
                    var fourLetterId = id.FourLetID.PadRight(4);
                    var degreesLat = Math.Floor(Math.Abs(id.Lat));
                    var degreesLon = Math.Floor(Math.Abs(id.Lon));
                    var remainderLat = (Math.Abs(id.Lat) - degreesLat) * 60m;
                    var remainderLon = (Math.Abs(id.Lon) - degreesLon) * 60m;
                    var minutesLat = Math.Floor(remainderLat);
                    var minutesLon = Math.Floor(remainderLon);
                    var secondsLat = Math.Round((remainderLat - minutesLat) * 60m);
                    var secondsLon = Math.Round((remainderLon - minutesLon) * 60m);

                    if (secondsLat == 60)
                    {
                        secondsLat = 0;
                        minutesLat++;
                    }

                    if (minutesLat == 60)
                    {
                        minutesLat = 0;
                        degreesLat++;
                    }

                    if (secondsLon == 60)
                    {
                        secondsLon = 0;
                        minutesLon++;
                    }

                    if (minutesLon == 60)
                    {
                        minutesLon = 0;
                        degreesLon++;
                    }

                    var headingLat = id.Lat >= 0 ? "N" : "S";
                    var headingLon = id.Lon >= 0 ? "E" : "W";
                    var formattedLat = String.Format("{0:0000}{1:00}{2:00}", degreesLat, minutesLat, secondsLat);
                    var formattedLon = String.Format("{0:0000}{1:00}{2:00}", degreesLon, minutesLon, secondsLon);
                    var line = String.Format("IDN4,\"{0}\",\"{1}\",{2},\"{3}\",{4}", fourLetterId, headingLat, formattedLat, headingLon, formattedLon);

                    airportOut.WriteLine(line);
                }

                airportOut.WriteLine("END FOURID");

                airportOut.Close();
            }
            catch (Exception ex)
            {
                if (reader != null) await reader.DisposeAsync();
                throw new Exception("failed to generate 4LETID.DAT", ex);
            }

            try
            {
                var productName = "as4000";
                var tempSqlFilePath = environment.GetTempPath($"{productName}.sql");
                var sqlOut = environment.OpenWriter(tempSqlFilePath, true);
                var batch = new SqlOutputBatch(sqlOut);
                batch.Format = SqlOutputFormat.Access;

                #region preparation
                // not really needed since the database we import into already has these tables
                // emptied but handy for development debugging
                batch.WriteAccessLog("cleaning up data");
                sqlOut.WriteLine("delete from tbairportinfo;");
                sqlOut.WriteLine("delete from tbappearance;");
                sqlOut.WriteLine("delete from tbcountryname;");
                sqlOut.WriteLine("delete from tbcoveragesegment;");
                sqlOut.WriteLine("delete from tbdestinationspelling;");
                sqlOut.WriteLine("delete from tbpnametrivia;");
                sqlOut.WriteLine("delete from tbspelling;");
                sqlOut.WriteLine("delete from tblanguage;");
                sqlOut.WriteLine("delete from tbgeorefid;");
                #endregion

                #region tbgeorefid
                environment.Logger.LogInfo("exporting to tbgeorefid");
                batch.WriteAccessLog("importing to tbgeorefid");
                reader = await context.Repositories.GeoRefs.GetExportAS4000GeoRefIds(configurationId);
                await batch.BatchInsertReader(reader, "tbGeoRefId");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                sqlOut.WriteLine("UPDATE [tbGeoRefId] SET [4xx POI] = NULL;");
                #endregion

                #region tbairportinfo
                environment.Logger.LogInfo("exporting to tbairportinfo");
                batch.WriteAccessLog("importing airports");
                reader = await context.Repositories.AirportInfo.GetExportAS4000AirportInfo(configurationId);
                await batch.BatchInsertReader(reader, "tbAirportInfo");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                sqlOut.WriteLine("UPDATE [tbAirportInfo] SET [Include] = NULL, [ACARS] = NULL, [DispDest] = NULL;");
                #endregion

                #region tbAppearance
                environment.Logger.LogInfo("exporting to tbappearance");
                batch.WriteAccessLog("importing appearance");
                reader = await context.Repositories.Appearance.GetExportAS4000Appearance(configurationId);
                await batch.BatchInsertReader(reader, "tbAppearance");
                await reader.CloseAsync();
                sqlOut.WriteLine("");

                environment.Logger.LogInfo("exporting to tbappearance (resolution6)");
                batch.WriteAccessLog("importing appearance (resolution 6)");
                reader = await context.Repositories.Appearance.GetExportAS4000AppearanceResolution6(configurationId);
                await batch.BatchInsertReader(reader, "tbAppearance");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tblanguage
                environment.Logger.LogInfo("exporting to tblanguage");
                batch.WriteAccessLog("importing tblanguage");
                reader = await context.Repositories.Simple<Language>().GetExportAS4000Languages(configurationId);
                await batch.BatchInsertReader(reader, "tbLanguage");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbCountryName
                environment.Logger.LogInfo("exporting to tbcountryname");
                batch.WriteAccessLog("importing tbCountryName");
                reader = await context.Repositories.CountrySpellings.GetAS4000CountrySpellings(configurationId);
                await batch.BatchInsertReader(reader, "tbCountryName");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbCoverageSegment
                environment.Logger.LogInfo("exporting to tbCoverageSegment");
                batch.WriteAccessLog("importing tbCoverageSegment");
                reader = await context.Repositories.CoverageSegment.GetAS4000CoverageSegments(configurationId);
                await batch.BatchInsertReader(reader, "tbCoverageSegment");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbSpelling
                environment.Logger.LogInfo("exporting to tbSpelling");
                batch.WriteAccessLog("importing tbSpelling");
                reader = await context.Repositories.Spelling.GetExportAS4000Spellings(configurationId);
                await batch.BatchInsertReader(reader, "tbSpelling");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbDestinationSpelling
                environment.Logger.LogInfo("exporting to tbDestinationSpelling");
                batch.WriteAccessLog("importing tbDestinationSpelling");
                reader = await context.Repositories.Spelling.GetExportDataAS4000DestinationSpelling(configurationId);
                await batch.BatchInsertReader(reader, "tbDestinationSpelling");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbPnameTrivia
                environment.Logger.LogInfo("exporting to tbPnameTrivia(US)");
                batch.WriteAccessLog("importing tbPnameTrivia(US)");
                reader = await context.Repositories.GeoRefs.GetExportAS4000GeoRefIdsPnameTriviaUS(configurationId);
                await batch.BatchInsertReader(reader, "tbPnameTrivia");
                await reader.CloseAsync();
                sqlOut.WriteLine("");

                environment.Logger.LogInfo("exporting to tbPnameTrivia(NonUS)");
                batch.WriteAccessLog("importing tbPnameTrivia(NonUS)");
                reader = await context.Repositories.GeoRefs.GetExportAS4000GeoRefIdsPnameTriviaNonUS(configurationId);
                await batch.BatchInsertReader(reader, "tbPnameTrivia");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                await reader.CloseAsync();

                #region tbAbout
                var configuration = await context.Repositories.ConfigurationRepository.GetConfiguration(configurationId);

                if (configuration == null)
                {
                    throw new Exception("build failed: unable to get version information for configuration: " + configurationId.ToString());
                }
                else {
                    batch.WriteAccessLog("updating version information");
                    sqlOut.WriteLine("delete * from tbabout;");
                    sqlOut.WriteLine("INSERT INTO tbabout (platform) VALUES ('ASX');");
                    sqlOut.WriteLine($"UPDATE tbabout SET version = {ACE_BASE_VERSION + configuration.Version};");
                    sqlOut.WriteLine($"UPDATE tbabout SET baselinecontent = {ACE_BASE_VERSION + configuration.Version};");
                    sqlOut.WriteLine($"UPDATE tbabout SET baselineexporter = 9999;");
                }
                #endregion

                sqlOut.Close();
                await reader.CloseAsync();
                await environment.UpdateDetailedStatus($"building database");
                var outputPath = GenerateProductDatabase(environment, tempSqlFilePath, productName);
            }
            catch (Exception ex)
            {
                if (reader != null) await reader.DisposeAsync();
                throw new Exception("build failed exception", ex);
            }

            return 0;
        }
        
        public async Task<int> GenerateASXI3DPACSqlFile(TaskEnvironment environment, int configurationId)
        {
            var assetCreateSchemaPath = environment.GetLocalAssetPath("data/asxnetandroid/asxnet_android.schema.sql");
            var languageSchemaPath = environment.GetLocalAssetPath("data/asxinfo/asxinfo.sqlite3.languageschema.sql");

            if (!File.Exists(assetCreateSchemaPath))
            {
                environment.Logger.LogError("missing database schema file");
                return -1;
            }

            // create the temp file with the initial database schema
            var tempSqlFilePath = environment.GetTempPath("asxnet_android.sql");
            environment.CopyFile(assetCreateSchemaPath, tempSqlFilePath);
            SqlDataReader reader = null;

            // get database access and a writer to the file and configure the batch output
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;

            try
            {
                var sqlOut = environment.OpenWriter(tempSqlFilePath, true, System.Text.Encoding.UTF8);
                //var batch = new SqlOutputBatch(sqlOut);
                //batch.Format = SqlOutputFormat.MySql;

                List<Language> exportLanguages;

                exportLanguages = await context.Repositories.Simple<Language>().FilterMappedAsync(configurationId);
                var defaultLangauge = exportLanguages.Find(item => item.ID == -1);
                if (defaultLangauge != null)
                {
                    exportLanguages.Remove(defaultLangauge);
                }
                var columnNames = exportLanguages.Select(x => $"Lang_{x.TwoLetterID_ASXi.ToUpper()}").ToList();
                var twoLetterCodes = exportLanguages.Select(x => x.TwoLetterID_ASXi.ToUpper()).ToList();
                var columnSql = string.Join(", ", columnNames);

                var languageSchema = File.ReadAllText(languageSchemaPath);
                var tables = new string[] { "tbinfospelling", "tbGeoRefId", "tbspelling", "tbcountry", "tbRegion" };

                for (int i = 0; i < tables.Length; ++i)
                {
                    foreach (var language in exportLanguages)
                    {
                        sqlOut.WriteLine($"ALTER TABLE {tables[i]} ADD COLUMN Lang_{language.TwoLetterID_ASXi.ToUpper()} {languageSchema};");
                    }
                }

                var batch = new SqlOutputBatch(sqlOut);
                batch.Format = SqlOutputFormat.MySql;

                #region tbGeoRefIdCategoryType
                environment.Logger.LogInfo("exporting to tbgeorefidcategorytype");
                reader = await context.Repositories.GeoRefs.GetExportASXI3dGeoRefIdCategoryType();
                await batch.BatchInsertReader(reader, "tbgeorefidcategorytype");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbGeoRefId
                environment.Logger.LogInfo("exporting to tbgeorefid");
                reader = await context.Repositories.GeoRefs.GetExportASXI3dGeoRefIds(configurationId, exportLanguages, null);
                //await batch.BatchInsertReader(reader, "tbgeorefid");

                batch.BeginBatchInsert($"INSERT INTO tbgeorefid (GeoRefId,Description,GeoRefIdCatTypeId,RegionId," +
                    $" CountryId,Elevation,Population,LayerDisplay,ISearch,RLIPOI,IPOI,WCPOI,MakkahPOI,ClosestPOI,Lat,Lon,CustomChangeBit, {columnSql})");
                while (await reader.ReadAsync())
                {
                    string spellingsSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{DbHelper.DBValueToInt(reader["GeoRefId"])},'{DbHelper.DBValueToString(reader["Description"])}'," +
                        $"{DbHelper.DBValueToInt(reader["GeoRefIdCatTypeId"])},{DbHelper.DBValueToInt(reader["RegionId"])},{DbHelper.DBValueToInt(reader["CountryId"])}," +
                        $"{DbHelper.DBValueToInt(reader["Elevation"])},{DbHelper.DBValueToInt(reader["Population"])},{DbHelper.DBValueToInt(reader["LayerDisplay"])}," +
                        $"{DbHelper.DBValueToInt(reader["ISearch"])},{DbHelper.DBValueToInt(reader["RLIPOI"])},{DbHelper.DBValueToInt(reader["IPOI"])}," +
                        $"{DbHelper.DBValueToInt(reader["WCPOI"])},{DbHelper.DBValueToInt(reader["MakkahPOI"])},{DbHelper.DBValueToInt(reader["ClosestPOI"])},{DbHelper.DBValueToInt(reader["Lat"])}," +
                        $"{DbHelper.DBValueToInt(reader["Lon"])},{DbHelper.DBValueToInt(reader["CustomChangeBit"])}, {spellingsSql}");
                }
                batch.EndBatchInsert();

                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbAirportInfo
                environment.Logger.LogInfo("exporting to tbairportinfo");
                reader = await context.Repositories.AirportInfo.GetExportASXI3dAirportInfo(configurationId);
                await batch.BatchInsertReader(reader, "tbairportinfo");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbAppearance
                environment.Logger.LogInfo("exporting to tbappearance");
                reader = await context.Repositories.Appearance.GetExportASXI3dAppearance(configurationId);
                await batch.BatchInsertReader(reader, "tbappearance");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbCountry
                environment.Logger.LogInfo("exporting to tbcountry");
                reader = await context.Repositories.CountrySpellings.GetASXI3dCountryData(configurationId,exportLanguages);
                //await batch.BatchInsertReader(reader, "tbcountry");
                batch.BeginBatchInsert($"INSERT INTO tbcountry (CountryId,CustomChangeBit, {columnSql})");
                while (await reader.ReadAsync())
                {
                    int valuesSql = DbHelper.DBValueToInt(reader["CountryID"]);
                    int CustomChangeBit = DbHelper.DBValueToInt(reader["CustomChangeBit"]);
                    string spellingsSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{valuesSql},{CustomChangeBit}, {spellingsSql}");
                }
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbCoverageSegment
                environment.Logger.LogInfo("exporting to tbcoveragesegment");
                reader = await context.Repositories.CoverageSegment.GetASXI3dCoverageSegments(configurationId);
                await batch.BatchInsertReader(reader, "tbcoveragesegment");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbLanguage
                environment.Logger.LogInfo("exporting to tblanguage");
                reader = await context.Repositories.Simple<Language>().GetExportASXi3DLanguages(configurationId);
                await batch.BatchInsertReader(reader, "tblanguage");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbRegion
                environment.Logger.LogInfo("exporting to tbregion");
                reader = await context.Repositories.RegionSpellings.GetExportASXI3dRegionSpelling(configurationId, exportLanguages);
                //await batch.BatchInsertReader(reader, "tbregion");
                batch.BeginBatchInsert($"INSERT INTO tbregion (RegionId,CustomChangeBit, {columnSql})");
                while (await reader.ReadAsync())
                {
                    int valuesSql = DbHelper.DBValueToInt(reader["RegionID"]);
                    int CustomChangeBit = DbHelper.DBValueToInt(reader["CustomChangeBit"]);
                    string spellingsSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{valuesSql},{CustomChangeBit}, {spellingsSql}");
                }
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbTzStrip
                environment.Logger.LogInfo("exporting to tbtzstrip");
                reader = await context.Repositories.GeoRefs.GetExportASXI3dGeoRefIdTbTzStrip(configurationId);
                await batch.BatchInsertReader(reader, "tbtzstrip");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion
                
                #region tbfont
                environment.Logger.LogInfo("exporting to tbfont");
                reader = await context.Repositories.FontRepository.GetExportFontForConfigPAC3D(configurationId);
                await batch.BatchInsertReader(reader, "tbfont");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontcategory
                environment.Logger.LogInfo("exporting to tbfontcategory");
                reader = await context.Repositories.FontRepository.GetExportFontCategoryForConfigPAC3D(configurationId);
                await batch.BatchInsertReader(reader, "tbfontcategory");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontdefaultcategory
                environment.Logger.LogInfo("exporting to tbfontdefaultcategory");
                reader = await context.Repositories.FontRepository.GetExportFontDefaultCategoryForConfigPAC3D(configurationId);
                await batch.BatchInsertReader(reader, "tbfontdefaultcategory");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontfamily
                environment.Logger.LogInfo("exporting to tbfontfamily");
                reader = await context.Repositories.FontRepository.GetExportFontFamilyForConfigPAC3D(configurationId);
                await batch.BatchInsertReader(reader, "tbfontfamily");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontmarker
                environment.Logger.LogInfo("exporting to tbfontmarker");
                reader = await context.Repositories.FontRepository.GetExportFontMarkerForConfigPAC3D(configurationId);
                await batch.BatchInsertReader(reader, "tbfontmarker");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfonttexteffect
                environment.Logger.LogInfo("exporting to tbfonttexteffect");
                reader = await context.Repositories.FontRepository.GetExportFontTextEffectForConfigPAC3D(configurationId);
                await batch.BatchInsertReader(reader, "tbfonttexteffect");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbinfospelling
                environment.Logger.LogInfo("exporting to tbinfospelling");
                var asxInfoSpelling = new ASXInfoInfoSpelling();
                reader = await context.Repositories.InfoSpellings.GetExportSpellingsForConfig(configurationId, exportLanguages);
                batch.BeginBatchInsert($"INSERT INTO {DatabaseMapper.Instance.GetTableName(asxInfoSpelling)} ({DatabaseMapper.Instance.GenerateInsertColumns(asxInfoSpelling)}, {columnSql})");
                while (await reader.ReadAsync())
                {
                    string valuesSql = reader["infoid"].ToString();
                    string spellingsSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{valuesSql}, {spellingsSql}");
                }
                batch.EndBatchInsert(); await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion
                
                #region tbscreensize
                environment.Logger.LogInfo("exporting to tbscreensize");
                reader = await context.Repositories.ScreenSize.GetExportScreenSizeForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbscreensize");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbwgcontent
                environment.Logger.LogInfo("exporting to tbwgcontent");
                reader = await context.Repositories.WorldGuide.GetExportWGContentForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbwgcontent");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbwgimage
                environment.Logger.LogInfo("exporting to tbwgimage");
                reader = await context.Repositories.WorldGuide.GetExportWGImageForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbwgimage");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbwgtext
                environment.Logger.LogInfo("exporting to tbwgtext");
                reader = await context.Repositories.WorldGuide.GetExportWGTextForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbwgtext");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbwgtype
                environment.Logger.LogInfo("exporting to tbwgtype");
                reader = await context.Repositories.WorldGuide.GetExportWGTypeForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbwgtype");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region "tbwgcities"

                environment.Logger.LogInfo("exporting to tbwgwcities");
                reader = await context.Repositories.Simple<WorldGuideCities>().GetExportASXi3DWGCities(configurationId);
                await batch.BatchInsertReader(reader, "tbwgwcities");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                sqlOut.WriteLine("--");
                sqlOut.WriteLine("-- tbwgcities excluded");
                sqlOut.WriteLine("--");
                environment.Logger.LogInfo("exporting to tbwgwcities");
                reader = await context.Repositories.WorldGuide.GetExportWGCitiesForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbwgwcities");
                await reader.CloseAsync();
                sqlOut.WriteLine("");

                #endregion


                #region tbAbout
                var configuration = await context.Repositories.ConfigurationRepository.GetConfiguration(configurationId);
                if (configuration == null)
                {
                    throw new Exception("build failed: unable to get version information for configuration: " + configurationId.ToString());
                }
                else
                {
                    sqlOut.WriteLine("/*!40000 ALTER TABLE `tbabout` DISABLE KEYS */;");
                    sqlOut.WriteLine("INSERT INTO `tbAbout` (`Version`, `Platform`, `BaselineContent`, `BaselineExporter`) VALUES");
                    sqlOut.WriteLine(String.Format(" ({0},'ASXi 3D PAC, Airshow Mobile 2, Airshow for Browsers', {0}, 9999);", ACE_BASE_VERSION + configuration.Version));
                    sqlOut.WriteLine("/*!40000 ALTER TABLE `tbabout` ENABLE KEYS */;");
                    sqlOut.WriteLine("");
                }
                #endregion

                #region postschema
                var postSchemaPath = environment.GetLocalAssetPath("data\\asxnetandroid\\asxnet_android.postschema.sql");
                if (!File.Exists(postSchemaPath))
                {
                    environment.Logger.LogError("missing asxnet android post schema file");
                    return 1;
                }

                var postSchema = File.ReadAllText(postSchemaPath);
                sqlOut.WriteLine(postSchema);
                #endregion

                sqlOut.Close();

                var outputPath = environment.GetOutputPath("asxnet_android.sql");
                environment.CopyFile(tempSqlFilePath, outputPath);
            }
            catch (Exception ex)
            {
                if (reader != null) await reader.DisposeAsync();
                throw new Exception("build failed exception", ex);
            }
            return 0;
        }

        /**
         * Generates the asxnet.sql file for a ces htse project. The functionality is based off the previously existing baseline importer.
         * In that setup, some of the baseline data was contained in the destination .mdb file. Instead of being in an .mdb file, the baseline data
         * is instead already captured in the asxnet.defaults.sql file which is then appended to by this export process. If the baseline data (eg. fonts, info spellings)
         * need to be updated, then they will have to be updated in the asxnet.defaults.sql file.
         */

        

        public async Task<int> GenerateCesHtseSqlFile(TaskEnvironment environment, int configurationId, bool isVenueHybrid = false)
        {
            var assetCreateSchemaPath = environment.GetLocalAssetPath("data/ceshtse/asxnet.defaults.sql");
			if (isVenueHybrid)
            {
                //Load sqlite3 formatted script
                assetCreateSchemaPath = environment.GetLocalAssetPath("data/ceshtse/asxnet.defaults.sqlite3.sql");
            }
            var languageSchemaPath = environment.GetLocalAssetPath("data/asxinfo/asxinfo.sqlite3.languageschema.sql");

            if (!File.Exists(assetCreateSchemaPath))
            {
                environment.Logger.LogError("missing database schema file");
                return -1;
            }

            // create the temp file with the initial database schema
            var tempSqlFilePath = environment.GetTempPath("asxnet.sql");
            environment.CopyFile(assetCreateSchemaPath, tempSqlFilePath);
            SqlDataReader reader = null;

            // get database access and a writer to the file and configure the batch output
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;

            try
            {
                var sqlOut = environment.OpenWriter(tempSqlFilePath, true, System.Text.Encoding.UTF8);


                List<Language> exportLanguages;
                exportLanguages = await context.Repositories.Simple<Language>().FilterMappedAsync(configurationId);
                var defaultLangauge = exportLanguages.Find(item => item.ID == -1);
                if (defaultLangauge != null)
                {
                    exportLanguages.Remove(defaultLangauge);
                }
                var columnNames = exportLanguages.Select(x => $"Lang_{x.TwoLetterID_ASXi.ToUpper()}").ToList();
                var twoLetterCodes = exportLanguages.Select(x => x.TwoLetterID_ASXi.ToUpper()).ToList();
                var columnSql = string.Join(", ", columnNames);
                
                var languageSchema = File.ReadAllText(languageSchemaPath);
                var tables = new string[] { "tbinfospelling", "tbpnametrivia", "tbspelling" };

                for (int i = 0; i < tables.Length; ++i)
                {
                    foreach (var language in exportLanguages)
                    {
                        sqlOut.WriteLine($"ALTER TABLE {tables[i]} ADD COLUMN Lang_{language.TwoLetterID_ASXi.ToUpper()} {languageSchema};");
                    }
                }
                var batch = new SqlOutputBatch(sqlOut);
                batch.Format = SqlOutputFormat.MySql;

                #region tbairportinfo
                environment.Logger.LogInfo("exporting to tbairportinfo");
                reader = await context.Repositories.AirportInfo.GetExportCESHTSEAirportInfo(configurationId);
                await batch.BatchInsertReader(reader, "tbairportinfo");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbappearance
                environment.Logger.LogInfo("exporting to tbappearance");
                reader = await context.Repositories.Appearance.GetExportCESHTSEAppearance(configurationId);
                await batch.BatchInsertReader(reader, "tbappearance");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbcoveragesegment
                environment.Logger.LogInfo("exporting to tbcoveragesegment");
                reader = await context.Repositories.CoverageSegment.GetCESHTSECoverageSegments(configurationId);
                await batch.BatchInsertReader(reader, "tbcoveragesegment");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbgeorefid
                environment.Logger.LogInfo("exporting to tbgeorefid");
                reader = await context.Repositories.GeoRefs.GetExportCESHTSEGeoRefIds(configurationId);
                await batch.BatchInsertReader(reader, "tbgeorefid");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbpnametrivia
                environment.Logger.LogInfo("exporting to tbpnametrivia");
                reader = await context.Repositories.Spelling.GetExportCESHTSESpellingsTrivia(configurationId,exportLanguages);
                
                batch.BeginBatchInsert($"INSERT INTO tbpnametrivia (GeoRefId,Elevation,Population, {columnSql})");

                while (await reader.ReadAsync())
                {
                    string geoRefId = reader["GeoRefId"].ToString();
                    int Elevation = DbHelper.DBValueToInt(reader["Elevation"]);
                    int Population = DbHelper.DBValueToInt(reader["Population"]);

                    string spellingsSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{geoRefId},{Elevation},{Population}, {spellingsSql}");
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbspelling
                environment.Logger.LogInfo("exporting to tbspelling");

                reader = await context.Repositories.Spelling.GetExportSpellings(configurationId, exportLanguages);

                batch.BeginBatchInsert($"INSERT INTO tbspelling (GeoRefId, {columnSql})");
                while (await reader.ReadAsync())
                {
                    string valuesSql = reader["GeoRefId"].ToString();
                    string spellingsSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{valuesSql}, {spellingsSql}");
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbabout
                var configuration = await context.Repositories.ConfigurationRepository.GetConfiguration(configurationId);
                if (configuration == null)
                {
                    throw new Exception("build failed: unable to get version information for configuration: " + configurationId.ToString());
                }
                else
                {
                    sqlOut.WriteLine("/*!40000 ALTER TABLE `tbabout` DISABLE KEYS */;");
                    sqlOut.WriteLine("INSERT INTO `tbabout` (`Version`, `Platform`, `BaselineContent`, `BaselineExporter`) VALUES");
                    sqlOut.WriteLine(String.Format(" ({0},'CES HTSE', {0}, 9999);", ACE_BASE_VERSION + configuration.Version));
                    sqlOut.WriteLine("/*!40000 ALTER TABLE `tbabout` ENABLE KEYS */;");
                    sqlOut.WriteLine("");
                }
                #endregion

                #region tbInfoSpelling
                environment.Logger.LogInfo("exporting to tbInfospelling");

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
                sqlOut.WriteLine("");

                #endregion

                #region tbfont
                environment.Logger.LogInfo("exporting to tbfont");
                reader = await context.Repositories.FontRepository.GetExportFontForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfont");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontcategory
                environment.Logger.LogInfo("exporting to tbfontcategory");
                reader = await context.Repositories.FontRepository.GetExportFontCategoryForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfontcategory");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontdefaultcategory
                environment.Logger.LogInfo("exporting to tbfontdefaultcategory");
                reader = await context.Repositories.FontRepository.GetExportFontDefaultCategoryForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfontdefaultcategory");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontfamily
                environment.Logger.LogInfo("exporting to tbfontfamily");
                reader = await context.Repositories.FontRepository.GetExportFontFamilyForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfontfamily");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontmarker
                environment.Logger.LogInfo("exporting to tbfontmarker");
                reader = await context.Repositories.FontRepository.GetExportFontMarkerForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfontmarker");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfonttexteffect
                environment.Logger.LogInfo("exporting to tbfonttexteffect");
                reader = await context.Repositories.FontRepository.GetExportFontTextEffectForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfonttexteffect");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tblLanguage

                if (isVenueHybrid)
                {
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
                }
                #endregion

                #region postschema
                var postSchemaPath = environment.GetLocalAssetPath("data\\ceshtse\\asxnet.postschema.sql");
                if (!File.Exists(postSchemaPath))
                {
                    environment.Logger.LogError("missing asxnet ces htse post schema file");
                    return 1;
                }

                var postSchema = File.ReadAllText(postSchemaPath);
                sqlOut.WriteLine(postSchema);
                #endregion

                

                sqlOut.Close();

                var outputPath = environment.GetOutputPath("asxnet.sql");
                environment.CopyFile(tempSqlFilePath, outputPath);
            }
            catch (Exception ex)
            {
                if (reader != null) await reader.DisposeAsync();
                throw new Exception("build failed exception", ex);
            }

            return 0;
        }

        public async Task<List<Language>> ExtractLanguages(IUnitOfWorkAdapter uow, string languageXml, int configurationId)
        {
            XDocument tree = XDocument.Parse(languageXml);

            string[] allLanguages = tree.Root.Element("language_set").Value.Split(",");
            var dbLanguages = await uow.Repositories.Simple<Language>().FilterMappedAsync(configurationId);

            List<Language> result = new List<Language>();
            for (int i = 0; i < allLanguages.Length; ++i)
            {
                var expectedName = allLanguages[i].ToUpper().Substring(1);
                var record = dbLanguages.Where(x => x.Name == expectedName).FirstOrDefault();
                if (record == null) continue;
                result.Add(record);
            }

            return result;
        }
        public async Task<int> GenerateThalesSqlFile(TaskEnvironment environment, int configurationId)
        {
            var assetCreateSchemaPath = environment.GetLocalAssetPath("data/thales/asxnet.defaults.sql");
            var languageSchemaPath = environment.GetLocalAssetPath("data/asxinfo/asxinfo.sqlite3.languageschema.sql");

            if (!File.Exists(assetCreateSchemaPath))
            {
                environment.Logger.LogError("missing database schema file");
                return -1;
            }

            // create the temp file with the initial database schema
            var tempSqlFilePath = environment.GetTempPath("asxnet.sql");
            environment.CopyFile(assetCreateSchemaPath, tempSqlFilePath);
            SqlDataReader reader = null;

            // get database access and a writer to the file and configure the batch output
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;

            try
            {
                var sqlOut = environment.OpenWriter(tempSqlFilePath, true, System.Text.Encoding.UTF8);


                List<Language> exportLanguages;

                exportLanguages = await context.Repositories.Simple<Language>().FilterMappedAsync(configurationId);
                var defaultLangauge = exportLanguages.Find(item => item.ID == -1);
                if (defaultLangauge != null)
                {
                    exportLanguages.Remove(defaultLangauge);
                }
                var columnNames = exportLanguages.Select(x => $"Lang_{x.TwoLetterID_ASXi.ToUpper()}").ToList();
                var twoLetterCodes = exportLanguages.Select(x => x.TwoLetterID_ASXi.ToUpper()).ToList();
                var columnSql = string.Join(", ", columnNames);

                var languageSchema = File.ReadAllText(languageSchemaPath);

                var tables = new string[] { "tbinfospelling", "tbspelling" };

                for (int i = 0; i < tables.Length; ++i)
                {
                    foreach (var language in exportLanguages)
                    {
                        sqlOut.WriteLine($"ALTER TABLE {tables[i]} ADD COLUMN Lang_{language.TwoLetterID_ASXi.ToUpper()} {languageSchema};");
                    }
                }
                var batch = new SqlOutputBatch(sqlOut);
                batch.Format = SqlOutputFormat.MySql;

                #region tbgeorefid
                // purposefully re-using the ceshtse export here, they export the same subset of data
                environment.Logger.LogInfo("exporting to tbgeorefid");
                reader = await context.Repositories.GeoRefs.GetExportCESHTSEGeoRefIds(configurationId);
                await batch.BatchInsertReader(reader, "tbgeorefid");
                await reader.CloseAsync();
                sqlOut.WriteLine("");

                #endregion

                #region tbairportinfo
                environment.Logger.LogInfo("exporting to tbairportinfo");
                reader = await context.Repositories.AirportInfo.GetExportThalesAirportInfo(configurationId);
                await batch.BatchInsertReader(reader, "tbairportinfo");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbappearance
                // purposefully re-using the ceshtse export here, they export the same subset of data
                environment.Logger.LogInfo("exporting to tbappearance");
                reader = await context.Repositories.Appearance.GetExportCESHTSEAppearance(configurationId);
                await batch.BatchInsertReader(reader, "tbappearance");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbcoveragesegment
                // purposefully re-using the ceshtse export here, they export the same subset of data
                environment.Logger.LogInfo("exporting to tbcoveragesegment");
                reader = await context.Repositories.CoverageSegment.GetCESHTSECoverageSegments(configurationId);
                await batch.BatchInsertReader(reader, "tbcoveragesegment");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbpnametrivia
                environment.Logger.LogInfo("exporting to tbpnametrivia");
                reader = await context.Repositories.Spelling.GetExportThalesPNameTriva(configurationId);
                await batch.BatchInsertReader(reader, "tbpnametrivia");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbspelling
                environment.Logger.LogInfo("exporting to tbspelling");

                reader = await context.Repositories.Spelling.GetExportSpellings(configurationId, exportLanguages);

                batch.BeginBatchInsert($"INSERT INTO tbspelling (GeoRefId, {columnSql})");
                while (await reader.ReadAsync())
                {
                    string valuesSql = reader["GeoRefId"].ToString();
                    string spellingsSql = String.Join(", ", twoLetterCodes.Select(x => DbHelper.DbValueToSqlString(reader[x])));
                    batch.WriteBatchedInsert($"{valuesSql}, {spellingsSql}");
                }
                batch.EndBatchInsert();
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbabout
                var configuration = await context.Repositories.ConfigurationRepository.GetConfiguration(configurationId);
                if (configuration == null)
                {
                    throw new Exception("build failed: unable to get version information for configuration: " + configurationId.ToString());
                }
                else
                {
                    sqlOut.WriteLine("/*!40000 ALTER TABLE `tbabout` DISABLE KEYS */;");
                    sqlOut.WriteLine("INSERT INTO `tbAbout` (`Version`, `Platform`, `BaselineContent`, `BaselineExporter`) VALUES");
                    sqlOut.WriteLine(String.Format(" ({0},'ASXi THA', {0}, 9999);", ACE_BASE_VERSION + configuration.Version));
                    sqlOut.WriteLine("/*!40000 ALTER TABLE `tbabout` ENABLE KEYS */;");
                    sqlOut.WriteLine("");
                }
                #endregion

                #region tbInfoSpelling
                environment.Logger.LogInfo("exporting to tbInfospelling");

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
                sqlOut.WriteLine("");
                #endregion

                #region tbfont
                environment.Logger.LogInfo("exporting to tbfont");
                reader = await context.Repositories.FontRepository.GetExportFontForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfont");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontcategory
                environment.Logger.LogInfo("exporting to tbfontcategory");
                reader = await context.Repositories.FontRepository.GetExportFontCategoryForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfontcategory");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontdefaultcategory
                environment.Logger.LogInfo("exporting to tbfontdefaultcategory");
                reader = await context.Repositories.FontRepository.GetExportFontDefaultCategoryForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfontdefaultcategory");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontfamily
                environment.Logger.LogInfo("exporting to tbfontfamily");
                reader = await context.Repositories.FontRepository.GetExportFontFamilyForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfontfamily");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfontmarker
                environment.Logger.LogInfo("exporting to tbfontmarker");
                reader = await context.Repositories.FontRepository.GetExportFontMarkerForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfontmarker");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region tbfonttexteffect
                environment.Logger.LogInfo("exporting to tbfonttexteffect");
                reader = await context.Repositories.FontRepository.GetExportFontTextEffectForConfig(configurationId);
                await batch.BatchInsertReader(reader, "tbfonttexteffect");
                await reader.CloseAsync();
                sqlOut.WriteLine("");
                #endregion

                #region postschema
                var postSchemaPath = environment.GetLocalAssetPath("data\\thales\\asxnet.postschema.sql");
                if (!File.Exists(postSchemaPath))
                {
                    environment.Logger.LogError("missing asxnet thales post schema file");
                    return 1;
                }

                var postSchema = File.ReadAllText(postSchemaPath);
                sqlOut.WriteLine(postSchema);
                #endregion

                sqlOut.Close();

                var outputPath = environment.GetOutputPath("asxnet.sql");
                environment.CopyFile(tempSqlFilePath, outputPath);
            }
            catch (Exception ex)
            {
                if (reader != null) await reader.DisposeAsync();
                throw new Exception("build failed exception", ex);
            }

            return 0;
        }

        public string GenerateProductDatabase(TaskEnvironment environment, string sqlPath, string productName)
        {
            var importerPath = environment.GetLocalAssetPath("bin\\AceImport.jar");
            var javaPath = Program.Configuration.GetValue<string>("JavaPath");
            var assetMdbPath = environment.GetLocalAssetPath("data\\as4xxx\\Asx.mdb");
            var tempMdbPath = environment.GetTempPath("Asx.mdb");

            environment.CopyFile(assetMdbPath, tempMdbPath);
            
            javaPath = System.IO.Path.Join(javaPath, "java.exe");
            var command = $"\"{javaPath}\" -jar {importerPath} -Dcommand accessexecutesql -Daccessdatabase {tempMdbPath} -Dsqlfile {sqlPath}";
            ExecuteCommand(environment, command);
            var outputPath = environment.GetOutputPath($"Asx.mdb");
            environment.CopyFile(tempMdbPath, outputPath);
            return outputPath;
        }

        static void ExecuteCommand(TaskEnvironment environment, string command)
        {
            var processInfo = new ProcessStartInfo("cmd.exe", "/c " + command)
            {
                CreateNoWindow = true,
                UseShellExecute = false,
                RedirectStandardError = true,
                RedirectStandardOutput = true
            };

            var process = Process.Start(processInfo);

            process.OutputDataReceived += (object sender, DataReceivedEventArgs e) =>
                environment.Logger.LogInfo("access>>" + e.Data);
            process.BeginOutputReadLine();

            process.ErrorDataReceived += (object sender, DataReceivedEventArgs e) =>
                environment.Logger.LogInfo("access error>>" + e.Data);
            process.BeginErrorReadLine();

            process.WaitForExit();

            environment.Logger.LogInfo("access>>ExitCode: " + process.ExitCode.ToString());
            process.Close();
        }

    }
}
