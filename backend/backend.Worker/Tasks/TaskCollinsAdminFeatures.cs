using backend.DataLayer.Helpers;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.ConfigMerge;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Models.Task;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers.Azure;
using backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.worker;
using backend.Worker.Data;
using backend.Worker.Helper;
using ClosedXML.Excel;
using CsvHelper;
using CsvHelper.Configuration;
using FastMember;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Data.SQLite;
using System.Diagnostics;
using System.Drawing;
using System.Dynamic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;
using static backend.DataLayer.Models.Configuration.ModListJsonData;
using Task = System.Threading.Tasks.Task;

namespace backend.Worker.Tasks
{
    public class TaskCollinsAdminFeatures
    {
        private readonly BuildPackageHelper packageHelper = new BuildPackageHelper();

        #region Public methods
        public async Task<int> ImportWGCities(TaskEnvironment environment, Guid CurrentTaskID, int configurationId, string path, Guid CurrentUserID)
        {


            string zipPath = path + ".zip";

            StringBuilder sbErrorLogs = new StringBuilder("ImportWGCities:");
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            ZipFile.ExtractToDirectory(zipPath, path);
            string[] filePaths = Directory.GetFiles(path, ".",
                                         SearchOption.AllDirectories);
            string xmlDocRockwell = string.Empty;
            string xmlDocFlightPoi = string.Empty;
            string poiidtoGeoRefIdCSV = string.Empty;
            string cityidtoGeoRefIdCSV = string.Empty;
            string wgcontentPath = string.Empty;
            List<PoiIDtoGeoRefID> _poiIDtoGeoRefs = new List<PoiIDtoGeoRefID>();
            List<CityIDtoGeoRefID> _cityIDtoGeoRefIDs = new List<CityIDtoGeoRefID>();
            List<WGDetailedFlightInfoDTO> _WGDetailedFtInfo = new List<WGDetailedFlightInfoDTO>();
            List<WGCityFlightInfoDTO> _WGCityFtInfo = new List<WGCityFlightInfoDTO>();
            List<string> imgList = new List<string>();

            string[] files_c = Directory.GetFiles(path, "*.*", SearchOption.AllDirectories);
            foreach (string s in files_c)
            {
                if (s.Contains("Rockwell.xml"))
                {
                    xmlDocRockwell = environment.PathWrapper(s);
                }
                if (s.Contains("flight_POI.xml"))
                {
                    xmlDocFlightPoi = environment.PathWrapper(s);
                }
                if (s.Contains("poiid-to-georefid.csv"))
                {
                    poiidtoGeoRefIdCSV = environment.PathWrapper(s);
                }
                if (s.Contains("cityid-to-georefid.csv"))
                {
                    cityidtoGeoRefIdCSV = environment.PathWrapper(s);
                }
                if (s.EndsWith(".jpg"))
                {
                    wgcontentPath = environment.PathWrapper(Path.GetDirectoryName(s));
                }
            }
            if (File.Exists(poiidtoGeoRefIdCSV))
            {
                _poiIDtoGeoRefs = importPoiMapFromCsv(poiidtoGeoRefIdCSV);
            }
            if (File.Exists(cityidtoGeoRefIdCSV))
            {
                _cityIDtoGeoRefIDs = importCityFromCsv(cityidtoGeoRefIdCSV);
            }
            if (File.Exists(xmlDocRockwell))
            {
                _WGDetailedFtInfo = importWGDetailedFtInfoFromXML(xmlDocRockwell, _cityIDtoGeoRefIDs);
            }
            if (File.Exists(xmlDocFlightPoi))
            {
                _WGCityFtInfo = importWGCityFtInfoFromXML(xmlDocFlightPoi, _poiIDtoGeoRefs, _cityIDtoGeoRefIDs);
            }

            if (Directory.Exists(wgcontentPath))
            {
                DirectoryInfo di = new DirectoryInfo(wgcontentPath);
                FileInfo[] imgFiles = di.GetFiles("*.jpg").Union(di.GetFiles("*.jpeg")).ToArray();
                foreach (FileInfo img in imgFiles)
                {
                    imgList.Add(img.Name.Substring(0, img.Name.LastIndexOf(".")));
                }
            }


            List<string> missingImages = _WGCityFtInfo.Select(x => x.Imagefilename.Substring(0, x.Imagefilename.LastIndexOf("."))).ToList().Except(imgList).ToList();
            if (missingImages.Count() == 0)
            {
                ZipFile.CreateFromDirectory(wgcontentPath, wgcontentPath + ".zip");
                Directory.Delete(wgcontentPath, true);

                await UploadToBlobStorage(environment, configurationId, CurrentUserID, wgcontentPath + ".zip", "WoldGuideContent", "WorldGuide");
            }
            else
            {
                sbErrorLogs.AppendFormat("{0};", "The following Files are missed in the WG Content:");
                missingImages.ForEach(item => sbErrorLogs.Append(item + ","));
                environment.CurrentTask.ErrorLog = sbErrorLogs.ToString();
                return -1;
            }

            await CopytoTempWGDetailedFlightInfo(_WGDetailedFtInfo);
            await CopytoTempWGCityFlightInfo(_WGCityFtInfo);

            // get database access and a writer to the file and configure the batch output
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
            var result = await context.Repositories.ConfigurationRepository.AddNewWGCities(CurrentTaskID, configurationId, CurrentUserID);
            if (result > 0)
            {
                await context.SaveChanges();
                await environment.UpdateDetailedStatus("WGCities have been Imported");
                return 0;
            }
            sbErrorLogs.AppendFormat("{0};", "Exception in Stored Procedure");
            environment.CurrentTask.ErrorLog = sbErrorLogs.ToString();
            return -1;
        }
        public List<PoiIDtoGeoRefID> importPoiMapFromCsv(string path)
        {
            PoiIDtoGeoRefID _poitoGeoRefId = new PoiIDtoGeoRefID();
            List<PoiIDtoGeoRefID> _poitoGeoRefIds = new List<PoiIDtoGeoRefID>();

            var config = new CsvConfiguration(CultureInfo.InvariantCulture)
            {
                MissingFieldFound = null,
                BadDataFound = null

            };

            using (TextReader tr = File.OpenText(path))
            {
                var csv = new CsvReader(tr, config);
                csv.Context.RegisterClassMap<PoiIDtoGeoRefIDMap>();
                while (csv.Read())
                {
                    _poitoGeoRefId = csv.GetRecord<PoiIDtoGeoRefID>();
                    _poitoGeoRefIds.Add(_poitoGeoRefId);
                }

            }
            return _poitoGeoRefIds;
        }
        public List<CityIDtoGeoRefID> importCityFromCsv(string path)
        {
            const int cityGeoRedIDPosition = 1;
            CityIDtoGeoRefID _cityidtoGeoRefId = new CityIDtoGeoRefID();
            List<CityIDtoGeoRefID> _cityidtoGeoRefIds = new List<CityIDtoGeoRefID>();

            var config = new CsvConfiguration(CultureInfo.InvariantCulture)
            {
                MissingFieldFound = null,
                BadDataFound = null

            };

            using (TextReader tr = File.OpenText(path))
            {
                var csv = new CsvReader(tr, config);
                csv.Context.RegisterClassMap<CityIDtoGeoRefIDMap>();
                while (csv.Read())
                {
                    bool isbadRecord = string.IsNullOrWhiteSpace(csv.GetField(cityGeoRedIDPosition)) || csv.GetField(cityGeoRedIDPosition) == "NULL";
                    if (!isbadRecord)
                    {
                        _cityidtoGeoRefId = csv.GetRecord<CityIDtoGeoRefID>();
                        _cityidtoGeoRefIds.Add(_cityidtoGeoRefId);
                    }
                }

            }
            return _cityidtoGeoRefIds;
        }


      
        public List<WGDetailedFlightInfoDTO> importWGDetailedFtInfoFromXML(string xmlDocRockwell, List<CityIDtoGeoRefID> _cityIDtoGeoRefIDs)
        {
            List<WGDetailedFlightInfoDTO> _WGDetailedFtInfo = new List<WGDetailedFlightInfoDTO>();
            try
            {
                XDocument xmlDocRC = (XDocument.Parse(File.ReadAllText(xmlDocRockwell, System.Text.Encoding.UTF8)));

                _WGDetailedFtInfo = (
                   from city in xmlDocRC.Element("cityfile").Elements("city")
                   select new WGDetailedFlightInfoDTO
                   {

                       CityId = ((int)city.Element("city_id")),
                       CityName = ((string)city.Element("city_name")),
                       ImageFileNames = city.Descendants("image").Select(h => h.Value).ToArray(),
                       ImageCaptions = city.Descendants("image").Attributes("caption").Select(h => h.Value).ToArray(),

                       CityGuides = (
                       from _cityGuides in city.Element("cityguides").Elements("cityguide")
                       select new Cityguide
                       {
                           cityguide = _cityGuides.Value.ToString(),
                           cityguideType = _cityGuides.Attribute("type").Value.ToString(),
                       }).ToArray()


                   }
                   ).ToList();
                string[] stats;

                StringBuilder sb = new StringBuilder();
                foreach (var eachCity in _WGDetailedFtInfo)
                {
                    foreach (var eachcityGuide in eachCity.CityGuides)
                    {
                        // 
                        if ((eachcityGuide.cityguideType == "gen_intro") & (eachcityGuide.cityguide.Split("<strong>").Length > 0))
                        {
                            StringBuilder sbCityOverview = new StringBuilder("<div class=\"OverviewText\">");
                            sbCityOverview.Append(Regex.Replace(eachcityGuide.cityguide.Split("<strong>")[0], "<.*?>", string.Empty));
                            sbCityOverview.Append("</div>");
                            eachCity.Overview = sbCityOverview.ToString();

                            StringBuilder sbCitySights = new StringBuilder("<div class=\"WorldGuide\">");
                            eachCity.Sights = string.Concat(eachcityGuide.cityguide.Split("<strong>").Skip(1));
                            sbCitySights.Append(Regex.Replace(eachCity.Sights, "<.*?>", string.Empty));
                            sbCitySights.Append("</div>");
                            eachCity.Sights = sbCitySights.ToString();
                        }
                        else if (eachcityGuide.cityguideType == "entertainment")
                        {
                            StringBuilder sbCityFeatures = new StringBuilder("<div class=\"WorldGuide\">");
                            sbCityFeatures.Append(Regex.Replace(eachcityGuide.cityguide.Split("<strong>")[0], "<.*?>", string.Empty));
                            sbCityFeatures.Append("</div>");
                            eachCity.Features = sbCityFeatures.ToString();
                        }
                        else if (eachcityGuide.cityguideType == "fun_facts")
                        {
                            stats = eachcityGuide.cityguide.Split("<strong>");
                            foreach (var param1 in stats)
                            {
                                //Console.WriteLine(par.ToString());
                                if (param1.Contains("State:") || param1.Contains("State/Province:"))
                                    eachCity.State = Regex.Replace(param1.Split(":")[1], "<.*?>", string.Empty);

                                if (param1.Contains("Country:"))
                                    eachCity.Country = Regex.Replace(param1.Split(":")[1], "<.*?>", string.Empty);

                                if (param1.Contains("By The Numbers"))
                                    foreach (var param2 in param1.Split("<br />"))
                                    {
                                        if (param2.Contains("Population:"))
                                            eachCity.Population = Regex.Replace(param2.Split(":")[1], "<.*?>", string.Empty);
                                        if (param2.Contains("Elevation:"))
                                            eachCity.Elevation = Regex.Replace(param2.Split(":")[1], "<.*?>", string.Empty);
                                    }
                            }
                            sb.AppendFormat("State|{0}|Country|{1}|Population|{2}|Elevation|{3}", eachCity.State, eachCity.Country, eachCity.Population, eachCity.Elevation);
                            eachCity.Stats = sb.ToString();
                            sb.Clear();
                        }
                    }
                    StringBuilder imgStringBuilder = new StringBuilder();
                    foreach (var imgFile in eachCity.ImageFileNames)
                    {
                        imgStringBuilder.AppendFormat("{0}|", imgFile);
                    }
                    eachCity.ImagesFileName = imgStringBuilder.ToString();
                    imgStringBuilder.Clear();

                    StringBuilder CaptiomStringBuilder = new StringBuilder();
                    foreach (var caption in eachCity.ImageCaptions)
                    {
                        CaptiomStringBuilder.AppendFormat("{0}|", caption);
                    }
                    eachCity.ImagesCaption = CaptiomStringBuilder.ToString();
                    CaptiomStringBuilder.Clear();

                    foreach (var row in _cityIDtoGeoRefIDs)
                    {
                        if (row.CityID == eachCity.CityId)
                        {
                            eachCity.GeoRefID = (int)row.GeoRefID;
                            break;
                        }

                    }

                }
            }
            catch (Exception ex)
            {
                throw new Exception("XML Parsing Failed", ex);
            }

            _WGDetailedFtInfo = _WGDetailedFtInfo.Where(city =>
                    _cityIDtoGeoRefIDs.Any(y => y.CityID == Convert.ToInt32(city.CityId)))
                    .ToList();
            return _WGDetailedFtInfo;
        }

        public List<WGCityFlightInfoDTO> importWGCityFtInfoFromXML(string xmlDocFlightPoi, List<PoiIDtoGeoRefID> _poiIDtoGeoRefs, List<CityIDtoGeoRefID> _cityIDtoGeoRefIDs)
        {
            List<WGCityFlightInfoDTO> _WGCityFtInfo = new List<WGCityFlightInfoDTO>();
            string[] expectedLangs = { "en", "de", "es", "fr", "it", "zh", "zh-tw", "ja", "ko", "pt", "ru", "tr", "ar" };
            try
            {
                XDocument xmlDocFtPoi = XDocument.Parse(File.ReadAllText(xmlDocFlightPoi, System.Text.Encoding.UTF8));

                _WGCityFtInfo = (
                    from ftpoi in xmlDocFtPoi.Element("records").Elements("record")
                    select new WGCityFlightInfoDTO
                    {
                        PoiID = (string)ftpoi.Elements("details").First().Element("id"),
                        CityID = (string)ftpoi.Elements("details").First().Element("city_id"),
                        Imagefilename = (string)ftpoi.Elements("details").First().Element("image"),
                        Captions = ftpoi.Elements("details").First().Descendants("caption").Select(h => h.Value).ToArray(),
                        CaptionLanguages = ftpoi.Elements("details").First().Descendants("caption").Attributes("lang").Select(h => h.Value).ToArray()
                    }
                    ).ToList();

            }
            catch (Exception ex)
            {
                throw new Exception("XML Parsing Failed", ex);
            }


            //Consider the city which has all the languages
            _WGCityFtInfo = _WGCityFtInfo.Where(city => (city.CaptionLanguages.Count() == expectedLangs.Count())).ToList();



            foreach (var _ftPoiCity in _WGCityFtInfo)
            {
                StringBuilder CaptionLanguageStringBuilder = new StringBuilder();
                foreach (var CaptionLanguage in _ftPoiCity.CaptionLanguages)
                {
                    CaptionLanguageStringBuilder.AppendFormat("{0}|", CaptionLanguage);
                }
                _ftPoiCity.CaptionLanguagesString = CaptionLanguageStringBuilder.ToString();
                CaptionLanguageStringBuilder.Clear();


                StringBuilder CaptionStringBuilder = new StringBuilder();
                foreach (var caption in _ftPoiCity.Captions)
                {
                    CaptionStringBuilder.AppendFormat("{0}|", caption);
                }
                _ftPoiCity.CaptionsString = CaptionStringBuilder.ToString();
                CaptionStringBuilder.Clear();


                foreach (var row in _poiIDtoGeoRefs)
                {
                    if (Convert.ToInt32(_ftPoiCity.PoiID) == row.PoiID)
                    {
                        _ftPoiCity.geoRefID = row.GeoRefID;
                        break;
                    }
                    else
                    {
                        foreach (var row2 in _cityIDtoGeoRefIDs)
                        {
                            if (Convert.ToInt32(_ftPoiCity.CityID) == row2.CityID)
                            {
                                _ftPoiCity.geoRefID = (int)row2.GeoRefID;
                                break;
                            }
                        }
                    }
                }
            }

            _WGCityFtInfo = _WGCityFtInfo.Where(city => city.geoRefID > 0).ToList();

            return _WGCityFtInfo;
        }
        public async Task<DataCreationResultDTO> CopytoTempWGCityFlightInfo(List<WGCityFlightInfoDTO> wGCityFtInfo)
        {
            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);

            using (SqlConnection con = new SqlConnection(connectionString))
            {

                var copyParameters = new[]
                             {

                        nameof(WGCityFlightInfoDTO.Imagefilename),
                        nameof(WGCityFlightInfoDTO.CaptionsString),
                        nameof(WGCityFlightInfoDTO.CaptionLanguagesString),
                        nameof(WGCityFlightInfoDTO.geoRefID)


                    };
                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    sqlCopy.DestinationTableName = "dbo.tblTempWGCityFlightInfo";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();


                    sqlCopy.ColumnMappings.Add("Imagefilename", "ImageFileName");
                    sqlCopy.ColumnMappings.Add("CaptionsString", "Description");
                    sqlCopy.ColumnMappings.Add("CaptionLanguagesString", "Language");
                    sqlCopy.ColumnMappings.Add("geoRefID", "GeoRefID");
                    con.Open();

                    using (var reader = ObjectReader.Create(wGCityFtInfo, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);
                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }
            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }

        async Task<DataCreationResultDTO> CopytoTempWGDetailedFlightInfo(List<WGDetailedFlightInfoDTO> wGDetailedFtInfo)
        {

            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                var copyParameters = new[]
                             {
                        nameof(WGDetailedFlightInfoDTO.Overview),
                        nameof(WGDetailedFlightInfoDTO.GeoRefID),
                        nameof(WGDetailedFlightInfoDTO.Features),
                        nameof(WGDetailedFlightInfoDTO.Sights),
                        nameof(WGDetailedFlightInfoDTO.Stats),
                        nameof(WGDetailedFlightInfoDTO.ImagesFileName),
                        nameof(WGDetailedFlightInfoDTO.ImagesCaption)


                    };
                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    sqlCopy.DestinationTableName = "dbo.tblTempWGDetailedFlightInfo";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    sqlCopy.ColumnMappings.Add("Overview", "Overview");
                    sqlCopy.ColumnMappings.Add("GeoRefID", "GeoRefID");
                    sqlCopy.ColumnMappings.Add("Features", "Features");
                    sqlCopy.ColumnMappings.Add("Sights", "Sights");
                    sqlCopy.ColumnMappings.Add("Stats", "Stats");
                    sqlCopy.ColumnMappings.Add("ImagesFileName", "ImageFileName");
                    sqlCopy.ColumnMappings.Add("ImagesCaption", "Text_EN");
                    con.Open();

                    using (var reader = ObjectReader.Create(wGDetailedFtInfo, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);

                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }
                //return new DataCreationResultDTO { IsError = true, Message = "ImportedFile is Succesfull !" };
            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }

        /**
         * The lsit data from ImportLatestPopulationData fed here for the second level of formation
         * Will apply some filtering to sort the data 
         * Validation of the format happens here using csvHelper, violation of this will raise a excepthion
         * The complete formated data copied to a temp table in to the sql server using sqlbulkcopy for further actions
         * **/
        public async Task<int> UpdateCityPopulation(TaskEnvironment environment, Guid CurrentTaskID, int configurationId, string path, Guid CurrentUserID)
        {
            
            string csvFilePath = string.Empty;
            StringBuilder sbErrorLogs = new StringBuilder("UpdateCityPopulation:");

            string zipPath = path + ".zip";
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            ZipFile.ExtractToDirectory(zipPath, path);
            string[] filePaths = Directory.GetFiles(path, ".",
                                         SearchOption.AllDirectories);
            foreach (var f in filePaths)
            {
                if (f.Contains(".csv"))
                {
                    csvFilePath = f;
                }
            }

            List<UnCityPopulationDTO> uNDatalist = new List<UnCityPopulationDTO>();
            uNDatalist = ImportLatestPopulationData(csvFilePath);

            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;

            uNDatalist = uNDatalist
                            .Where(w => (w.Sex == "Both Sexes"))
                            .GroupBy(x => x.CityCode).Select(y => y.OrderByDescending(x => x.Year).FirstOrDefault()).ToList();

            if (!uNDatalist.Any())
            {
                sbErrorLogs.AppendFormat("{0};", "Pre-Processing of Airport.csv is not done successfully!. The Output list empty");
                return -1;
            }

            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                var copyParameters = new[]
                    {
                        nameof(UnCityPopulationDTO.Country),
                        nameof(UnCityPopulationDTO.Year),
                        nameof(UnCityPopulationDTO.Sex),
                        nameof(UnCityPopulationDTO.CityCode),
                        nameof(UnCityPopulationDTO.City),
                        nameof(UnCityPopulationDTO.CityType),
                        nameof(UnCityPopulationDTO.Population)

                    };

                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    sqlCopy.DestinationTableName = "dbo.tblTempCityPopulation";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    sqlCopy.ColumnMappings.Add("Country", "Country");
                    sqlCopy.ColumnMappings.Add("Year", "Year");
                    sqlCopy.ColumnMappings.Add("Sex", "Sex");
                    sqlCopy.ColumnMappings.Add("CityCode", "CityCode");
                    sqlCopy.ColumnMappings.Add("City", "City");
                    sqlCopy.ColumnMappings.Add("CityType", "CityType");
                    sqlCopy.ColumnMappings.Add("Population", "Population");
                    con.Open();
                    using (var reader = ObjectReader.Create(uNDatalist, copyParameters))
                    {
                        try
                        {
                            sqlCopy.WriteToServer(reader);
                        }
                        catch (Exception ex)
                        {
                            if (Directory.Exists(path)) Directory.Delete(path, true);


                            environment.Logger.LogError("ImportedFile format is not matching " + ex);
                            sbErrorLogs.AppendFormat("{0};", "ImportedFile format is not matching");
                            return -1;
                        }

                    }
                    con.Close();
                }

            }
            var result = await context.Repositories.ConfigurationRepository.UpdateCityPopulation(CurrentTaskID, configurationId, CurrentUserID);
            if (result > 0)
            {
                await context.SaveChanges();

                var config = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Build Modlist Json");
                BuildQueueItem item = new BuildQueueItem
                {
                    Debug = false,
                    Config = new BuildTask()
                };
                item.Config.ID = Guid.NewGuid();
                item.Config.ConfigurationDefinitionID = config.ConfigurationDefinitionId;
                item.Config.ConfigurationID = configurationId;
                item.Config.StartedByUserID = CurrentUserID;
                item.Config.TaskTypeID = taskType.ID;
                item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                item.Config.DateStarted = DateTime.Now;
                item.Config.DateLastUpdated = DateTime.Now;
                item.Config.PercentageComplete = 0f;

                await environment.UpdateDetailedStatus("Population data has been Imported");
                if (Directory.Exists(path)) Directory.Delete(path, true);
                return 0;
            }
            if (Directory.Exists(path)) Directory.Delete(path, true);
            sbErrorLogs.AppendFormat("{0};", "Exception in Stored Procedure");
            environment.CurrentTask.ErrorLog = sbErrorLogs.ToString();
            return -1;
        }
        /**
         * This is function does first level of  format the data from the source and copy to a list
         * When we download the data from source ,there will be unwanted comment lines at the bottom
         * Our point of interes is "Country or Area,Year,Sex,Code of City,City,City type"
         * In the process of formating, we did filter and capturing only the data which requiered, that way we can avoid the comment section
         * csv.GetField(3) is Code of City if it is not present  then the record wont be usefull to us so Skipping those bad records       
         **/
        public List<UnCityPopulationDTO> ImportLatestPopulationData(string _cvsfilepath)
        {
            const int cityCodePosition = 3;
            UnCityPopulationDTO uNData = new UnCityPopulationDTO();
            List<UnCityPopulationDTO> uNDatas = new List<UnCityPopulationDTO>();
            var config = new CsvConfiguration(CultureInfo.InvariantCulture)
            {
                MissingFieldFound = null,
                BadDataFound = null
            };
            using (TextReader reader = File.OpenText(_cvsfilepath))
            {
                var csv = new CsvReader(reader, config);

                csv.Context.RegisterClassMap<UnCityPopulationDTOMap>();

                while (csv.Read())
                {
                    bool isBadRecord = string.IsNullOrWhiteSpace(csv.GetField(cityCodePosition));

                    if (!isBadRecord)
                    {
                        uNData = csv.GetRecord<UnCityPopulationDTO>();
                        uNDatas.Add(uNData);
                    }
                }
            }
            return uNDatas;
        }

        //infospelling
        public async Task<int> UpdateInfoSpelling(TaskEnvironment environment, Guid CurrentTaskID, int configurationId, string path, Guid CurrentUserID)
        {
            try
            {
                string csvFilePath = string.Empty;
                StringBuilder sbErrorLogs = new StringBuilder("UpdateInfoSpelling:");

                string zipPath = path + ".zip";
                if (!Directory.Exists(path))
                    Directory.CreateDirectory(path);
                ZipFile.ExtractToDirectory(zipPath, path);
                string[] filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                foreach (var f in filePaths)
                {
                    if (f.Contains(".csv"))
                    {
                        csvFilePath = f;
                    }
                }
                string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
                List<InfoSpellingCSVDTO> infoDataList2 = new List<InfoSpellingCSVDTO>();
                List<ScriptForcedLanguage> ScriptForcedLanguages = new List<ScriptForcedLanguage>();
                List<string> Header = new List<string>();
                Header.Add("InfoId");

                infoDataList2 = ImportLatestInfoSpellingData(csvFilePath, connectionString);
                var columnNames = infoDataList2.SelectMany(data => data.Columns.Keys).Distinct().ToList();
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                ScriptForcedLanguages = await context.Repositories.ConfigurationRepository.GetLanguageCode(columnNames);
                foreach (var ScriptForcedLanguage in ScriptForcedLanguages)
                {
                    var originalItem = columnNames.FirstOrDefault(x => x == ScriptForcedLanguage.LanguageName);
                    if (originalItem != null)
                    {
                        Console.WriteLine("Lang_"+ ScriptForcedLanguage.LanguageCode);
                        Header.Add("Lang_" + ScriptForcedLanguage.LanguageCode);
                    }

                }

                foreach (var item in infoDataList2)
                {
                    for (int i = 0; i < ScriptForcedLanguages.Count; i++)
                    {
                        for(int j = 0; j < item.Columns.Keys.Count; j++) {

                            if (item.Columns.Keys.ElementAt(j) == ScriptForcedLanguages[i].LanguageName)
                            {
                                if (item.Columns.Keys.ElementAt(j) != "InfoId")
                                {
                                    item.Columns.Add("Lang_" + ScriptForcedLanguages[i].LanguageCode, item.Columns[item.Columns.Keys.ElementAt(j)]);
                                    item.Columns.Remove(ScriptForcedLanguages[i].LanguageName);
                                }
                            }

                        }

                    }

                }

                Console.WriteLine(infoDataList2.Count);
                foreach(var item in infoDataList2)
                {
                    var keysToRemove = item.Columns.Keys.Except(Header).ToList();

                    foreach (string key in keysToRemove)
                    {
                        item.Columns.Remove(key);
                    }
                }

                CreateSqlTable("dbo.tblTempInfoSpelling", Header, connectionString);
                InsertCsvDataIntoSqlTable("dbo.tblTempInfoSpelling", infoDataList2, connectionString);

                
                var result = await context.Repositories.ConfigurationRepository.UpdateInfoSpelling(configurationId);
                if (result > 0)
                {
                    await context.SaveChanges();

                    var config = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                    var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Build Modlist Json");
                    BuildQueueItem item = new BuildQueueItem
                    {
                        Debug = false,
                        Config = new BuildTask()
                    };
                    item.Config.ID = Guid.NewGuid();
                    item.Config.ConfigurationDefinitionID = config.ConfigurationDefinitionId;
                    item.Config.ConfigurationID = configurationId;
                    item.Config.StartedByUserID = CurrentUserID;
                    item.Config.TaskTypeID = taskType.ID;
                    item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                    item.Config.DateStarted = DateTime.Now;
                    item.Config.DateLastUpdated = DateTime.Now;
                    item.Config.PercentageComplete = 0f;

                    await environment.UpdateDetailedStatus("InfoSpelling data has been Imported");
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return 0;
                }
                if (Directory.Exists(path)) Directory.Delete(path, true);
                sbErrorLogs.AppendFormat("{0};", "Exception in Stored Procedure");
                environment.CurrentTask.ErrorLog = sbErrorLogs.ToString();
                return -1;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        public static void CreateSqlTable(string tableName, List<string> columnNames, string connectionString)
        {
            using (var connection = new SqlConnection(connectionString))
            {
                var sql = $"CREATE TABLE {tableName} ({string.Join(", ", columnNames.Select(cn => $"{cn} VARCHAR(MAX)"))})";
                using (var command = new SqlCommand(sql, connection))
                {
                    connection.Open();
                    command.ExecuteNonQuery();
                }
            }
        }

        public static void InsertCsvDataIntoSqlTable(string tableName, List<InfoSpellingCSVDTO> csvData, string connectionString)
        {
            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                foreach (var row in csvData)
                {
                    var columnNames = row.Columns.Keys.ToList();
                    var columnValues = row.Columns.Values.Select(value => value.Replace("'", "''")).ToList();
                    var sql = $"INSERT INTO {tableName} ({string.Join(", ", columnNames)}) VALUES ('{string.Join("', '", columnValues)}')";

                    using (var command = new SqlCommand(sql, connection))
                    {
                        command.ExecuteNonQuery();
                    }
                }
            }
        }

        public List<InfoSpellingCSVDTO> ImportLatestInfoSpellingData(string _cvsfilepath,string con)
        {
            try
            {
               
                InfoSpellingDTO infoData = new InfoSpellingDTO();
                List<InfoSpellingDTO> infoDatas = new List<InfoSpellingDTO>();
                List<InfoSpellingCSVDTO> InfoSpellingCSVDTOs = new List<InfoSpellingCSVDTO>();
                var config = new CsvConfiguration(CultureInfo.InvariantCulture)
                {
                    MissingFieldFound = null,
                    BadDataFound = null,
                    HasHeaderRecord = true,
                    HeaderValidated = null,
                    Delimiter = ","
                    
                 };
                using var streamReader = new StreamReader(_cvsfilepath);
                using (var csvReader = new CsvReader(streamReader, config))
                {
                    // Read the header record
                   // var record1 = csvReader.GetRecords();
                   var records = csvReader.GetRecords<dynamic>();
                   return records.Select(record => new InfoSpellingCSVDTO
                    {
                        Columns = ((IDictionary<string, object>)record).ToDictionary(kv => kv.Key, kv => kv.Value.ToString())
                    }).ToList();

                }
         
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        /**
        * The is Data Convertion function which will convert Data from DMS(Degree,Minutes and Seconds) to DD(Decimal Degree)
         * The Input string is divided in three parts Degrees, Minutes and Seconds each will get devided by its own multiplier.
         * */
        public static string ConvertDegreeAngleToDouble(string point)
        {
            const int minutes_factor = 60;
            const int seconds_factor = 3600;

            var multiplier = (point.Contains("S") || point.Contains("W")) ? -1 : 1; //handle south and west
            bool isLat = (point.Contains("S") || point.Contains("N")) ? true : false; //handle lat and Long

            point = Regex.Replace(point, "[^0-9.]", ""); //remove the characters


            //Decimal degrees = 
            //   whole number of degrees, 
            //   plus minutes divided by 60, 
            //   plus seconds divided by 3600
            var degrees = isLat ? double.Parse(point.Substring(0, 2)) : double.Parse(point.Substring(0, 3));
            var minutes = isLat ? double.Parse(point.Substring(2, 2)) / minutes_factor : double.Parse(point.Substring(3, 2)) / minutes_factor;
            var seconds = isLat ? double.Parse(point.Substring(4, 2)) / seconds_factor : double.Parse(point.Substring(5, 2)) / seconds_factor;

            var pointDecimal = (degrees + minutes + seconds) * multiplier;

            return ((decimal)pointDecimal).ToString(); ;
        }
        /**
          * The Function will extract the Data from the Navigational Database DataSource(WORLD_DOCS.db)
          * */
        public List<NavDBAirportsDTO> getNavDBAirports(TaskEnvironment environment, string DB_name)
        {
            List<NavDBAirportsDTO> navdbAllAirports = new List<NavDBAirportsDTO>();
            try
            {

                SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
                builder.DataSource = DB_name;
                builder.TypeSystemVersion = "version 3";

                using var scon = new SQLiteConnection(builder.ConnectionString);
                scon.Open();
                using (var command = scon.CreateCommand())
                {

                    command.CommandText = "SELECT A.ID as FourLetId, " +
                                            "A.[Recommended Navaid] as ThreeLetId, " +
                                            "A.Latitude as Lat, " +
                                            "A.Longitude as Long, " +
                                            "A.Name as Description, " +
                                            "A.Name as City, " +
                                            "A.Ref as SN " +
                                            "FROM Airports as A, " +
                                            "(select min(rowid) as RD from Airports group by Ref ) as UNQ " +
                                            "WHERE A.rowid = UNQ.RD";
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            NavDBAirportsDTO navdbAirport = new NavDBAirportsDTO();
                            navdbAirport.FourLetId = reader.GetString(0);
                            navdbAirport.ThreeLetId = reader.GetString(1);
                            navdbAirport.Lat = reader.GetString(2);
                            navdbAirport.Long = reader.GetString(3);
                            navdbAirport.Description = reader.GetString(4).ToLower().Trim();
                            navdbAirport.City = reader.GetString(5).ToLower().Trim();
                            navdbAirport.SN = reader.GetInt32(6);

                            navdbAllAirports.Add(navdbAirport);
                        }
                    }

                }
                scon.Close();
            }
            catch (Exception ex)
            {
                environment.Logger.LogError("NavDB format is not correct: " + ex);

            }
            return navdbAllAirports;

        }
       
         
        

        /**
         * This is functionis used to get all the airports from the data source https://ourairports.com/data/   
        **/
        public List<AllAirportsDTO> getAllAirports(string _cvsfilepath)
        {

            List<AllAirportsDTO> AirportRecords = new List<AllAirportsDTO>();
            var config = new CsvConfiguration(CultureInfo.InvariantCulture)
            {
                MissingFieldFound = null,
                BadDataFound = null

            };
            using (TextReader reader = File.OpenText(_cvsfilepath))
            {
                var csv = new CsvReader(reader, config);

                csv.Context.RegisterClassMap<AllAirportsDTOMap>();

                while (csv.Read())
                {

                    AllAirportsDTO AirportRecord = csv.GetRecord<AllAirportsDTO>();
                    AirportRecords.Add(AirportRecord);

                }
            }
            return AirportRecords;
        }

        /**
          * The Function will extract the Data from the Data Sources and fill it to the tables
          * dbo.tblGeoRef, dbo.tblCoverageSegment, dbo.tblSpelling, dbo.tblAppearance and dbo.tblAirportInfo and their corresponding Maping tables
          * */
        public async Task<int> AddNewAirpots(TaskEnvironment environment, Guid CurrentTaskID, int configurationId, string path, Guid CurrentUserID)
        {
            string zipPath = path + ".zip";

            StringBuilder sbErrorLog = new StringBuilder("AddNewAirports:");
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            ZipFile.ExtractToDirectory(zipPath, path);
            string[] filePaths = Directory.GetFiles(path, ".",
                                         SearchOption.AllDirectories);
            string airportCsvFilePath = string.Empty;
            string DB_name = string.Empty;
            foreach (var f in filePaths)
            {
                if (f.Contains("airports.csv"))
                {
                    airportCsvFilePath = f;
                }
                if (f.Contains("WORLD_DOCS.db"))
                {
                    DB_name = f;
                }
            }

            TextInfo ti = CultureInfo.CurrentCulture.TextInfo;
            List<AllAirportsDTO> allAirportslist = getAllAirports(airportCsvFilePath);
            List<NavDBAirportsDTO> navDBAirports = getNavDBAirports(environment, DB_name);
            if (!allAirportslist.Any() || !navDBAirports.Any())
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                sbErrorLog.AppendFormat("{0};", "Input lists are Empty, One of the Req File might be Missing !");
                return -1;
            }
            else
            {
                try
                {

                    foreach (var airportrow in allAirportslist)
                    {
                        foreach (var navDBrow in navDBAirports)
                        {
                            if (((navDBrow.FourLetId == airportrow.Ident) || (navDBrow.FourLetId == airportrow.IataCode)
                                || (navDBrow.FourLetId == airportrow.LocalCode)) && !string.IsNullOrWhiteSpace(airportrow.Municipality))
                            {
                                if (airportrow.Type == "small_airport")
                                {
                                    navDBrow.City = airportrow.Municipality.Split("/").FirstOrDefault().Trim();
                                }
                                else
                                {
                                    navDBrow.City = airportrow.Municipality.Split("/").LastOrDefault().Trim();
                                }

                            }

                        }

                    }
                    foreach (var navDBrow in navDBAirports)
                    {
                        navDBrow.Lat = ConvertDegreeAngleToDouble(navDBrow.Lat);
                        navDBrow.Long = ConvertDegreeAngleToDouble(navDBrow.Long);
                        navDBrow.City = ti.ToTitleCase(navDBrow.City);
                        navDBrow.Description = navDBrow.City + " -AIRPORT CITY";
                    }
                }
                catch (Exception ex)
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    environment.Logger.LogError("Not able to format the input files: " + ex);
                    sbErrorLog.AppendFormat("{0};", "Not able to format the input files");
                    return -1;
                }
            }
            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                var copyParameters = new[]
                             {
                        nameof(NavDBAirportsDTO.FourLetId),
                        nameof(NavDBAirportsDTO.ThreeLetId),
                        nameof(NavDBAirportsDTO.Lat),
                        nameof(NavDBAirportsDTO.Long),
                        nameof(NavDBAirportsDTO.Description),
                        nameof(NavDBAirportsDTO.City),
                        nameof(NavDBAirportsDTO.SN),
                        nameof(NavDBAirportsDTO.existingGeorefId)

                    };
                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    sqlCopy.DestinationTableName = "dbo.tblNavdbAirports";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    sqlCopy.ColumnMappings.Add("FourLetId", "FourLetId");
                    sqlCopy.ColumnMappings.Add("ThreeLetId", "ThreeLetId");
                    sqlCopy.ColumnMappings.Add("Lat", "Lat");
                    sqlCopy.ColumnMappings.Add("Long", "Long");
                    sqlCopy.ColumnMappings.Add("Description", "Description");
                    sqlCopy.ColumnMappings.Add("City", "City");
                    sqlCopy.ColumnMappings.Add("SN", "SN");
                    sqlCopy.ColumnMappings.Add("existingGeorefId", "existingGeorefId");
                    con.Open();
                    using (var reader = ObjectReader.Create(navDBAirports, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            environment.Logger.LogError("Writting to server failed: " + ex);
                            if (Directory.Exists(path)) Directory.Delete(path, true);
                            sbErrorLog.AppendFormat("{0};", "Writting to server failed");
                            return -1;

                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }

            }
            // get database access and a writer to the file and configure the batch output
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
            var result = await context.Repositories.ConfigurationRepository.AddNewAirportfromNavDB(CurrentTaskID, configurationId, CurrentUserID);
            if (result > 0)
            {

                var config = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Build Modlist Json");
                BuildQueueItem item = new BuildQueueItem
                {
                    Debug = false,
                    Config = new BuildTask()
                };
                item.Config.ID = Guid.NewGuid();
                item.Config.ConfigurationDefinitionID = config.ConfigurationDefinitionId;
                item.Config.ConfigurationID = configurationId;
                item.Config.StartedByUserID = CurrentUserID;
                item.Config.TaskTypeID = taskType.ID;
                item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                item.Config.DateStarted = DateTime.Now;
                item.Config.DateLastUpdated = DateTime.Now;
                item.Config.PercentageComplete = 0f;

                await context.SaveChanges();
                if (Directory.Exists(path)) Directory.Delete(path, true);
                return 0;
            }
            sbErrorLog.AppendFormat("{0};", "Exception in Stored Procedure");
            environment.CurrentTask.ErrorLog = sbErrorLog.ToString();
            if (Directory.Exists(path)) Directory.Delete(path, true);
            return -1;
        }
        public async Task<int> InsertUpdateFonts(TaskEnvironment environment, Guid CurrentTaskID, int configurationId, string path, Guid CurrentUserID)
        {
            string csvFilePath = path;
            string tbfont = "";
            string tbfontcategory = "";
            string tbfontfamily = "";
            string tbfontmarker = "";
            string fontTTFName = string.Empty;
            bool istbfont = false;
            bool istbfontcategory = false;
            bool istbfontfamily = false;
            bool istbFontMarker = false;
            bool isFontTTF = false;
            StringBuilder sbErrorLogs = new StringBuilder("Import Fonts");

            string zipPath = path + ".zip";
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            ZipFile.ExtractToDirectory(zipPath, path);
            string[] filePaths = Directory.GetFiles(path, ".",
                                         SearchOption.AllDirectories);
            foreach (var f in filePaths)
            {
                if (f.ToLower().Contains("tbfont.csv"))
                {
                    tbfont = f;
                    istbfont = true;
                }
                if (f.ToLower().Contains("tbfontcategory.csv"))
                {
                    tbfontcategory = f;
                    istbfontcategory = true;
                }
                if (f.ToLower().Contains("tbfontfamily.csv"))
                {
                    tbfontfamily = f;
                    istbfontfamily = true;
                }
                if (f.ToLower().Contains("tbfontmarker.csv"))
                {
                    tbfontmarker = f;
                    istbFontMarker = true;
                }
                if (f.ToLower().Contains(".ttf"))
                {
                    fontTTFName = f;
                    isFontTTF = true;
                }

            }
            if (istbfont)
            {
                List<FontsDTO> fontsList = getfontList(tbfont);
                await CopytoTempFonts(fontsList);
            }
            if(istbfontcategory)
            {
                List<FontCategoryDTO> fontCategoryList = getfontCategoryList(tbfontcategory);
                await CopytoTempFontsCategory(fontCategoryList);
            }
            if(istbfontfamily)
            {
                List<FontFamilyDTO> fontFamilyList = GetFontFamilyList(tbfontfamily);
                await CopytoTempFontsFamily(fontFamilyList);
            }
            if (istbFontMarker)
            {
                List<FontMarkerDTO> fontMarkerList = GetFontMarkerList(tbfontmarker);
                await CopytoTempFontsMarker(fontMarkerList);
            }
            if (isFontTTF)
            {
                await UploadToBlobStorage(environment, configurationId, CurrentUserID, zipPath, ConfigurationCustomComponentType.FontData.ToString(), GetDescriptionFromEnum(ConfigurationCustomComponentType.FontData));
            }
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
         
            var result = await context.Repositories.ConfigurationRepository.InsertUpdateFonts( configurationId);
            if (result > 0)
            {
                await context.SaveChanges();

                var config = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Build Modlist Json");
                BuildQueueItem item = new BuildQueueItem
                {
                    Debug = false,
                    Config = new BuildTask()
                };
                item.Config.ID = Guid.NewGuid();
                item.Config.ConfigurationDefinitionID = config.ConfigurationDefinitionId;
                item.Config.ConfigurationID = configurationId;
                item.Config.StartedByUserID = CurrentUserID;
                item.Config.TaskTypeID = taskType.ID;
                item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                item.Config.DateStarted = DateTime.Now;
                item.Config.DateLastUpdated = DateTime.Now;
                item.Config.PercentageComplete = 0f;

                await environment.UpdateDetailedStatus("fonts data has been Imported");
                if (Directory.Exists(path)) Directory.Delete(path, true);
                return 0;
            }
            if (Directory.Exists(path)) Directory.Delete(path, true);
            sbErrorLogs.AppendFormat("{0};", "Exception in Stored Procedure");
            environment.CurrentTask.ErrorLog = sbErrorLogs.ToString();
            return -1;
        }
        async Task<DataCreationResultDTO> CopytoTempFonts(List<FontsDTO> fonts)
        {

            //cities = cities.Select(x=>x.Population.ToString().Replace(",","")).ToList()
            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                var copyParameters = new[]
                    {
                        nameof(FontsDTO.FontId),
                        nameof(FontsDTO.FontFaceId),
                        nameof(FontsDTO.FontStyle),
                        nameof(FontsDTO.Size),
                        nameof(FontsDTO.Description),
                        nameof(FontsDTO.Color),
                         nameof(FontsDTO.ShadowColor)

                    };

                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    SqlCommand cmd = new SqlCommand("TRUNCATE TABLE tblTempFonts", con);
                    cmd.CommandType = CommandType.Text;
                    con.Open();
                    cmd.ExecuteNonQuery();
                    sqlCopy.DestinationTableName = "dbo.tblTempFonts";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();
                    sqlCopy.ColumnMappings.Add("FontId", "FontId");
                    sqlCopy.ColumnMappings.Add("FontFaceId", "FontFaceId");
                    sqlCopy.ColumnMappings.Add("FontStyle", "FontStyle");
                    sqlCopy.ColumnMappings.Add("Size", "Size");
                    sqlCopy.ColumnMappings.Add("Description", "Description");
                    sqlCopy.ColumnMappings.Add("Color", "Color");
                    sqlCopy.ColumnMappings.Add("ShadowColor", "ShadowColor");
                  
                    using (var reader = ObjectReader.Create(fonts, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);
                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }

            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }
        public List<FontsDTO> getfontList(string _cvsfilepath)
        {

            FontsDTO fonts = new FontsDTO();
            List<FontsDTO> fontsList = new List<FontsDTO>();
            var config = new CsvConfiguration(CultureInfo.InvariantCulture)
            {
                MissingFieldFound = null,
                BadDataFound = null

            };
            using (TextReader reader = File.OpenText(_cvsfilepath))
            {
                var csv = new CsvReader(reader, config);

                csv.Context.RegisterClassMap<FontsDTOMap>();

                while (csv.Read())
                {

                    fonts = csv.GetRecord<FontsDTO>();
                    fontsList.Add(fonts);

                }
            }
            return fontsList;
        }
        public List<FontCategoryDTO> getfontCategoryList(string _cvsfilepath)
        {
            try
            {
                FontCategoryDTO fontscategory = new FontCategoryDTO();
                List<FontCategoryDTO> fontsCategoryList = new List<FontCategoryDTO>();
                var config = new CsvConfiguration(CultureInfo.InvariantCulture)
                {
                    MissingFieldFound = null,
                    BadDataFound = null

                };
                using (TextReader reader = File.OpenText(_cvsfilepath))
                {
                    var csv = new CsvReader(reader, config);

                    csv.Context.RegisterClassMap<FontCategoryDTOMap>();

                    while (csv.Read())
                    {

                        fontscategory = csv.GetRecord<FontCategoryDTO>();
                        fontsCategoryList.Add(fontscategory);

                    }
                }
                return fontsCategoryList;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        async Task<DataCreationResultDTO> CopytoTempFontsCategory(List<FontCategoryDTO> fontsCategory)
        {

            //cities = cities.Select(x=>x.Population.ToString().Replace(",","")).ToList()
            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                var copyParameters = new[]
                    {
                        
                        nameof(FontCategoryDTO.FontID),
                        nameof(FontCategoryDTO.GeoRefIdCatTypeID),
                        nameof(FontCategoryDTO.IMarkerID),
                        nameof(FontCategoryDTO.MarkerID),
                        nameof(FontCategoryDTO.LanguageID),

                    };

                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    SqlCommand cmd = new SqlCommand("TRUNCATE TABLE tblTempFontsCategory", con);
                    cmd.CommandType = CommandType.Text;
                    con.Open();
                    cmd.ExecuteNonQuery();
                    sqlCopy.DestinationTableName = "dbo.tblTempFontsCategory";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    
                    sqlCopy.ColumnMappings.Add("FontID", "FontID");
                    sqlCopy.ColumnMappings.Add("GeoRefIdCatTypeID", "GeoRefIdCatTypeID");
                    sqlCopy.ColumnMappings.Add("IMarkerID", "IMarkerID");
                    sqlCopy.ColumnMappings.Add("MarkerID", "MarkerID");
                    sqlCopy.ColumnMappings.Add("LanguageID", "LanguageID");
                  
                    
                    using (var reader = ObjectReader.Create(fontsCategory, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);
                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }

            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }
        public List<FontFamilyDTO> GetFontFamilyList(string _cvsfilepath)
        {
            try
            {

                FontFamilyDTO fontFamily = new FontFamilyDTO();
                List<FontFamilyDTO> fontsFamilyList = new List<FontFamilyDTO>();
                var config = new CsvConfiguration(CultureInfo.InvariantCulture)
                {
                    MissingFieldFound = null,
                    BadDataFound = null

                };
                using (TextReader reader = File.OpenText(_cvsfilepath))
                {
                    var csv = new CsvReader(reader, config);

                    csv.Context.RegisterClassMap<FontFamilyDTOMap>();

                    while (csv.Read())
                    {

                        fontFamily = csv.GetRecord<FontFamilyDTO>();
                        fontsFamilyList.Add(fontFamily);

                    }
                }
                return fontsFamilyList;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        async Task<DataCreationResultDTO> CopytoTempFontsFamily(List<FontFamilyDTO> fontsFamily)
        {

            //cities = cities.Select(x=>x.Population.ToString().Replace(",","")).ToList()
            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                var copyParameters = new[]
                    {
                        nameof(FontFamilyDTO.FontFaceID),
                        nameof(FontFamilyDTO.FileName),
                        nameof(FontFamilyDTO.FaceName),
                    };

                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    SqlCommand cmd = new SqlCommand("TRUNCATE TABLE tblTempFontsFamily", con);
                    cmd.CommandType = CommandType.Text;
                    con.Open();
                    cmd.ExecuteNonQuery();
                    sqlCopy.DestinationTableName = "dbo.tblTempFontsFamily";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    sqlCopy.ColumnMappings.Add("FontFaceID", "FontFaceID");
                    sqlCopy.ColumnMappings.Add("FileName", "FileName");
                    sqlCopy.ColumnMappings.Add("FaceName", "FaceName");
                    
                
                    using (var reader = ObjectReader.Create(fontsFamily, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);
                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }

            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }

        public List<FontMarkerDTO> GetFontMarkerList(string _cvsfilepath)
        {
            try
            {
                FontMarkerDTO fontMarker = new FontMarkerDTO();
                List<FontMarkerDTO> fontMarkerList = new List<FontMarkerDTO>();
                var config = new CsvConfiguration(CultureInfo.InvariantCulture)
                {
                    MissingFieldFound = null,
                    BadDataFound = null

                };
                using (TextReader reader = File.OpenText(_cvsfilepath))
                {
                    var csv = new CsvReader(reader, config);

                    csv.Context.RegisterClassMap<FontMarkerDTOMap>();

                    while (csv.Read())
                    {

                        fontMarker = csv.GetRecord<FontMarkerDTO>();
                        fontMarkerList.Add(fontMarker);

                    }
                }
                return fontMarkerList;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        async Task<DataCreationResultDTO> CopytoTempFontsMarker(List<FontMarkerDTO> fontsMarker)
        {

            //cities = cities.Select(x=>x.Population.ToString().Replace(",","")).ToList()
            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                var copyParameters = new[]
                    {
                        
                        nameof(FontMarkerDTO.MarkerID),
                        nameof(FontMarkerDTO.Filename),
                        
                    };

                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    SqlCommand cmd = new SqlCommand("TRUNCATE TABLE tblTempFontsMarker", con);
                    cmd.CommandType = CommandType.Text;
                    con.Open();
                    cmd.ExecuteNonQuery();
                    sqlCopy.DestinationTableName = "dbo.tblTempFontsMarker";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    sqlCopy.ColumnMappings.Add("MarkerID", "MarkerID");
                    sqlCopy.ColumnMappings.Add("Filename", "Filename");


                
                    using (var reader = ObjectReader.Create(fontsMarker, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);
                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }

            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }
        /// <summary>
        /// Step 1 : Locks,merge and branch the current config and generates build
        /// Step 2 : Create task for queuing to lock child configuration (immediate children)
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="currentTask"></param>
        /// <returns></returns>
        public async Task<int> MergAndLockCofiguration(TaskEnvironment environment, BuildTask currentTask)
        {
            var uOfWork = environment.NewUnitOfWork();
            StringBuilder sbErrorLog = new StringBuilder("MergAndLockCofiguration:");
            try
            {
                await environment.UpdateDetailedStatus("Starting MergAndLockCofiguration for : " + currentTask.ConfigurationID);

                //parent config lock,merge,branch
                using var context = uOfWork.Create;
                var lockComments = currentTask.TaskDataJSON;
                //Lock and merge the given configuration before processing the child configuration.
                await context.Repositories.ConfigurationRepository.LockCurrentConfiguration(currentTask.ConfigurationID, lockComments,
                    currentTask.StartedByUserID.ToString(), currentTask.ID.ToString());
                var lstChildConfigIds = await context.Repositories.ConfigurationRepository.GetChildConfigIds(currentTask.ConfigurationID);
                await environment.UpdateDetailedStatus("Child count for : " + currentTask.ConfigurationID + " is " + lstChildConfigIds.Count);

                foreach (var id in lstChildConfigIds)
                {
                    var config = await context.Repositories.Simple<backend.DataLayer.Models.Configuration.Configuration>().FirstAsync("ConfigurationID", id);
                    var definition = await context.Repositories.Simple<ConfigurationDefinition>().FirstAsync("ConfigurationDefinitionID", config.ConfigurationDefinitionId);
                    if (definition.AutoMerge == 1)
                    {
                        await environment.UpdateDetailedStatus("Merge config from : " + currentTask.ConfigurationID + " to " + id);
                        await context.Repositories.ConfigurationRepository.MergeCurrentConfiguration(currentTask.ConfigurationID, id, currentTask.ID.ToString(), currentTask.StartedByUserID.ToString());
                        await context.Repositories.MergeConfigurationRepository.SetConfigUpdatedVersion(currentTask.ConfigurationID, config.ConfigurationDefinitionId);
                    }
                }

                await environment.UpdateDetailedStatus("Started BranchConfiguration : " + currentTask.ConfigurationID);

                await context.Repositories.ConfigurationRepository.BranchConfiguration(currentTask.ConfigurationID, currentTask.StartedByUserID);
                await context.SaveChanges();
                await environment.UpdateDetailedStatus("Lock Configuration is completed for " + currentTask.ConfigurationID);

                await environment.UpdateDetailedStatus("Started DownloadDatabaseData : " + currentTask.ConfigurationID);

                await DownloadDatabaseData(environment, currentTask.ConfigurationID, currentTask.StartedByUserID);
                //create report with changes done in this version by comparing it with previous version
                await environment.UpdateDetailedStatus("Started GenerateVersionUpdateReport : " + currentTask.ConfigurationID);

                await GenerateVersionUpdateReport(environment, currentTask.ConfigurationID, currentTask.StartedByUserID);

                lstChildConfigIds.Remove(currentTask.ConfigurationID);

                using var Newcontext = uOfWork.Create;

                string taskType = "QueuedForLockCofiguration";
                var taskTypeRecord = await Newcontext.Repositories.Simple<TaskType>().FirstAsync("Name", taskType);

                foreach (var id in lstChildConfigIds)
                {

                    var config = await Newcontext.Repositories.Simple<backend.DataLayer.Models.Configuration.Configuration>().FirstAsync("ConfigurationID", id);
                    var childDef =
                        await context.Repositories.Simple<ConfigurationDefinition>().FirstAsync("ConfigurationDefinitionID", config.ConfigurationDefinitionId);
                    if (childDef.AutoLock == 1)
                    {
                        BuildQueueItem item = new BuildQueueItem
                        {
                            Debug = false,
                            Config = new BuildTask()
                        };
                        item.Config.ID = Guid.NewGuid();
                        item.Config.ConfigurationDefinitionID = config.ConfigurationDefinitionId;
                        item.Config.ConfigurationID = id;
                        item.Config.StartedByUserID = currentTask.StartedByUserID;
                        item.Config.TaskTypeID = taskTypeRecord.ID;
                        item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                        item.Config.DateStarted = DateTime.Now;
                        item.Config.DateLastUpdated = DateTime.Now;
                        item.Config.PercentageComplete = 0f;
                        item.Config.TaskDataJSON = lockComments;

                        // look for an associated aircraft id
                        var aircraftConfiguration = await Newcontext.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("ConfigurationDefinitionID", config.ConfigurationDefinitionId);
                        if (aircraftConfiguration != null)
                            item.Config.AircraftID = aircraftConfiguration.AircraftID;
                        await Newcontext.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
                    }
                }
                await Newcontext.SaveChanges();
                return 0;
            }
            catch (Exception ex)
            {
                sbErrorLog.AppendFormat("{0};", "Lock Configuration is not completed");
                environment.CurrentTask.ErrorLog = sbErrorLog.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                return -1;
            }
        }

        //We are distinguishing placenames data based on the filename.
        //Its is mandatory to follow the naming convention to import the placenames
        public async Task<int> AddNewPlaceNames(TaskEnvironment environment, Guid CurrentTaskID, int configurationId, string path, Guid CurrentUserID)
        {

            StringBuilder sbErrorLog = new StringBuilder("AddNewPlacNames:");
            bool isUSPlacenamesSource = false;
            string zipPath = path + ".zip";
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);
            ZipFile.ExtractToDirectory(zipPath, path);
            string[] filePaths = Directory.GetFiles(path, ".",
                                         SearchOption.AllDirectories);

            string USNationalFile_SourceFile = "";
            string GlobalPlaceNamesSourceFile = "";
            string CountrySpecficCityList_SourceFile = "";
            foreach (var f in filePaths)
            {
                if (f.ToLower().Contains("usnationalfile.txt"))
                {
                    USNationalFile_SourceFile = f;
                    isUSPlacenamesSource = true;
                }
                if (f.ToLower().Contains("internationalfile.txt"))
                {
                    GlobalPlaceNamesSourceFile = f;
                    isUSPlacenamesSource = false;
                }
                if (f.ToLower().Contains(".csv"))
                {
                    CountrySpecficCityList_SourceFile = f;
                }

            }
            //string CountrySpecficCityList_SourceFile = "C:/project_files/DB_activities/DataSources/ListofUSCities.csv";
            //string USNationalFile_SourceFile = "C:/project_files/DB_activities/DataSources/Countries_administrative_a.txt";


            try
            {
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                if (isUSPlacenamesSource)
                {
                    var sourceFile = File.ReadAllLines(USNationalFile_SourceFile);
                    var sourceList = new List<string>(sourceFile);

                    var NationalFileDataDTOList = (from item in sourceList.Skip(1)
                                                   let splitItem = item.Split('|', StringSplitOptions.RemoveEmptyEntries)
                                                   select new NationalFileDataDTO
                                                   {
                                                       CityName = splitItem[1],
                                                       Lat = splitItem[9],
                                                       Long = splitItem[10],
                                                   }).ToList();
                    await CopytoTempPlacNamesNationalFile(NationalFileDataDTOList);
                }
                else
                {
                    var sourceFile = File.ReadAllLines(GlobalPlaceNamesSourceFile);
                    var sourceList = new List<string>(sourceFile);

                    var GlobalPlaceNamesDataDTOList = (from item in sourceList.Skip(1)
                                                       let splitItem = item.Split('\t', StringSplitOptions.RemoveEmptyEntries)
                                                       select new GlobalPlaceNamesDataDTO
                                                       {
                                                           CityName = splitItem[19],
                                                           Lat = splitItem[3],
                                                           Long = splitItem[4],
                                                           BGNFilter = splitItem[13]
                                                       }).ToList();
                    await CopytoTempPlacNamesNationalFile(GlobalPlaceNamesDataDTOList);
                }



                List<CityDTO> CityList = getCityList(CountrySpecficCityList_SourceFile);
                await CopytoTempCityInfo(CityList);

                var result = await context.Repositories.ConfigurationRepository.AddNewPlaceNames(CurrentTaskID, configurationId, CurrentUserID, isUSPlacenamesSource);
                if (result > 0)
                {
                    await context.SaveChanges();
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return 0;
                }
                sbErrorLog.AppendFormat("{0};", "Exception in Stored Procedure");
                environment.CurrentTask.ErrorLog = sbErrorLog.ToString();
                if (Directory.Exists(path)) Directory.Delete(path, true);
                return -1;

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.StackTrace);
                return -1;
            }
        }
        async Task<DataCreationResultDTO> CopytoTempPlacNamesNationalFile(List<NationalFileDataDTO> placeNames)
        {

            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                var copyParameters = new[]
                             {
                        nameof(NationalFileDataDTO.CityName),
                        nameof(NationalFileDataDTO.Lat),
                        nameof(NationalFileDataDTO.Long)
                    };
                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    sqlCopy.DestinationTableName = "dbo.tblTempPlacNamesNationalFile";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    sqlCopy.ColumnMappings.Add("CityName", "CityName");
                    sqlCopy.ColumnMappings.Add("Lat", "Lat");
                    sqlCopy.ColumnMappings.Add("Long", "Long");
                    con.Open();

                    using (var reader = ObjectReader.Create(placeNames, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);

                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }
            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }

        async Task<DataCreationResultDTO> CopytoTempPlacNamesNationalFile(List<GlobalPlaceNamesDataDTO> placeNames)
        {

            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                var copyParameters = new[]
                             {
                        nameof(GlobalPlaceNamesDataDTO.CityName),
                        nameof(GlobalPlaceNamesDataDTO.Lat),
                        nameof(GlobalPlaceNamesDataDTO.Long),
                        nameof(GlobalPlaceNamesDataDTO.BGNFilter)
                    };
                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    sqlCopy.DestinationTableName = "dbo.tblTempPlacNamesNationalFile";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    sqlCopy.ColumnMappings.Add("CityName", "CityName");
                    sqlCopy.ColumnMappings.Add("Lat", "Lat");
                    sqlCopy.ColumnMappings.Add("Long", "Long");
                    sqlCopy.ColumnMappings.Add("BGNFilter", "BGNFilter");
                    con.Open();

                    using (var reader = ObjectReader.Create(placeNames, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);

                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }
            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }
        async Task<DataCreationResultDTO> CopytoTempCityInfo(List<CityDTO> cities)
        {

            //cities = cities.Select(x=>x.Population.ToString().Replace(",","")).ToList()
            string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                var copyParameters = new[]
                             {
                        nameof(CityDTO.City),
                        nameof(CityDTO.Population)
                    };
                using (var sqlCopy = new SqlBulkCopy(con))
                {
                    sqlCopy.DestinationTableName = "dbo.tblTempCityInfo";
                    sqlCopy.BatchSize = 500;
                    sqlCopy.ColumnMappings.Clear();

                    sqlCopy.ColumnMappings.Add("City", "City");
                    sqlCopy.ColumnMappings.Add("Population", "Population");
                    con.Open();

                    using (var reader = ObjectReader.Create(cities, copyParameters))
                    {
                        try
                        {
                            await sqlCopy.WriteToServerAsync(reader);
                        }
                        catch (Exception ex)
                        {
                            throw new Exception("SqlBulkCopy Failed", ex);

                        }
                        finally
                        {
                            reader.Close();
                        }

                    }
                    con.Close();
                }
            }
            return new DataCreationResultDTO { IsError = false, Message = "ImportedFile is Succesfull !" };
        }
        public List<CityDTO> getCityList(string _cvsfilepath)
        {

            CityDTO City = new CityDTO();
            List<CityDTO> CityList = new List<CityDTO>();
            var config = new CsvConfiguration(CultureInfo.InvariantCulture)
            {
                MissingFieldFound = null,
                BadDataFound = null

            };
            using (TextReader reader = File.OpenText(_cvsfilepath))
            {
                var csv = new CsvReader(reader, config);

                csv.Context.RegisterClassMap<CityDTOMap>();

                while (csv.Read())
                {

                    City = csv.GetRecord<CityDTO>();
                    CityList.Add(City);

                }
            }
            return CityList.Select(city =>
            {
                int population = int.Parse(city.Population, NumberStyles.Any);
                city.Population = population.ToString();
                return city;
            }).ToList();
        }

        public async Task<ActionResult> DownloadDatabaseData(TaskEnvironment environment, int configurationId, Guid userId)
        {
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;


            // assumes that only a single in-progress or successful export is present. failed ones are ignored
            // if this assumption changes for some reason then we will need to adjust the logic here accordingly
            var tasks = await context.Repositories.BuildTaskRepository.GetProductExports(configurationId);

            // more than one export present ... whoops, return an error
            if (tasks.Count > 1)
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "internal error: multiple exports present" });

            // only one record, check if its finished, if not return its id
            else if (tasks.Count == 1)
            {

                if (tasks[0].TaskStatusID == (int)DataLayer.Models.Task.TaskStatus.Succeeded)
                {
                    var blobConnectionString = environment.GetAzureConfigurationItem("AzureExportBlobStorage");
                    var blobContainerName = environment.GetAzureConfigurationItem("AzureExportBlobStorageContainer");
                    var blobName = $"{tasks[0].ID}.zip";
                    var blobStream = await AzureFileHelper.OpenBlobStream(
                        blobConnectionString,
                        blobContainerName,
                        blobName);
                    return new FileStreamResult(blobStream, "application/zip");
                }

                return new OkObjectResult(new DataCreationResultDTO { IsError = false, Id = tasks[0].ID });
            }


            var config = await context.Repositories.Simple<backend.DataLayer.Models.Configuration.Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (config == null)
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "invalid configuration" });

            var definition = await context.Repositories.Simple<ConfigurationDefinition>().FirstAsync("ConfigurationDefinitionID", config.ConfigurationDefinitionId);
            if (definition == null)
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "invalid configuration definition" });

            var outputType = await context.Repositories.Simple<OutputType>().FirstAsync("OutputTypeID", definition.OutputTypeID);
            if (outputType == null)
            {
                await environment.UpdateDetailedStatus("Output type id "+ definition.OutputTypeID+ " and Output Type is NULL");

                return new OkObjectResult(new DataCreationResultDTO()
                {
                    IsError = false,
                    Message = "invalid configuration definition"
                });
            }
            OutputTypeEnum outputTypeEnum = (OutputTypeEnum)Enum.Parse(typeof(OutputTypeEnum), outputType.OutputTypeName, true);

            await environment.UpdateDetailedStatus("Output Type : " + outputTypeEnum.ToString());

            string taskType = null;
            switch (outputTypeEnum)
            {
                case OutputTypeEnum.AS4XXX:
                    taskType = "Export Product Database - AS4XXX";
                    break;
                case OutputTypeEnum.CES:
                    taskType = "Export Product Database - CESHTSE";
                    break;
                case OutputTypeEnum.Thales2D:
                    taskType = "Export Product Database - Thales";
                    break;
                case OutputTypeEnum.PAC3D:
                    taskType = "Export Product Database - PAC3D";
                    break;
                case OutputTypeEnum.VenueNext:
                    taskType = "Venue Next";
                    break;
                case OutputTypeEnum.VenueHybrid:
                    taskType = "Venue Hybrid";
                    break;
            }
            if (taskType == null)
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "internal error: could not determine task type" });
            var taskTypeRecord = await context.Repositories.Simple<TaskType>().FirstAsync("Name", taskType);
            await environment.UpdateDetailedStatus("taskTypeRecord : " + taskTypeRecord);

            BuildQueueItem item = new BuildQueueItem
            {
                Debug = false,
                Config = new BuildTask()
            };
            item.Config.ID = Guid.NewGuid();
            item.Config.ConfigurationDefinitionID = config.ConfigurationDefinitionId;
            item.Config.ConfigurationID = configurationId;
            item.Config.StartedByUserID = userId;
            item.Config.TaskTypeID = taskTypeRecord.ID;
            item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
            item.Config.DateStarted = DateTime.Now;
            item.Config.DateLastUpdated = DateTime.Now;
            item.Config.PercentageComplete = 0f;

            // look for an associated aircraft id
            var aircraftConfiguration = await context.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("ConfigurationDefinitionID", definition.ConfigurationDefinitionID);
            if (aircraftConfiguration != null)
                item.Config.AircraftID = aircraftConfiguration.AircraftID;

            await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
            await context.SaveChanges();
            await environment.UpdateDetailedStatus("Task created : " + taskTypeRecord);

            string connectionString = environment.GetAzureWebJobsStorage();
            string queueName = environment.GetAzureWebJobsQueue();
            string message = JsonConvert.SerializeObject(item);
            var bytes = Encoding.ASCII.GetBytes(message);
            var base64 = System.Convert.ToBase64String(bytes);
            await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);
            await environment.UpdateDetailedStatus("Task created : " + taskTypeRecord);

            return new OkObjectResult(new DataCreationResultDTO()
            {
                IsError = false,
                Id = item.Config.ID
            });
        }

        public async Task<int> BuildVenueNext(TaskEnvironment environment, BuildTask currentTask)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started Venue Next build");
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var categories = await context.Repositories.ConfigurationComponentsRepository.GetCofigurationComponentsArtifacts(currentTask.ConfigurationID);

                var partNumberCollectionId = await context.Repositories.AircraftRepository.GetPartNumberCollectionId(currentTask.ConfigurationDefinitionID);

                var partNumbers = await context.Repositories.AircraftRepository.ConfigurationDefinitionPartNumber(currentTask.ConfigurationDefinitionID,partNumberCollectionId,string.Empty);

                var venueScriptDownloadPath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.VenueNextscripts)).Select(x => x.Path).FirstOrDefault();
                
                string finalVenueNextPath = environment.GetOutputPath();
                if (Directory.Exists(finalVenueNextPath))
                    Directory.Delete(finalVenueNextPath, true);
                Directory.CreateDirectory(finalVenueNextPath);
                
                string venueNextDownloadFolder = finalVenueNextPath + "\\VenueDownload";
                if (Directory.Exists(venueNextDownloadFolder))
                    Directory.Delete(venueNextDownloadFolder, true);
                Directory.CreateDirectory(venueNextDownloadFolder);

                string venueNextScriptExtractPath = string.Empty;
                string venuePath = string.Empty;
                venuePath = Path.Combine(venueNextDownloadFolder + "\\venueNextScript.zip");

                if (!string.IsNullOrWhiteSpace(venueScriptDownloadPath))
                {
                    DownloadData(environment, venueScriptDownloadPath, venuePath);
                    venueNextScriptExtractPath = buildPackageHelper.zipFileExtractor(venuePath);
                }
                var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", currentTask.ConfigurationID);
                if (definition == null)
                {
                    environment.Logger.LogError("Invalid Configuration..!");
                    return 0;
                }

                var insets = await context.Repositories.ASXiInsetRepository.GetASXiInsets(currentTask.ConfigurationID);

                Dictionary<string, string> venuNextPackagePath = new Dictionary<string, string>();
                string versionNumber = definition.Version.ToString("D2");

                //Create different packages
                venuNextPackagePath.Add(await PackageTimeZoneDB(environment, categories, definition, partNumbers, venueNextScriptExtractPath), VenueNextBuildTypeEnum.mtz.ToString());
                venuNextPackagePath.Add(await PackageFlightData(environment, categories, definition, partNumbers, venueNextScriptExtractPath), VenueNextBuildTypeEnum.mcfg.ToString());
                venuNextPackagePath.Add(await BuildMCCPackage(environment, categories, definition, partNumbers, venueNextScriptExtractPath), VenueNextBuildTypeEnum.mcc.ToString());
                venuNextPackagePath.Add(await BuildMCNTPackage(environment, categories, definition, partNumbers, venueNextScriptExtractPath), VenueNextBuildTypeEnum.mcnt.ToString());
                venuNextPackagePath.Add(await BuildBriefingsPackages(environment, categories, definition, partNumbers, "briefingcnt", venueNextScriptExtractPath), VenueNextBuildTypeEnum.hdbrfcnt.ToString());
                venuNextPackagePath.Add(await BuildBriefingsPackages(environment, categories, definition, partNumbers, "briefingcfg", venueNextScriptExtractPath), VenueNextBuildTypeEnum.hdbrfcfg.ToString());
                venuNextPackagePath.Add(await PackageMdatadb(environment, categories, definition, partNumbers, venueNextScriptExtractPath), VenueNextBuildTypeEnum.mdata.ToString());
                venuNextPackagePath.Add(await PackageMmobileccdb(environment, categories, definition, partNumbers, venueNextScriptExtractPath), VenueNextBuildTypeEnum.mmobilecc.ToString());
                venuNextPackagePath.Add(await PackageMinsetsDB(environment, categories, definition, partNumbers, insets, venueNextScriptExtractPath), VenueNextBuildTypeEnum.minsets.ToString());

                if (Directory.Exists(environment.GetOutputPath() + @"\TempSqlPath"))
                {
                    Directory.Delete(environment.GetOutputPath() + @"\TempSqlPath", true);
                }

                foreach (var path in venuNextPackagePath)
                {
                    //Get PartNumber based on packageType
                    Enum.TryParse(path.Value, out VenueNextBuildTypeEnum packageType);
                    string partNumber = string.Empty;
                    string ciiPartNumber = string.Empty;
                    string ciiFileName = string.Empty;
                    switch (packageType)
                    {
                        case VenueNextBuildTypeEnum.hdbrfcfg:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.hdbrfcfg)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.hdbrfcfgCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = path.Value.ToString().ToLower() + "_" + ciiPartNumber + "_" + versionNumber.ToString();
                            break;
                        case VenueNextBuildTypeEnum.hdbrfcnt:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.hdbrfcnt)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.hdbrfcntCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = path.Value.ToString().ToLower() + "_" + ciiPartNumber + "_" + versionNumber;
                            break;
                        case VenueNextBuildTypeEnum.mcc:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mcc)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = Path.GetFileName(Directory.GetFiles(path.Key)[0]).Split('.')[0];
                            break;
                        case VenueNextBuildTypeEnum.mcfg:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mcfg)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = Path.GetFileName(Directory.GetFiles(path.Key)[0]).Split('.')[0];
                            break;
                        case VenueNextBuildTypeEnum.mcnt:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mcnt)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = Path.GetFileName(Directory.GetFiles(path.Key)[0]).Split('.')[0];
                            break;
                        case VenueNextBuildTypeEnum.mdata:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mdata)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = Path.GetFileName(Directory.GetFiles(path.Key)[0]).Split('.')[0];
                            break;
                        case VenueNextBuildTypeEnum.minsets:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.minsets)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = Path.GetFileName(Directory.GetFiles(path.Key)[0]).Split('.')[0];
                            break;
                        case VenueNextBuildTypeEnum.mmobilecc:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mmobilecc)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = Path.GetFileName(Directory.GetFiles(path.Key)[0]).Split('.')[0];
                            break;
                        case VenueNextBuildTypeEnum.mtz:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mtz)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = Path.GetFileName(Directory.GetFiles(path.Key)[0]).Split('.')[0];
                            break;
                    }

                    buildPackageHelper.CopyFilesRecursively(path.Key, finalVenueNextPath);
                    if (Directory.Exists(path.Key))
                        Directory.Delete(path.Key, true);
                    CreateCII(environment, versionNumber, finalVenueNextPath, ciiFileName, partNumber, path.Value.ToString().ToLower());
                }

                if (Directory.Exists(venueNextDownloadFolder))
                    Directory.Delete(venueNextDownloadFolder, true);

                if (File.Exists(environment.GetOutputPath() + "\\asxairport.sqlite3"))
                    File.Delete(environment.GetOutputPath() + "\\asxairport.sqlite3");
                if (File.Exists(environment.GetOutputPath() + "\\asxinfo.sqlite3"))
                    File.Delete(environment.GetOutputPath() + "\\asxinfo.sqlite3");
                if (File.Exists(environment.GetOutputPath() + "\\asxwg.sqlite3"))
                    File.Delete(environment.GetOutputPath() + "\\asxwg.sqlite3");
                if (File.Exists(environment.GetOutputPath() + "\\custom.xml"))
                    File.Delete(environment.GetOutputPath() + "\\custom.xml");

                await environment.UpdateDetailedStatus("Completed Venue next build");
            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                await environment.UpdateDetailedStatus("Error in Venue next build: " + ex.Message);
                return 1;
            }
            return 0;
        }

        public async Task<int> BuildVenueHybrid(TaskEnvironment environment, BuildTask currentTask)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started Venue Hybrid build");
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var categories = await context.Repositories.ConfigurationComponentsRepository.GetCofigurationComponentsArtifacts(currentTask.ConfigurationID);
                var partNumberCollectionId = await context.Repositories.AircraftRepository.GetPartNumberCollectionId(currentTask.ConfigurationDefinitionID);

                var partNumbers = await context.Repositories.AircraftRepository.ConfigurationDefinitionPartNumber(currentTask.ConfigurationDefinitionID ,partNumberCollectionId,string.Empty);

                var venueHybridDownloadPath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.InstallationScriptsVenueHybrid)).Select(x => x.Path).FirstOrDefault();


                string finalVenueHybridPath = environment.GetOutputPath();
                if (Directory.Exists(finalVenueHybridPath))
                    Directory.Delete(finalVenueHybridPath, true);
                Directory.CreateDirectory(finalVenueHybridPath);

                string venueHybridDownloadFolder = finalVenueHybridPath + "\\venueHybridDownload";
                if (Directory.Exists(venueHybridDownloadFolder))
                    Directory.Delete(venueHybridDownloadFolder, true);
                Directory.CreateDirectory(venueHybridDownloadFolder);



                string venueHybridScriptExtractPath = string.Empty;
                string venueHybridPath = string.Empty;
                venueHybridPath = Path.Combine(venueHybridDownloadFolder + "\\venueHybridScript.zip");


                if (!string.IsNullOrWhiteSpace(venueHybridDownloadPath))
                {
                    DownloadData(environment, venueHybridDownloadPath, venueHybridPath);
                    venueHybridScriptExtractPath = buildPackageHelper.zipFileExtractor(venueHybridPath);
                }


                var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", currentTask.ConfigurationID);
                if (definition == null)
                {
                    environment.Logger.LogError("Invalid Configuration..!");
                    return 0;
                }

                var insets = await context.Repositories.ASXiInsetRepository.GetASXiInsets(currentTask.ConfigurationID);

                Dictionary<string, string> venueHybridPackagePath = new Dictionary<string, string>();
                string ciiFileName = string.Empty;
                string versionNumber = definition.Version.ToString("D2");
                //Create different packages

                venueHybridPackagePath.Add(await PackageAudioVideoBriefingsNonHd(environment, categories, definition, partNumbers, "audiovideobriefingcnt"), VenueHybridBuildTypeEnum.avb.ToString());
                venueHybridPackagePath.Add(await PackageAudioVideoBriefingsNonHd(environment, categories, definition, partNumbers, "audiovideobriefingcfg"), VenueHybridBuildTypeEnum.brfcfg.ToString());
                venueHybridPackagePath.Add(await BuildMmcdpPackage(environment, categories, definition, partNumbers, venueHybridScriptExtractPath), VenueHybridBuildTypeEnum.mmcdp.ToString());
                venueHybridPackagePath.Add(await BuildBlueMarblePackage(environment, categories, definition, partNumbers, venueHybridScriptExtractPath), VenueHybridBuildTypeEnum.bmp.ToString());
                venueHybridPackagePath.Add(await PackageAudioVideoBriefingsHd(environment, categories, definition, partNumbers, "hdbrfcnt"), VenueHybridBuildTypeEnum.hdbrfcnt.ToString());
                venueHybridPackagePath.Add(await PackageAudioVideoBriefingsHd(environment, categories, definition, partNumbers, "hdbrfcfg"), VenueHybridBuildTypeEnum.hdbrfcfg.ToString());
                venueHybridPackagePath.Add(await PackageConfig(environment, categories, definition, partNumbers, venueHybridScriptExtractPath), VenueHybridBuildTypeEnum.mmcfgp.ToString());
                venueHybridPackagePath.Add(await PackageContent(environment, categories, definition, partNumbers, venueHybridScriptExtractPath), VenueHybridBuildTypeEnum.mmcntp.ToString());

                if (insets.Count > 0)
                {
                    venueHybridPackagePath.Add(await PackageMinsetsForVenueHybrid(environment, categories, definition, partNumbers, insets, venueHybridScriptExtractPath), VenueHybridBuildTypeEnum.minsets.ToString());
                }
                venueHybridPackagePath.Add(await BuildMmdbpPackage(environment, categories, definition, partNumbers, venueHybridScriptExtractPath), VenueHybridBuildTypeEnum.mmdbp.ToString());

                if (Directory.Exists(environment.GetOutputPath() + @"\TempSqlPath"))
                {
                    Directory.Delete(environment.GetOutputPath() + @"\TempSqlPath",true);
                }
                foreach (var path in venueHybridPackagePath)
                {
                    //Get PartNumber based on packageType
                    Enum.TryParse(path.Value, out VenueHybridBuildTypeEnum packageType);
                    string partNumber = string.Empty;
                    string ciiPartNumber = string.Empty;
                    switch (packageType)
                    {   
					
					    case VenueHybridBuildTypeEnum.avb:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.avb)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.avbCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "avb_" + ciiPartNumber + "_" + versionNumber;
                            break;
                        case VenueHybridBuildTypeEnum.brfcfg:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.brfcfg)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.brfcfgCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "brfcfg_" + ciiPartNumber + "_" + versionNumber;
                            break;
                        case VenueHybridBuildTypeEnum.mmcdp:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmcdp)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmcdpCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "mmcdp_" + ciiPartNumber + "_" + versionNumber; 
                            break;
                        case VenueHybridBuildTypeEnum.bmp:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.bmp)).Select(X => X.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.bmpCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "bmp_" + ciiPartNumber + "_" + versionNumber; 
                            break;
                        case VenueHybridBuildTypeEnum.hdbrfcnt:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.hdbrfcnt)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.hdbrfcntCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "hdbrfcnt_" + ciiPartNumber + "_" + versionNumber; 
                            break;
                        case VenueHybridBuildTypeEnum.hdbrfcfg:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.hdbrfcfg)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.hdbrfcfgCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "hdbrfcfg_" + ciiPartNumber + "_" + versionNumber; 
                            break;
                        case VenueHybridBuildTypeEnum.minsets:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.minsets)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.minsets)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "minsets_" + ciiPartNumber + "_" + versionNumber; 
                            break;
                        case VenueHybridBuildTypeEnum.mmdbp:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmdbp)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmdbpCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "mmdbp_" + ciiPartNumber + "_" + versionNumber; 
                            break;
                        case VenueHybridBuildTypeEnum.mmcntp:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmcntp)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmcntpCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "mmcntp_" + ciiPartNumber + "_" + versionNumber; 
                            break;
                        case VenueHybridBuildTypeEnum.mmcfgp:
                            partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmcfgp)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiPartNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmcfgpCII)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                            ciiFileName = "mmcfgp_" + ciiPartNumber + "_" + versionNumber; 
                            break;
                    }

                    buildPackageHelper.CopyFilesRecursively(path.Key, finalVenueHybridPath);
                    if (Directory.Exists(path.Key))
                        Directory.Delete(path.Key, true);

                    CreateCII(environment, versionNumber, finalVenueHybridPath, ciiFileName, partNumber, path.Value.ToString().ToLower());
                    
                    if (Directory.Exists(venueHybridDownloadFolder))
                        Directory.Delete(venueHybridDownloadFolder, true);

                }

                await environment.UpdateDetailedStatus("Completed Venue hybrid build");

            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                await environment.UpdateDetailedStatus("Error in Venue hybrid build: " + ex.Message);
                return 1;
            }
            return 0;
        }

        public async Task<int> BuildModListJSON(TaskEnvironment environment)
        {
            try
            {
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                List<string> listGeoRefIds = new List<string>();
                List<string> resolutionValues = new List<string>();
                List<ModListJSON> modListJSONs = new List<ModListJSON>();

                DataTable modListDataTable = new DataTable();
                modListDataTable.Columns.Add("Id", typeof(int));
                modListDataTable.Columns.Add("FileJSON", typeof(string));
                modListDataTable.Columns.Add("Row", typeof(int));
                modListDataTable.Columns.Add("Col", typeof(int));
                modListDataTable.Columns.Add("Resolution", typeof(int));

                // getting landsat value
                string landSatValue = await context.Repositories.ConfigurationRepository.GetLandSatValue(environment.CurrentTask.ConfigurationID);
                var featuresetValue = await context.Repositories.ConfigurationRepository.GetFeature(environment.CurrentTask.ConfigurationID, "Modlist-resolutions");

                if (string.IsNullOrWhiteSpace(landSatValue) || string.IsNullOrWhiteSpace(featuresetValue.Value))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }
                // bringing resolution values from feature set table.

                resolutionValues = featuresetValue.Value.Split(",").ToList();

                // bringing all the JSON fiels for the given configuration id.
                List<ModListData> listModlistData = await context.Repositories.ConfigurationRepository.GetModlistData(environment.CurrentTask.ConfigurationID, true);

                if (listModlistData.Count > 0)
                {
                    listModlistData.ForEach(data =>
                    {
                        ModListPOI modListJson = JsonConvert.DeserializeObject<ModListPOI>(data.FileJSON);
                        if (modListJson != null && modListJson.POI != null)
                        {
                            if (modListJson.POI.Airports?.Count > 0)
                            {
                                modListJson.POI.Airports.ForEach(airport =>
                                {
                                    listGeoRefIds.Add(airport.Id.ToString());
                                });
                            }
                            if (modListJson.POI.Cities?.Count > 0)
                            {
                                modListJson.POI.Cities.ForEach(city =>
                                {
                                    listGeoRefIds.Add(city.Id.ToString());
                                });
                            }
                            if (modListJson.POI.WaterFeatures?.Count > 0)
                            {
                                modListJson.POI.WaterFeatures.ForEach(water =>
                                {
                                    listGeoRefIds.Add(water.Id.ToString());
                                });
                            }
                            if (modListJson.POI.LandFeatures?.Count > 0)
                            {
                                modListJson.POI.LandFeatures.ForEach(land =>
                                {
                                    listGeoRefIds.Add(land.Id.ToString());
                                });
                            }
                        }
                    });
                }

                if (listGeoRefIds != null && listGeoRefIds.Count > 0)
                {
                    string geoRefIds = string.Join(",", listGeoRefIds);
                    modListJSONs = await context.Repositories.ConfigurationRepository.GetDataForModListJson(geoRefIds, environment.CurrentTask.ConfigurationID, "geoRef");
                }
                List<ModListJSON> newModListJSONs = await context.Repositories.ConfigurationRepository.GetDataForModListJson("", environment.CurrentTask.ConfigurationID, "all");

                if (newModListJSONs != null && newModListJSONs.Count > 0)
                    modListJSONs.AddRange(newModListJSONs);

                if (resolutionValues.Count > 0 && modListJSONs.Count > 0)
                {
                    modListDataTable = CreateModListDataTable(modListJSONs, resolutionValues, landSatValue);
                }
                if (modListDataTable.Rows.Count > 0)
                {
                    if (modListDataTable.Rows.Count > 699)
                    {
                        List<DataTable> result = modListDataTable.AsEnumerable()
                        .GroupBy(row => row.Field<int>("Resolution"))
                        .Select(g => g.CopyToDataTable())
                        .ToList();

                        if (result.Count > 0)
                        {
                            result.ForEach(async resolutions =>
                            {
                                if (resolutions.Rows.Count > 699)
                                {
                                    List<DataTable> rowsDataTable = resolutions.AsEnumerable()
                                    .GroupBy(row => row.Field<int>("Row"))
                                    .Select(g => g.CopyToDataTable())
                                    .ToList();

                                    if (rowsDataTable.Count > 0)
                                    {
                                        rowsDataTable.ForEach(async row =>
                                        {
                                            if (row.Rows.Count > 699)
                                            {
                                                List<DataTable> colsDataTable = row.AsEnumerable()
                                                .GroupBy(row => row.Field<int>("Col"))
                                                .Select(g => g.CopyToDataTable())
                                                .ToList();

                                                if (colsDataTable.Count > 0)
                                                {
                                                    colsDataTable.ForEach(async col =>
                                                    {
                                                        UpdateDataFromDataTable(environment, col);
                                                    });
                                                }
                                            }
                                            else
                                            {
                                                UpdateDataFromDataTable(environment, row);
                                            }
                                        });
                                    }
                                }
                                else
                                {
                                    UpdateDataFromDataTable(environment, resolutions);
                                }
                            });
                        }
                    }
                    else
                    {
                        UpdateDataFromDataTable(environment, modListDataTable);
                    }

                }
            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                return 0;
            }
            return 1;
        }

        public async Task<int> PerformDataMerge(TaskEnvironment environment)
        {
            //TODO remove commented code after file testing
            //              Checking if the config can be merged
            //              Perform final merge(update mapping tables for Child config)
            //              Update the task status
            //              Update child config version to update

            //check task table

            try
            {
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                var childConfigId = environment.CurrentTask.ConfigurationID;
                var childConfigDefId = environment.CurrentTask.ConfigurationDefinitionID;
                var currentTask = environment.CurrentTask;

                //var childDef = (await context.Repositories.ConfigurationDefinitions.FilterAsync<ConfigurationDefinition>("ConfigurationDefinitionID", childConfigDefId)).DefaultIfEmpty(null).FirstOrDefault();
                //var parentDef = (await context.Repositories.ConfigurationDefinitions.FilterAsync<ConfigurationDefinition>("ConfigurationDefinitionID", childDef.ConfigurationDefinitionParentID)).DefaultIfEmpty(null).FirstOrDefault();

                var mergeTaskInfo = currentTask.TaskDataJSON;
                await context.Repositories.MergeConfigurationRepository.PerformMergeChoiceMoveToMapTable(childConfigId, mergeTaskInfo.ToString());

                var taskInfo = await context.Repositories.Simple<BuildTask>().FirstAsync("ID", currentTask.TaskDataJSON);
                var parentConfigIds = taskInfo.TaskDataJSON.Split(',').ToList();
                var currentParentConfigId = parentConfigIds.Select(p => int.Parse(p)).Max();
                await context.Repositories.MergeConfigurationRepository.SetConfigUpdatedVersion(Convert.ToInt32(currentParentConfigId), childConfigDefId);
                await context.SaveChanges();


            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                return 1;
            }

            return 0;
        }

        /// <summary>
        /// Method to populate merge details table
        /// </summary>
        /// <param name="environment"></param>
        /// <returns></returns>
        public async Task<int> PopulateMergeDetails(TaskEnvironment environment)
        {
            try
            {
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;
                var configurationId = environment.CurrentTask.ConfigurationID;
                var configurationDefinitionfId = environment.CurrentTask.ConfigurationDefinitionID;
                var parentConfigurationIds = environment.CurrentTask.TaskDataJSON;
                var taskId = environment.CurrentTask.ID;
                foreach (var parentConfigurationId in parentConfigurationIds.Split(",").ToList())
                {
                    var result = await context.Repositories.MergeConfigurationRepository.PopulateMergeDetails(configurationId, int.Parse(parentConfigurationId), taskId.ToString());

                    if (result > 0)
                    {
                        var conflictData = await context.Repositories.MergeConfigurationRepository.GetMergeConflictData(taskId);
                        if (conflictData.Count == 0)
                        {
                            var mergeDataCount = await context.Repositories.MergeConfigurationRepository.GetMergeConflictCount(taskId.ToString());

                            var response = await context.Repositories.MergeConfigurationRepository.PerformMergeChoiceMoveToMapTable(configurationId, taskId.ToString());
                            if (response > 0 || mergeDataCount == 0)
                            {
                                await context.Repositories.MergeConfigurationRepository.SetConfigUpdatedVersion(int.Parse(parentConfigurationId), configurationDefinitionfId);

                            }
                        }           
                    }
                }
                await context.SaveChanges();
            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                return 1;
            }
            return 0;
        }


        /// <summary>
        /// Task to save products
        /// </summary>
        /// <param name="environment"></param>
        /// <returns></returns>
        public async Task<int> SaveProducts(TaskEnvironment environment)
        {
            try
            {
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                var currentTask = environment.CurrentTask;
                ProductConfigurationData productConfigurationData = JsonConvert.DeserializeObject<ProductConfigurationData>(currentTask.TaskDataJSON);

                await context.Repositories.ConfigurationDefinitions.SaveProducts(productConfigurationData, environment.CurrentTask.StartedByUserID);
                await context.SaveChanges();
            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                return 1;
            }
            return 0;
        }

        /// <summary>
        /// Task to save platforms and product details
        /// </summary>
        /// <param name="environment"></param>
        /// <returns></returns>
        public async Task<int> SaveProductConfigurationData(TaskEnvironment environment)
        {
            try
            {
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                var currentTask = environment.CurrentTask;
                ProductConfigurationData productConfigurationData = JsonConvert.DeserializeObject<ProductConfigurationData>(currentTask.TaskDataJSON);

                DataTable platformDataTable = new DataTable();
                platformDataTable.Columns.Add("ConfigurationDefinitionID", typeof(int));
                platformDataTable.Columns.Add("Name", typeof(string));
                platformDataTable.Columns.Add("Description", typeof(string));
                platformDataTable.Columns.Add("PlatformId", typeof(int));
                platformDataTable.Columns.Add("InstallationTypeID", typeof(string));

                productConfigurationData.PlatformConfiguration.ForEach(platform => {
                    platformDataTable.Rows.Add(platform.ConfigurationDefinitionID, platform.Name, platform.Description, platform.PlatformId, platform.InstallationTypeID);
                });

                await context.Repositories.ConfigurationDefinitions.SaveProductConfigurationData(productConfigurationData, environment.CurrentTask.StartedByUserID, platformDataTable);
                await context.SaveChanges();
            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                return 1;
            }
            return 0;
        }

		/// <summary>
        /// Task to save Aircraft details
        /// </summary>
        /// <param name="environment"></param>
        /// <returns></returns>
        public async Task<int> SaveAircraftConfigurationData (TaskEnvironment environment)
        {
            try
            {
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                var currentTask = environment.CurrentTask;

                var result = await context.Repositories.ConfigurationRepository.BranchConfigFromParent(currentTask.ConfigurationDefinitionID, currentTask.ConfigurationID, currentTask.StartedByUserID, currentTask.TaskDataJSON);

                await context.Repositories.ConfigurationRepository.UpdatePartNumberFromTemp(environment.CurrentTask.AircraftID);
                await context.SaveChanges();


            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                return 1;
            }
            return 0;
        }

        public async Task <int> InsertCustomXMLData(TaskEnvironment environment, string outputConfigPath)
        {
            try
            {
                string sourcePath = environment.GetOutputPath() + @"\CustomXML";
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                if (Directory.Exists(sourcePath))
                {
                    Directory.Delete(sourcePath, true);
                }
                Directory.CreateDirectory(sourcePath);
                
                buildPackageHelper.zipFileExtractor(outputConfigPath + ".zip", sourcePath);

                var path = Directory.GetFiles(sourcePath);

                (new TaskImportInitialConfiguration()).ImportCustomDataAsync(environment, path[0], environment.CurrentTask.ConfigurationID);
                await UploadToBlobStorage(environment, environment.CurrentTask.ConfigurationID, environment.CurrentTask.StartedByUserID, outputConfigPath + ".zip", ConfigurationCustomComponentType.customXML.ToString().ToLower(), GetDescriptionFromEnum(ConfigurationCustomComponentType.customXML).ToLower());

            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.ToString());
                return 1;
            }
            return 0;
        }

        #endregion

        #region Private Method
        /// <summary>
        /// 1. Method to upload data to azure storage container.
        /// 2. This will create a stream of data and upload it to azure.
        /// 3. The folder structure will be config definition ID folder then configuration id folder and then inside this the file will be uploaded
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="userId"></param>
        /// <param name="zipfilePath"></param>
        /// <param name="fileName"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> UploadToBlobStorage(TaskEnvironment environment, int configurationId, Guid userId, string zipfilePath, string fileName, string pageName)
        {
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (definition == null)
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Invalid configuration"
                };
            }

            //Upload the file to Blob container
            string connectionString = environment.GetAzureWebJobsStorage();
            string blobContainer = environment.GetAzureBlobStorageContainerforCollinsAdminAssets();
            string uploadPath = definition.ConfigurationDefinitionId + "\\" + configurationId + "\\";
            string name = fileName + "_custom_component.zip";
            FileInfo currentFile = new FileInfo(zipfilePath);

            byte[] byteArray = File.ReadAllBytes(zipfilePath);

            string destFile = currentFile.Directory.FullName + "\\" + fileName + ".zip";
            if (File.Exists(destFile))
                File.Delete(destFile);
            currentFile.CopyTo(destFile);

            var fileUploadDetails = await AzureFileHelper.UploadFiles(connectionString, blobContainer, byteArray, name, uploadPath);

            string url = fileUploadDetails[0].Key;
            string error = fileUploadDetails[0].Value;
            string truncatedURL = string.Empty;
            if (!string.IsNullOrWhiteSpace(url.ToString()))
            {
                if (!url.ToLower().Equals("true"))
                    truncatedURL = url.ToString()[(url.ToString().LastIndexOf('/') + 1)..];

                var result = await context.Repositories.ConfigurationRepository.UpdateFilePath(truncatedURL, configurationId, fileName, userId, pageName, error);

                if (result > 0)
                {
                    resultDTO.IsError = false;
                    resultDTO.Id = new Guid();
                    resultDTO.Message = "The files are uploaded successfully.";
                    await context.SaveChanges();
                }
                else if (result == 0)
                {
                    resultDTO.IsError = false;
                    resultDTO.Id = new Guid();
                    resultDTO.Message = "Warning";
                    await context.SaveChanges();
                }
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Id = new Guid();
                resultDTO.Message = "File upload failed.";

            }
            return resultDTO;
        }

        private static async void DownloadData(TaskEnvironment environment, string url, string destinationFolder,bool isCompleteURL=false)
        {
            try
            {
                WebClient client = new WebClient();
                string azureBlobUrl = environment.GetAzureBlobUrl();
                string blobContainer = environment.GetAzureBlobStorageContainerforCollinsAdminAssets();

                byte[] myDataBuffer1;
                if (!isCompleteURL)
                    myDataBuffer1 = client.DownloadData((new Uri(string.Concat(azureBlobUrl, blobContainer, '/', url))));
                else
                    myDataBuffer1 = client.DownloadData(url);

                MemoryStream storeStream1 = new MemoryStream();
                environment.UpdateDetailedStatus("Memory stream capacity " + storeStream1.Capacity.ToString());
                environment.UpdateDetailedStatus("Data length " + myDataBuffer1.Length.ToString());
                storeStream1.SetLength(myDataBuffer1.Length);

                storeStream1.Write(myDataBuffer1, 0, (int)storeStream1.Length);
                storeStream1.Flush();

                FileStream outStream1 = File.OpenWrite(destinationFolder);
                storeStream1.WriteTo(outStream1);
                outStream1.Flush();
                outStream1.Close();
                client.Dispose();
            }
            catch(Exception ex)
            {
                await environment.UpdateDetailedStatus("Download data failed: " + ex.Message);
                await environment.UpdateDetailedStatus("Download data failed: " + ex.StackTrace);
                throw ex;
            }

        }

        private static void GenerateReleaseTxtFile(Configuration definition, string partNumer, string buildDirecotry)
        {
            StreamWriter releaseStreaWriter = File.CreateText(buildDirecotry + "\\release.txt");
            releaseStreaWriter.WriteLine("Date : " + DateTime.Now.ToLongDateString() + "  " + DateTime.Now.ToLongTimeString());
            releaseStreaWriter.WriteLine("Part#: " + partNumer);
            string stringVersion = definition.Version.ToString();// oVersion.Major.ToString() + "." + oVersion.Minor.ToString() + "." + oVersion.Build.ToString() + " (Build: " + oVersion.Revision.ToString() + ")";
            releaseStreaWriter.WriteLine("Configuration Tool Version: " + stringVersion);
            releaseStreaWriter.WriteLine("Database Version: " + 1);
            releaseStreaWriter.WriteLine("Database Platform: " + 1);
            releaseStreaWriter.WriteLine("Database Creator: " + 1);
            releaseStreaWriter.Flush();
            releaseStreaWriter.Close();
        }

        private static void GenerateVenueHybridReleaseTxtFile(Configuration definition, string partNumber, string resourcePath)
        {
            StreamWriter releaseStreaWriter = File.CreateText(resourcePath + "\\release.txt");
            releaseStreaWriter.WriteLine("Date : " + DateTime.Now.ToLongDateString() + "  " + DateTime.Now.ToLongTimeString());
            releaseStreaWriter.WriteLine("Customer Config Part Number: " + partNumber);
            string stringVersion = definition.Version.ToString();
            releaseStreaWriter.WriteLine("Configuration Tool Version: " + stringVersion);
            releaseStreaWriter.WriteLine("Package Part Number: " + partNumber + "_" + stringVersion);
            releaseStreaWriter.Flush();
            releaseStreaWriter.Close();
        }

        /// <summary>
        /// To build the package for venue next (mcfg)  - Configuration
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="currentTask"></param>
        /// <param name="categories"></param>
        /// <param name="definition"></param>
        /// <returns></returns>
        private async Task<string> PackageFlightData(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venuNextScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build Flight data package");
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var flightDataPath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.FlightDataconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();
                var siteIdConfigPath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.SiteIdentificationconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();
                var tzBasePath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.TimezoneDatabaseconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();
                var acarsConfig = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.ACARSDataconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();
                var flightPhase = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.FlightPhaseconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();
                var discreteInputs = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.DiscreteInputs).ToLower()).Select(x => x.Path).FirstOrDefault();
                var fdcMapMenuListConfig = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.FDCMapMenuList).ToLower()).Select(x => x.Path).FirstOrDefault();
                //TODO FDCMapMenuListConfig.xml

                if (string.IsNullOrWhiteSpace(flightDataPath) || string.IsNullOrWhiteSpace(tzBasePath) ||
                    string.IsNullOrWhiteSpace(venuNextScriptExtractPath) || string.IsNullOrWhiteSpace(flightPhase) || 
                    string.IsNullOrWhiteSpace(fdcMapMenuListConfig))
                    
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mcfg)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                List<string> lstConfigXmlFilePath = new List<string>();
                lstConfigXmlFilePath.Add(tzBasePath);
                lstConfigXmlFilePath.Add(siteIdConfigPath);
                lstConfigXmlFilePath.Add(acarsConfig);
                lstConfigXmlFilePath.Add(flightPhase);
                lstConfigXmlFilePath.Add(discreteInputs);
                lstConfigXmlFilePath.Add(fdcMapMenuListConfig);

                string resourcePath = environment.GetOutputPath() + @"\FlightData";
                string finalTzPath = environment.GetOutputPath() + @"\FlightDataTZ";

                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);
                Directory.CreateDirectory(resourcePath);

                if (Directory.Exists(finalTzPath))
                    Directory.Delete(finalTzPath, true);
                Directory.CreateDirectory(finalTzPath);

                var tzdbaseoutputPath = Path.Combine(resourcePath, "tzdbase.zip");
                var venueScriptoutputPath = Path.Combine(resourcePath, "venue_next_scripts.zip");
                var flightDataOutputPath = Path.Combine(resourcePath, "flightData.zip");

                //Generates version.txt file
                GeneratVersionTxtFile(definition, partNumber, resourcePath);

                string stringScriptDir = resourcePath + "\\mcfg";

                string buildDirecotry = stringScriptDir;

                string stringConfigDirectory = buildDirecotry + "\\config";
                if (Directory.Exists(stringConfigDirectory))
                    Directory.Delete(stringConfigDirectory, true);
                Directory.CreateDirectory(stringConfigDirectory);


                string fmsDirecotory = stringConfigDirectory + "\\FMS";
                if (Directory.Exists(fmsDirecotory))
                    Directory.Delete(fmsDirecotory, true);
                Directory.CreateDirectory(fmsDirecotory);

                //tzdbase
                foreach (var path in lstConfigXmlFilePath)
                {
                    if (!string.IsNullOrWhiteSpace(path))
                    {

                        DownloadData(environment, path, tzdbaseoutputPath);

                        buildPackageHelper.zipFileExtractor(tzdbaseoutputPath, stringConfigDirectory, true);
                    }
                }

                //Generate asxiconfigpartnum.xml
                GenerateAsxiXonfigPartNumXML(definition, partNumber, stringConfigDirectory);

                //Generat custom xml
                await GenerateCustomXML(environment, stringConfigDirectory);

                //get install.sh and clean.sh from Venue_Next_Data under custom content from azure
                if (!string.IsNullOrWhiteSpace(venuNextScriptExtractPath))
                {
                    if (Directory.Exists(venuNextScriptExtractPath + "\\mcfg"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venuNextScriptExtractPath + "\\mcfg", buildDirecotry);
                    }
                }

                if (!string.IsNullOrWhiteSpace(flightDataPath))
                {
                    DownloadData(environment, flightDataPath, flightDataOutputPath);
                    ZipFile.ExtractToDirectory(flightDataOutputPath, fmsDirecotory);
                    File.Delete(flightDataOutputPath);
                }

                GenerateReleaseTxtFile(definition, partNumber, buildDirecotry);
                string message;
                if (!(buildPackageHelper.CreateSquashIMGFileSystem(environment.GetLocalAssetPath("bin\\cygwin"), buildDirecotry, resourcePath, "mcfg.img", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                if (Directory.Exists(stringScriptDir))
                    Directory.Delete(stringScriptDir, true);

                string tgzFilePath = finalTzPath;
                string tzgFileName = "mcfg_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                buildPackageHelper.CreateTGZ(resourcePath, tzgFileName, tgzFilePath);
                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);

                await environment.UpdateDetailedStatus("Completed building flight data package");
                return tgzFilePath;
            }
            catch (Exception ex)
            {
                await environment.UpdateDetailedStatus("Error building flight data package: " + ex.Message);
                return ex.Message;
            }
        }

        private static async Task GenerateCustomXML(TaskEnvironment environment, string stringConfigDirectory,bool isVenueHybrid = false)
        {
            var customXmlPath = environment.GetOutputPath("custom.xml");
            if (!File.Exists(customXmlPath))
            {
                TaskDevelopmentExport taskDevelopmentExport = new TaskDevelopmentExport();
                await taskDevelopmentExport.GenerateCustomXML(environment, isVenueHybrid);
            }
            if (!string.IsNullOrEmpty(stringConfigDirectory))
                File.Move(customXmlPath, stringConfigDirectory + "//custom.xml", true);

        }

        private static async Task GenerateASXIInfoDB(TaskEnvironment environment, string stringConfigDirectory)
        {
            TaskDevelopmentExport taskDevelopmentExport = new TaskDevelopmentExport();
            await taskDevelopmentExport.GenerateASXInfoDatabase(environment, environment.CurrentTask.ConfigurationID);
            if (Directory.Exists(Path.Join(environment.TempStoragePath, "temp")))
            {
                Directory.Delete(Path.Join(environment.TempStoragePath, "temp"), true);
            }
        }

        private static async Task GenerateASXIAirportDB(TaskEnvironment environment, string stringConfigDirectory)
        {
            TaskDevelopmentExport taskDevelopmentExport = new TaskDevelopmentExport();
            await taskDevelopmentExport.GenerateASXIAirportinfoDatabase(environment, environment.CurrentTask.ConfigurationID);
            if (Directory.Exists(Path.Join(environment.TempStoragePath, "temp")))
            {
                Directory.Delete(Path.Join(environment.TempStoragePath, "temp"), true);
            }
        }

        private static async Task GenerateASXIWgDB(TaskEnvironment environment, string stringConfigDirectory)
        {
            TaskDevelopmentExport taskDevelopmentExport = new TaskDevelopmentExport();
            await taskDevelopmentExport.GenerateASXIaswginfoDatabase(environment, environment.CurrentTask.ConfigurationID);
            if (Directory.Exists(Path.Join(environment.TempStoragePath, "temp")))
            {
                Directory.Delete(Path.Join(environment.TempStoragePath, "temp"), true);
            }
        }

        private static void GenerateAsxiXonfigPartNumXML(Configuration definition, string partNumber, string stringConfigDirectory)
        {
            XmlDocument doc = new XmlDocument();
            XmlDeclaration xmlDeclaration = doc.CreateXmlDeclaration("1.0", "UTF-8", "yes");
            XmlElement root = doc.DocumentElement;
            doc.InsertBefore(xmlDeclaration, root);
            XmlElement element1 = doc.CreateElement("asxiconfig");
            element1.SetAttribute("partnumber", partNumber);
            element1.SetAttribute("version", definition.Version.ToString());

            doc.AppendChild(element1);
            doc.Save(stringConfigDirectory + "\\asxiconfigpartnum.xml");
        }

        private static async Task GenerateASXNetDatabase(TaskEnvironment environment, string stringConfigDirectory)
        {
            var tempSqlPath = environment.GetTempPath("asxnet.sql");
            TaskExportProductDatabase taskExportProductDatabase = new TaskExportProductDatabase();
            await taskExportProductDatabase.GenerateCesHtseSqlFile(environment, environment.CurrentTask.ConfigurationID, true);
            TaskDevelopmentExport taskDevelopmentExport = new TaskDevelopmentExport();
            BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
            File.Move(environment.GetTempPath("asxnet.sql"), environment.GetTempPath("asxnet.sqlite3.sql"));
            taskDevelopmentExport.GenerateDatabase(environment, "asxnet");
            if (Directory.Exists(Path.Join(environment.TempStoragePath, "temp")))
            {
                Directory.Delete(Path.Join(environment.TempStoragePath, "temp"), true);
            }
        }

        /// <summary>
        /// To build the package for venue next (mtz) - Timezone database
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="currentTask"></param>
        /// <param name="categories"></param>
        /// <param name="definition"></param>
        /// <returns></returns>
        private async Task<string> PackageTimeZoneDB(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venuNextScriptExtractPath)
        {
            //get the time zone .dta file from azure storage
            //form the the directory sctructure and create .img file and form the direct structure
            try
            {
                await environment.UpdateDetailedStatus("Started to build Timezone package");
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var tzBasePath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.TimezoneDatabaseconfiguration)).Select(x => x.Path).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(venuNextScriptExtractPath) || string.IsNullOrWhiteSpace(tzBasePath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mtz)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string resourcePath = environment.GetOutputPath() + @"\TimeZone";
                string finalTzPath = environment.GetOutputPath() + @"\TimeZoneTZ";

                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);
                Directory.CreateDirectory(resourcePath);

                if (Directory.Exists(finalTzPath))
                    Directory.Delete(finalTzPath, true);
                Directory.CreateDirectory(finalTzPath);

                //Create version text file
                GeneratVersionTxtFile(definition, partNumber, resourcePath);
                //Change permission for version.txt

                string message;
                var cygwinPath =  environment.GetLocalAssetPath("bin\\cygwin");
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, resourcePath, "version.txt", "644", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string stringScriptDir = resourcePath + "\\mtz";
                if (Directory.Exists(stringScriptDir))
                    Directory.Delete(stringScriptDir, true);
                Directory.CreateDirectory(stringScriptDir);


                var tzdbaseoutputPath = Path.Combine(resourcePath, "tzdbase.zip");
                var venueScriptoutputPath = Path.Combine(resourcePath, "venue_next_scripts.zip");

                string buildDirecotry = stringScriptDir;

                string stringConfigDirectory = buildDirecotry + "\\config";
                if (Directory.Exists(stringConfigDirectory))
                    Directory.Delete(stringConfigDirectory, true);
                Directory.CreateDirectory(stringConfigDirectory);


                //tzdbase
                if (!string.IsNullOrWhiteSpace(tzBasePath))
                {
                    DownloadData(environment, tzBasePath, tzdbaseoutputPath);
                    buildPackageHelper.zipFileExtractor(tzdbaseoutputPath, stringConfigDirectory, true);
                }


                //get install.sh and clean.sh from Venue_Next_Data under custom content from azure
                if (!string.IsNullOrWhiteSpace(venuNextScriptExtractPath))
                {
                    if (Directory.Exists(venuNextScriptExtractPath + "\\mtz"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venuNextScriptExtractPath + "\\mtz", buildDirecotry);
                    }
                }

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, buildDirecotry, "config", " -R  755 ", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                GenerateReleaseTxtFile(definition, partNumber, buildDirecotry);


                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, buildDirecotry, "release.txt", "777", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);
                if (!(buildPackageHelper.CreateSquashIMGFileSystem(cygwinPath, buildDirecotry, resourcePath, "mtz.img", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, buildDirecotry, "mtz.img", "700", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                if (Directory.Exists(stringScriptDir))
                    Directory.Delete(stringScriptDir, true);

                string tzgFileName = "mtz_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                buildPackageHelper.CreateTGZ(resourcePath, tzgFileName, finalTzPath);
                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Timezone package");
                return finalTzPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                environment.CurrentTask.TaskStatusID = 3;
                await environment.UpdateDetailedStatus("Error building Timezone package: " + ex.Message);
                return ex.Message;
            }
        }

        /// <summary>
        /// 1. Method to create tgz files for the Briefings packages
        /// 2. This method will work for both briefings content and briefings config.
        /// 3. Based on input parameter briefingDataType, it will decide which data to be used for tgz creation.
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="currentTask"></param>
        /// <param name="briefingDataType"></param>
        /// <returns></returns>
        private async Task<string> BuildBriefingsPackages(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string briefingDataType, string venuNextScriptExtractPath)
        {
            //get the time zone .dta file from azure storage
            //form the the directory sctructure and create .img file and form the direct structure
            try
            {
                await environment.UpdateDetailedStatus("Started to build Briefings package");
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var briefingsBasePath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.Briefingsconfiguration)).Select(x => x.Path).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(briefingsBasePath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = "";
                if (briefingDataType.ToLower() == "briefingcnt")
                {
                    partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.hdbrfcnt)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                }
                else if (briefingDataType.ToLower() == "briefingcfg")
                {
                    partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.hdbrfcfg)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                }

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string sourcePath = environment.GetOutputPath() + @"\" + briefingDataType;
                string finalBriefingsPath = environment.GetOutputPath() + @"\" + briefingDataType + "tgz";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalBriefingsPath))
                    Directory.Delete(finalBriefingsPath, true);
                Directory.CreateDirectory(finalBriefingsPath);

                //Create version text file and change the permission as required
                string message;
                GeneratVersionTxtFile(definition, partNumber, sourcePath);
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version.txt", "644", out message))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string briefingsOutputPath = Path.Combine(sourcePath, "briefings.zip");

                if (!string.IsNullOrWhiteSpace(briefingsOutputPath))
                {
                    DownloadData(environment, briefingsBasePath, briefingsOutputPath);
                    
                    buildPackageHelper.zipFileExtractor(briefingsOutputPath, sourcePath, true);
                }

                string[] directories = Directory.GetDirectories(sourcePath);

                if (briefingDataType.ToLower() == "briefingcnt")
                {
                    packageHelper.CopyFilesRecursively(sourcePath + "/Content", sourcePath);
                    Directory.Delete(sourcePath + "/Content", true);
                    Directory.Delete(sourcePath + "/Config", true);
                }
                else if (briefingDataType.ToLower() == "briefingcfg")
                {
                    packageHelper.CopyFilesRecursively(sourcePath + "/Config", sourcePath);
                    Directory.Delete(sourcePath + "/Config", true);
                    Directory.Delete(sourcePath + "/Content", true);
                }
                
                //extract venue next script into buildDirecotry
                string tzgFileName = finalBriefingsPath + ".tgz";
                if (briefingDataType.ToLower() == "briefingcnt")
                {
                    tzgFileName = "hdbrfcnt_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                }
                else if (briefingDataType.ToLower() == "briefingcfg")
                {
                    tzgFileName = "hdbrfcfg_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                }

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, finalBriefingsPath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Briefings package");
                return finalBriefingsPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building briefings package: " + ex.Message);
                return ex.Message;
            }
        }

       
        /// <summary>
        /// Method to create a TGZ file for MMC package
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="currentTask"></param>
        /// <returns></returns>
        private async Task<string> BuildMCCPackage(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venuNextScriptExtractPath)
        {
            //get the time zone .dta file from azure storage
            //form the the directory sctructure and create .img file and form the direct structure
            try
            {
                await environment.UpdateDetailedStatus("Started to build MCC package");
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;

                var mccBasePath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.tickeradsconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(venuNextScriptExtractPath) || string.IsNullOrWhiteSpace(mccBasePath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mcc)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string sourcePath = environment.GetOutputPath() + @"\MCC";
                string finalMCCPath = environment.GetOutputPath() + @"\MCCTgz";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalMCCPath))
                    Directory.Delete(finalMCCPath, true);
                Directory.CreateDirectory(finalMCCPath);

                //Create version text file and Change permission for version.txt
                string message;
                GeneratVersionTxtFile(definition, partNumber, sourcePath);
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version.txt", "644", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string scriptDir = sourcePath + "\\mcc";
                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);
                Directory.CreateDirectory(scriptDir);


                var mccOutputPath = Path.Combine(scriptDir, "mcc.zip");

                //mcc file from cloud
                if (!string.IsNullOrWhiteSpace(mccBasePath))
                {
                    DownloadData(environment, mccBasePath, mccOutputPath);
                    buildPackageHelper.zipFileExtractor(mccOutputPath, scriptDir, true);
                }


                //get install.sh and clean.sh from Venue_Next_Data under custom content from azure
                if (!string.IsNullOrWhiteSpace(venuNextScriptExtractPath))
                {
                    if (Directory.Exists(venuNextScriptExtractPath + "\\mcc"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venuNextScriptExtractPath + "\\mcc", scriptDir);
                    }
                }

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, scriptDir, "mcc", " -R  755 ", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                GenerateReleaseTxtFile(definition, partNumber, scriptDir);


                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "release.txt", "777", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);
                if (!(buildPackageHelper.CreateSquashIMGFileSystem(cygwinPath, scriptDir, sourcePath, "mcc.img", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "mcc.img", "700", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);

                string tzgFileName = "mcc_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, finalMCCPath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building MCC package");
                return finalMCCPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error build MCC package: " + ex.Message) ;
                return ex.Message;
            }
        }

        /// <summary>
        /// Method to create a TGZ file for MMC package
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="currentTask"></param>
        /// <returns></returns>
        private async Task<string> BuildMCNTPackage(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venuNextScriptExtractPath)
        {
            //get the time zone .dta file from azure storage
            //form the the directory sctructure and create .img file and form the direct structure
            try
            {
                await environment.UpdateDetailedStatus("Started to build MCNT package");
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;

                var venueScriptPath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.VenueNextscripts).ToLower()).Select(x => x.Path).FirstOrDefault();
                //var mccBasePath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.content3daircraftmodels).ToLower()).Select(x => x.Path).FirstOrDefault();
                
                if (string.IsNullOrWhiteSpace(venuNextScriptExtractPath))

                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mcnt)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string sourcePath = environment.GetOutputPath() + @"\MCNT";
                string finalMCNTPath = environment.GetOutputPath() + @"\MCNTgz";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalMCNTPath))
                    Directory.Delete(finalMCNTPath, true);
                Directory.CreateDirectory(finalMCNTPath);

                //Create version text file and Change permission for version.txt
                string message;
                GeneratVersionTxtFile(definition, partNumber, sourcePath);
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version.txt", "644", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string scriptDir = sourcePath + "\\mcnt";
                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);
                Directory.CreateDirectory(scriptDir);

                var mccOutputPath = Path.Combine(scriptDir, "mcnt.zip");
                //mcc file from cloud
                //if (!string.IsNullOrWhiteSpace(mccBasePath))
                //{
                //    DownloadData(environment, mccBasePath, mccOutputPath);
                //    buildPackageHelper.zipFileExtractor(mccOutputPath, scriptDir, true);
                //}


                //get install.sh and clean.sh from Venue_Next_Data under custom content from azure
                if (!string.IsNullOrWhiteSpace(venuNextScriptExtractPath))
                {
                    if (Directory.Exists(venuNextScriptExtractPath + "\\mcnt"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venuNextScriptExtractPath + "\\mcnt", scriptDir);
                    }
                }

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, scriptDir, "mcnt", " -R  755 ", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                GenerateReleaseTxtFile(definition, partNumber, scriptDir);


                //Set the access for the files
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "release.txt", "777", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);
                if (!(buildPackageHelper.CreateSquashIMGFileSystem(cygwinPath, scriptDir, sourcePath, "mcnt.img", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "mcnt.img", "700", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);

                string tzgFileName = "mcnt_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, finalMCNTPath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building MCNT package");
                return finalMCNTPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building MCNT package: " + ex.Message);
                return ex.Message;
            }
        }

        private async Task<string> PackageMmobileccdb(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venuNextScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build MmobileCC package");
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;

                var mMobileBasePath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.mmobileccconfiguration)).Select(x => x.Path).FirstOrDefault();
                var content3daircraftmodels = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.content3daircraftmodels)).Select(x => x.Path).FirstOrDefault();
                var mobileconfigurationplatform = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.mobileconfigurationplatform)).Select(x => x.Path).FirstOrDefault();
                var fontsPath= categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.FontData)).Select(x => x.Path).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(venuNextScriptExtractPath) || string.IsNullOrWhiteSpace(mMobileBasePath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mmobilecc)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string sourcePath = environment.GetOutputPath() + @"\Mmobilecc";
                string finalMMobileCCPath = environment.GetOutputPath() + @"\MmobileccTZ";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalMMobileCCPath))
                    Directory.Delete(finalMMobileCCPath, true);
                Directory.CreateDirectory(finalMMobileCCPath);

                //Create version text file
                GeneratVersionTxtFile(definition, partNumber, sourcePath);
                //Change permission for version.txt

                string message;
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version.txt", "644", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string mMobileCC = sourcePath + "\\mmobileccc";
                if (Directory.Exists(mMobileCC))
                    Directory.Delete(mMobileCC, true);
                Directory.CreateDirectory(mMobileCC);

                string scriptDir = mMobileCC + "\\ipadconfig";
                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);
                Directory.CreateDirectory(scriptDir);
                //create ipadxml into scriptDir

                var mobileccOutputPath = Path.Combine(scriptDir, "ipadconfig.zip");
                var mobileconfigurationplatformOutputPath = Path.Combine(mMobileCC, "Mobile_Config_Data.zip");

                //TODO check ipadconfig table and use if exist or else condition
                //if (!string.IsNullOrEmpty(mobileconfigurationplatform))
                //{
                //    DownloadData(environment, mobileconfigurationplatform, mobileconfigurationplatformOutputPath);

                //    var afterZipExtract = buildPackageHelper.zipFileExtractor(mobileconfigurationplatformOutputPath);
                //    buildPackageHelper.CopyFilesRecursively(afterZipExtract, mMobileCC);
                //    Directory.Delete(Path.Combine(mMobileCC, "Mobile_Config_Data"), true);
                //    File.Delete(mobileconfigurationplatformOutputPath);
                //}
                //else
                //{
                    GenerateIPadConfigXML(environment, definition, mMobileCC, "/asxig/config/ipad/ipadconfig.zip");
                //}

                // generate Release txt file and change access of the file.
                GenerateReleaseTxtFile(definition, partNumber, mMobileCC);

                // Mmobile CC download
                if (!string.IsNullOrEmpty(mMobileBasePath))
                {
                    DownloadData(environment, mMobileBasePath, mobileccOutputPath);
                    buildPackageHelper.zipFileExtractor(mobileccOutputPath, scriptDir, true);
                    var asxiDirectory = scriptDir + "\\asxi";
                    var configDirectory = asxiDirectory + "\\config";
                    if (!Directory.Exists(configDirectory))
                    {
                        Directory.CreateDirectory(configDirectory);
                    }

                    if (File.Exists(configDirectory + "\\custom.xml"))
                    {
                        File.Delete(configDirectory + "\\custom.xml");
                    }
                    await GenerateCustomXML(environment, configDirectory);

                    var contentDirectory = asxiDirectory + "\\web\\content";
                    if (!Directory.Exists(contentDirectory))
                    {
                        Directory.CreateDirectory(contentDirectory);
                    }
                    var directory_3d = contentDirectory + "\\3d";
                    if (!Directory.Exists(directory_3d))
                    {
                        Directory.CreateDirectory(directory_3d);
                        DownloadData(environment, content3daircraftmodels, directory_3d + "\\Aircraft_Models_Data.zip");
                        var tempDirectory = directory_3d + "\\temp_3d";
                        buildPackageHelper.zipFileExtractor(directory_3d + "\\Aircraft_Models_Data.zip", tempDirectory, true);

                        if (Directory.Exists(tempDirectory + "\\map_images") && Directory.Exists(directory_3d + "\\map_images"))
                            Directory.Move(tempDirectory + "\\map_images", directory_3d + "\\map_images");

                        if (Directory.Exists(tempDirectory + "\\models") && Directory.Exists(directory_3d + "\\models"))
                            Directory.Move(tempDirectory + "\\models", directory_3d + "\\models");

                        Directory.Delete(tempDirectory, true);

                        //get the images
                        await GetConfigImages(environment, directory_3d, ImageType.Logo);
                        await GetConfigImages(environment, directory_3d, ImageType.Splash);
                        await GetConfigImages(environment, directory_3d, ImageType.Script, true);

                    }
                    //Font .ttf files copy
                    if (!string.IsNullOrEmpty(fontsPath))
                    {
                        var fontDirectory = directory_3d + "\\fonts";
                        if (!Directory.Exists(fontDirectory))
                        {
                            Directory.CreateDirectory(fontDirectory);
                        }

                        ExtractFontFiles(environment, buildPackageHelper, fontsPath, directory_3d, fontDirectory);
                    }

                    var modalDirectory = directory_3d + "\\models";
                    if (!Directory.Exists(modalDirectory))
                    {
                        Directory.CreateDirectory(modalDirectory);
                    }

                    var mapImagesDirectory = directory_3d + "\\map_images";
                    if (!Directory.Exists(mapImagesDirectory))
                    {
                        Directory.CreateDirectory(mapImagesDirectory);
                    }

                    var dataDirectory = directory_3d + "\\data";
                    if (!Directory.Exists(dataDirectory))
                    {
                        Directory.CreateDirectory(dataDirectory);
                    }


                    var dbDirectory = dataDirectory + "\\db";
                    if (!Directory.Exists(dbDirectory))
                    {
                        Directory.CreateDirectory(dbDirectory);
                    }

                    TaskDevelopmentExport taskDevelopmentExport = new TaskDevelopmentExport();
                    if (!File.Exists(environment.TempStoragePath + "/asxinfo.sqlite3.sql"))
                    {
                        await taskDevelopmentExport.GenerateASXInfoDatabase(environment, environment.CurrentTask.ConfigurationID);
                    }
                    string asxinfo = Directory.EnumerateFiles(environment.TempStoragePath, "asxinfo.sqlite3.sql", SearchOption.AllDirectories).First();
                    if (!string.IsNullOrWhiteSpace(asxinfo))
                    {
                        File.Copy(asxinfo, dbDirectory + @"\\asxinfo.sqlite3.sql");
                    }

                    var mapImageDirectory = dataDirectory + "\\map";
                    if (!Directory.Exists(mapImageDirectory))
                    {
                        Directory.CreateDirectory(mapImageDirectory);
                    }
                    //get the mod list json file and place it here
                    List<ModListData> listModlistData = await context.Repositories.ConfigurationRepository.GetModlistData(definition.ConfigurationId, false);
                    int fileCount = 0;
                    listModlistData.ForEach(modlist => {
                        int resolution = modlist.Resolution;
                        var modListResolutionDirectory = mapImageDirectory + "\\" + resolution;
                        if (!Directory.Exists(modListResolutionDirectory))
                        {
                            Directory.CreateDirectory(modListResolutionDirectory);
                        }
                        if (modListResolutionDirectory.Contains(resolution.ToString()))
                        {
                            var fileDirectory = modListResolutionDirectory + "\\" + modlist.Row;
                            if (!Directory.Exists(fileDirectory))
                            {
                                Directory.CreateDirectory(fileDirectory);
                                fileCount = 0;
                            }
                            string fileName = "t" + resolution + "_" + modlist.Row + "_" + fileCount + ".json";
                            StreamWriter jsonStreaWriter = File.CreateText(fileDirectory + "\\" + fileName);
                            jsonStreaWriter.WriteLine(modlist.FileJSON);
                            jsonStreaWriter.Flush();
                            jsonStreaWriter.Close();
                            fileCount++;
                        }
                    });
                }

                buildPackageHelper.CreateZipFile(scriptDir, scriptDir + ".zip");

                //get install.sh and clean.sh from Venue_Next_Data under custom content from azure
                if (!string.IsNullOrWhiteSpace(venuNextScriptExtractPath))
                {
                    if (Directory.Exists(venuNextScriptExtractPath + "\\mmobilecc"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venuNextScriptExtractPath + "\\mmobilecc", mMobileCC);
                    }
                }
               
                

                //Set the access for the files
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, mMobileCC, "release.txt", "777", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                if (!(buildPackageHelper.CreateSquashIMGFileSystem(cygwinPath, mMobileCC, sourcePath, "mmobilecc.img", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                // change access for .img file.
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "mmobilecc.img", "700", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                if (Directory.Exists(mMobileCC))
                    Directory.Delete(mMobileCC, true);

                //Create version text file
                GeneratVersionTxtFile(definition, partNumber, sourcePath);
				// Change permission for the file
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version.txt", "644", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string tzgFileName = "mmobilecc_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, finalMMobileCCPath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building MmobileCC package");
                return finalMMobileCCPath;
            }
            catch (Exception ex)

            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building MmobileCC package: " + ex.Message);
                return ex.Message;
            }
        }

        private static void ExtractFontFiles(TaskEnvironment environment, BuildPackageHelper buildPackageHelper, string fontsPath, string directory_3d, string fontDirectory)
        {
            var tempFont = directory_3d + "\\temp_font";
            if (!Directory.Exists(tempFont))
            {
                Directory.CreateDirectory(tempFont);
            }
            DownloadData(environment, fontsPath, tempFont + "\\Font_Data.zip");
            buildPackageHelper.zipFileExtractor(tempFont + "\\Font_Data.zip", tempFont, true);
            var filesToCopy = Directory.EnumerateFiles(tempFont, "*.ttf", SearchOption.AllDirectories);
            foreach (var file in filesToCopy)
            {
                File.Copy(file, Path.Combine(fontDirectory, Path.GetFileName(file)));
            }
            if (Directory.Exists(tempFont))
            {
                Directory.Delete(tempFont, true);
            }
        }

        private void GenerateIPadConfigXML(TaskEnvironment environment, Configuration definition, string destinationFolder, string ipadZipPath, bool isVenuHybrid = false)
        {
            XmlDocument doc = new XmlDocument();
            XmlDeclaration xmlDeclaration = doc.CreateXmlDeclaration("1.0", "UTF-8", "yes");
            XmlElement root = doc.DocumentElement;
            doc.InsertBefore(xmlDeclaration, root);
            XmlElement element1 = doc.CreateElement("ipad");
            XmlElement element2 = doc.CreateElement("data");
            element2.SetAttribute("enabled", "true");
            element2.SetAttribute("broadcast", "true");

            XmlElement element3 = doc.CreateElement("cfg");
            //TODO get the value from feature set for protocol
            if (isVenuHybrid)
                element3.SetAttribute("protocol", "ftp");
            else
                element3.SetAttribute("protocol", "http");

            element3.SetAttribute("dirpath", ipadZipPath);
            element3.SetAttribute("version", definition.ConfigurationDefinitionId.ToString() + "-" + definition.Version.ToString());
            element3.SetAttribute("customPN", "false");

            element1.AppendChild(element2);
            element1.AppendChild(element3);
            doc.AppendChild(element1);
            doc.Save(destinationFolder + "\\ipadconfig.xml");
        }

        private async Task GetConfigImages(TaskEnvironment environment, string directory_3d, ImageType imageType, bool userOriginalFileName=false)
        {
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;

            var images = await context.Repositories.CustomContentRepository.GetConfigImages(environment.CurrentTask.ConfigurationID, (int)imageType);

            var selectedImage = images.Where(x => x.IsSelected).ToList();
            if (selectedImage.Count > 0)
            {
                foreach (var image in selectedImage)
                {
                    var imageResolutions = await context.Repositories.CustomContentRepository.PreviewImages(environment.CurrentTask.ConfigurationID, image.ImageId, (int)ImageType.Logo);
                    foreach (var resol in imageResolutions)
                    {
                        var resolDirectory = directory_3d + "\\" + resol.ResolutionValue;
                        if (!Directory.Exists(resolDirectory))
                            Directory.CreateDirectory(resolDirectory);

                        var imageDirectory = resolDirectory + "\\images";
                        var phoneDirectory = resolDirectory + "\\phone\\Images";

                        if (!Directory.Exists(imageDirectory))
                            Directory.CreateDirectory(imageDirectory);

                        if (!Directory.Exists(phoneDirectory))
                            Directory.CreateDirectory(phoneDirectory);

                        var fileName = imageType.ToString().ToLower();
                        if (userOriginalFileName)
                            fileName = Path.GetFileNameWithoutExtension(image.ImageName);
                        var extn = Path.GetExtension(image.ImageName);

                        DownloadData(environment, resol.ImageURL, imageDirectory + "\\" + string.Concat(fileName, extn), true);
                        File.Copy(imageDirectory + "\\" + string.Concat(fileName, extn), phoneDirectory + "\\" + string.Concat(fileName, extn));
                    }
                }
            }
        }

        private async Task<string> PackageMdatadb(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venueNextScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build Mdata package");
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                if (string.IsNullOrWhiteSpace(venueNextScriptExtractPath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                string sourcePath = environment.GetOutputPath() + @"\Mdata";
                string finalTzPath = environment.GetOutputPath() + @"\MdataTZ";

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.mdata)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalTzPath))
                    Directory.Delete(finalTzPath, true);
                Directory.CreateDirectory(finalTzPath);

                //Create version text file Change permission for version.txt
                GeneratVersionTxtFile(definition, partNumber, sourcePath);
                string message;
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version.txt", "644", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string stringScriptDir = sourcePath + "\\mdata";
                if (Directory.Exists(stringScriptDir))
                    Directory.Delete(stringScriptDir, true);
                Directory.CreateDirectory(stringScriptDir);

                //get install.sh and clean.sh from Venue_Next_Data under custom content from azure
                if (!string.IsNullOrWhiteSpace(venueNextScriptExtractPath))
                {
                    if (Directory.Exists(venueNextScriptExtractPath + "\\mdata"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venueNextScriptExtractPath + "\\mdata", stringScriptDir);
                    }
                }

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, stringScriptDir, "mdata", " -R  755 ", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                //generate release.txt file
                GenerateReleaseTxtFile(definition, partNumber, stringScriptDir);
                
                //Set the access for the files
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, stringScriptDir, "release.txt", "777", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string stringdataDirectory = Path.Combine(stringScriptDir, "data");
                if (Directory.Exists(stringdataDirectory))
                    Directory.Delete(stringdataDirectory, true);
                Directory.CreateDirectory(stringdataDirectory);

                string stringdbDirectory = Path.Combine(stringdataDirectory, "db");
                if (Directory.Exists(stringdbDirectory))
                    Directory.Delete(stringdbDirectory, true);
                Directory.CreateDirectory(stringdbDirectory);

                //generate asxinfo.sqlite3, asxwg.sqlite3 and asxairport.sqlite3 files
                await GenerateASXIInfoDB(environment, stringdbDirectory);
                await GenerateASXIAirportDB(environment, stringdbDirectory);
                await GenerateASXIWgDB(environment, stringdbDirectory);

                string asxinfo = Directory.EnumerateFiles(environment.GetOutputPath(), "asxinfo.sqlite3", SearchOption.AllDirectories).First();
                string asxwg = Directory.EnumerateFiles(environment.GetOutputPath(), "asxwg.sqlite3", SearchOption.AllDirectories).First();
                string asxairport = Directory.EnumerateFiles(environment.GetOutputPath(), "asxairport.sqlite3", SearchOption.AllDirectories).First();

                if (!string.IsNullOrWhiteSpace(asxinfo))
                {
                    File.Move(asxinfo, Path.Combine(stringdbDirectory, "asxinfo.sqlite3"));
                }
                if (!string.IsNullOrWhiteSpace(asxwg))
                {
                    File.Move(asxwg, Path.Combine(stringdbDirectory, "asxwg.sqlite3"));
                }
                if (!string.IsNullOrWhiteSpace(asxairport))
                {
                    File.Move(asxairport, Path.Combine(stringdbDirectory, "asxairport.sqlite3"));
                }

                environment.Logger.LogInfo(message);
                if (!(buildPackageHelper.CreateSquashIMGFileSystem(cygwinPath, stringScriptDir, sourcePath, "mdata.img", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "mdata.img", "700", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                if (Directory.Exists(stringScriptDir))
                    Directory.Delete(stringScriptDir, true);

                string tgzfilepath = finalTzPath;
                string tzgFileName = "mdata_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, tgzfilepath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Mdata package");
                return finalTzPath;
            }

            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building Mdata package " + ex.Message);
                return ex.Message;
            }
        }

        private async Task<string> PackageMinsetsDB(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, List<ASXiInset> insets, string venueNextScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build Minsets package");
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;

                if (string.IsNullOrWhiteSpace(venueNextScriptExtractPath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueNextPartNumberCollection.minsets)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string sourcePath = environment.GetOutputPath() + @"\Minsets";
                string finalMinsetsPath = environment.GetOutputPath() + @"\MinsetsTgz";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalMinsetsPath))
                    Directory.Delete(finalMinsetsPath, true);
                Directory.CreateDirectory(finalMinsetsPath);

                //Create version text file and Change permission for version.txt
                string message;
                GeneratVersionTxtFile(definition, partNumber, sourcePath);
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version.txt", "644", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string scriptDir = sourcePath + "\\minsets";
                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);
                Directory.CreateDirectory(scriptDir);

                //get install.sh and clean.sh from Venue_Next_Data under collins admin assets from azure
                if (!string.IsNullOrWhiteSpace(venueNextScriptExtractPath))
                {
                    if (Directory.Exists(venueNextScriptExtractPath + "\\minsets"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venueNextScriptExtractPath + "\\minsets", scriptDir);
                    }
                }

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, scriptDir, "minsets", " -R  755 ", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                //generate release.txt file
                GenerateReleaseTxtFile(definition, partNumber, scriptDir);

                var temInsetsDir = Path.Combine(scriptDir, "teminsets");
                if (Directory.Exists(temInsetsDir))
                    Directory.Delete(temInsetsDir, true);
                Directory.CreateDirectory(temInsetsDir);

                //generate temdescription.xml file
                GenerateTemDescriptionXML(insets, temInsetsDir);

                //get insets from azure
                await DownloadInsets(environment, insets, temInsetsDir);

                //Set the access for the files
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "release.txt", "777", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);
                if (!(buildPackageHelper.CreateSquashIMGFileSystem(cygwinPath, scriptDir, sourcePath, "minsets.img", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "minsets.img", "700", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);

                string tzgFileName = "minsets_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, finalMinsetsPath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Minsets package");
                return finalMinsetsPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building Minsets package: " + ex.Message);
                return ex.Message;
            }
        }



        private void GenerateTemDescriptionXML(List<ASXiInset> asxiInsets, string destinationFolder)
        {
            try
            {
                if (asxiInsets != null && asxiInsets.Count > 0)
                {
                    XmlDocument doc = new XmlDocument();
                    XmlDeclaration xmlDeclaration = doc.CreateXmlDeclaration("1.0", "UTF-8", "yes");
                    XmlElement root = doc.DocumentElement;
                    doc.InsertBefore(xmlDeclaration, root);
                    XmlElement temMapPackage = doc.CreateElement("tem_map_package");
                    temMapPackage.SetAttribute("name", "teminsets");
                    temMapPackage.SetAttribute("quality", "80");
                    //Filter ASXiInsets based on the Resolution/Zoom level
                    var groupedASXiInsets = asxiInsets.GroupBy(x => x.Zoom);
                    //Generate xml as defined in https://alm.rockwellcollins.com/wiki/display/ASXIW/Insets
                    foreach (var asxiInsetsPerResolution in groupedASXiInsets)
                    {
                        var res = asxiInsetsPerResolution.Key;
                        //TODO: Get Resolution related Data either from db or constants
                        //w and h are the full width of the map in pixels at the specified resolution
                        //For Res 15, below are the values and the tem w and h attributes will double for each increase in resolution.
                        int w = 2593660;
                        int h = 1296830;
                        //tile_w and tile_h are the width and height of each tile, should always be 512
                        //excludenorth_deg and excludesouth_deg are the number of degrees from each pole that the insets ignore, should always be "5.0"
                        XmlElement tem = doc.CreateElement("tem");
                        tem.SetAttribute("res", res.ToString());
                        tem.SetAttribute("w", ((15 / res) * w).ToString());
                        tem.SetAttribute("h", ((15 / res) * h).ToString());
                        tem.SetAttribute("tile_w", "512");
                        tem.SetAttribute("tile_h", "512");
                        tem.SetAttribute("excludenorth_deg", "5.0");
                        tem.SetAttribute("excludesouth_deg", "5.0");
                        XmlElement insets = doc.CreateElement("insets");
                        foreach (var asxiInset in asxiInsetsPerResolution)
                        {
                            //Create inset elements
                            XmlElement inset = doc.CreateElement("inset");
                            inset.SetAttribute("name", asxiInset.InsetName);
                            inset.SetAttribute("row_st", asxiInset.RowStart.ToString());
                            inset.SetAttribute("row_end", asxiInset.RowEnd.ToString());
                            inset.SetAttribute("col_st", asxiInset.ColStart.ToString());
                            inset.SetAttribute("col_end", asxiInset.ColEnd.ToString());
                            inset.SetAttribute("lat_st", asxiInset.LatStart.ToString());
                            inset.SetAttribute("lon_st", asxiInset.LongStart.ToString());
                            inset.SetAttribute("lat_end", asxiInset.LatEnd.ToString());
                            inset.SetAttribute("lon_end", asxiInset.LongEnd.ToString());
                            inset.SetAttribute("is_hf", asxiInset.IsHf.ToString());
                            inset.SetAttribute("partNum", "");
                            inset.InnerText = asxiInset.Cdata;
                            insets.AppendChild(inset);
                        }
                        tem.AppendChild(insets);
                        temMapPackage.AppendChild(tem);
                    }
                    doc.AppendChild(temMapPackage);
                    doc.Save(destinationFolder + "\\TemDescription.xml");
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        private async Task DownloadInsets(TaskEnvironment environment, List<ASXiInset> asxiInsets, string temInsetsDir)
        {
            try
            {
                if (asxiInsets != null && asxiInsets.Count > 0)
                {
                    BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                    foreach (ASXiInset inset in asxiInsets)
                    {
                        if (!string.IsNullOrEmpty(inset.Path))
                        {
                            //format inset/image download dir as t(resolution)
                            string insetsOutPath = Path.Combine(temInsetsDir, "t" + inset.Zoom.ToString() + ".zip");
                            string container = environment.GetAzureContainerforHiFocusMapInsets();
                            string connectString = environment.GetAzureConnectionString();
                            //get only the BlobName
                            string insetBlobName = AzureFileHelper.getBlobNameFromURL(inset.Path);
                            await AzureFileHelper.DownloadFromBlob(connectString, container, insetsOutPath, insetBlobName);
                            buildPackageHelper.zipFileExtractor(insetsOutPath, true);
                            File.Delete(insetsOutPath);
                        }
                    }
                }
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        private string GetDescriptionFromEnum(Enum value)
        {
            DescriptionAttribute attribute = value.GetType()
            .GetField(value.ToString())
            .GetCustomAttributes(typeof(DescriptionAttribute), false)
            .SingleOrDefault() as DescriptionAttribute;
            return attribute == null ? value.ToString() : attribute.Description;
        }

        private static void GeneratVersionTxtFile(Configuration definition, string partNumer, string resourcePath)
        {
            StreamWriter oStreamWriter = File.CreateText(resourcePath + "\\version.txt");
            oStreamWriter.WriteLine("Part#: " + partNumer);
            oStreamWriter.WriteLine("Version: " + definition.Version);
            oStreamWriter.Flush();
            oStreamWriter.Close();
        }

        private static void GeneratVersionContentTxtFile(Configuration definition, string partNumer, string sourcePath, string name)
        {
            StreamWriter oStreamWriter = File.CreateText(sourcePath + "\\version_" + name + ".txt");
            oStreamWriter.WriteLine("rc.partnumber: " + partNumer);
            oStreamWriter.WriteLine("rc.buildnumber: " + definition.Version);
            oStreamWriter.Flush();
            oStreamWriter.Close();
        }
        private static  void CreateMd5TextFile(string resourceDirectories)
        {

            string[] Files = Directory.GetFiles(resourceDirectories, "*.*", SearchOption.AllDirectories);
            StreamWriter oStreamWriter = File.CreateText(resourceDirectories + "\\md5sum.txt");
            oStreamWriter.NewLine = "\n";
            foreach (string Filename in Files)
            {
                string Md5Code = MD5HashingHelper.GetMd5Hash(Filename);
                string DirectoryAndFilename = Filename.Replace(resourceDirectories, ".").Replace('\\', '/');
                oStreamWriter.WriteLine(Md5Code + "  " + DirectoryAndFilename);
            }
            oStreamWriter.Flush();
            oStreamWriter.Close();
        }


        /// <summary>
        /// Method to create CII files for Venue next build after tgz files is created.
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="definition"></param>
        /// <param name="sourceFolder"></param>
        /// <param name="tgzFilePath"></param>
        /// <param name="partNumber"></param>
        /// <param name="packageType"></param>
        private void CreateCII(TaskEnvironment environment, string versionNumber, string sourceFolder, string fileName, string partNumber, string packageType)
        {
            try
            {
                string ciiJarPath = Path.GetFullPath(environment.GetLocalAssetPath("bin\\AddSignatureToCII\\addsignature.jar"));
                var cygwinPath = Path.GetFullPath(environment.GetLocalAssetPath("bin\\cygwin"));

                Process myProcess = new Process();
                myProcess.StartInfo.FileName = cygwinPath + "\\bin\\bash.exe";
                myProcess.StartInfo.WorkingDirectory = cygwinPath + "/bin/";
                myProcess.StartInfo.UseShellExecute = false;
                myProcess.StartInfo.RedirectStandardOutput = true;
                myProcess.StartInfo.CreateNoWindow = true;
                myProcess.StartInfo.RedirectStandardError = true;
                myProcess.StartInfo.ErrorDialog = true;
                string arg = String.Format("--login -i \"{0}\\assets\\bin\\create-cii.sh\" \"{1}\" \"{2}\" \"{3}\" \"{4}\" \"{5}\" \"{6}\" ",
                Directory.GetCurrentDirectory(), Path.GetFullPath(sourceFolder), fileName, ciiJarPath, partNumber, versionNumber, packageType);
                environment.UpdateDetailedStatus("CII Args " +arg.ToString());
                myProcess.StartInfo.Arguments = arg.ToString();
                myProcess.Start();
                myProcess.OutputDataReceived += (object sender, DataReceivedEventArgs e) =>
                environment.Logger.LogInfo("output>>" + e.Data);
                myProcess.BeginOutputReadLine();

                myProcess.ErrorDataReceived += (object sender, DataReceivedEventArgs e) =>
                environment.Logger.LogInfo("error >>" + e.Data);
                myProcess.BeginErrorReadLine();
                myProcess.WaitForExit();
                environment.Logger.LogInfo("CII generated for " + packageType + " in the path " + sourceFolder);
            }
            catch (Exception ex)
            {
                environment.Logger.LogError(ex.Message);
                throw;
            }
        }

        /// <summary>
        /// Method to calculate the row and column for the JSON files to be stored in.
        /// </summary>
        /// <param name="lat"></param>
        /// <param name="lon"></param>
        /// <param name="resolution"></param>
        /// <param name="landSatType"></param>
        /// <returns></returns>
        private ModListData ModlistCalculator(float lat, float lon, int resolution, string landSatType)
        {
            ModListData modListData = new ModListData();

            double landSatValue = landSatType.ToLower() == "temlandsat7" ? 1801.15273775 : 1851.99396180872;
            double tile_height = 512.0;
            double tile_width = 512.0;
            double degrees_per_minute = landSatValue * 60.0;
            modListData.Row = Math.Floor(((((-1 * lat) + 90.0) * degrees_per_minute) / resolution) / tile_height);
            modListData.Col = Math.Floor((((lon + 180.0) * degrees_per_minute) / resolution) / tile_width);
            modListData.Resolution = resolution;
            return modListData;
        }

        /// <summary>
        /// Method to insert all data in the modlist JSON to datatable
        /// </summary>
        /// <param name="modlist"></param>
        /// <param name="resolution"></param>
        /// <param name="landSatValue"></param>
        /// <returns></returns>
        private DataTable CreateModListDataTable(List<ModListJSON> modLists, List<string> resolutions, string landSatValue)
        {
            int id = 0;
            DataTable modListDataTable = new DataTable();
            modListDataTable.Columns.Add("Id", typeof(int));
            modListDataTable.Columns.Add("FileJSON", typeof(string));
            modListDataTable.Columns.Add("Row", typeof(int));
            modListDataTable.Columns.Add("Col", typeof(int));
            modListDataTable.Columns.Add("Resolution", typeof(int));

            ModListPOI newModListPOI = new ModListPOI();
            newModListPOI.POI = new POI();
            newModListPOI.POI.Airports = new List<ModListJSON>();
            newModListPOI.POI.Cities = new List<ModListJSON>();
            newModListPOI.POI.LandFeatures = new List<ModListJSON>();
            newModListPOI.POI.WaterFeatures = new List<ModListJSON>();

            string json = string.Empty;

            resolutions.ForEach(resolution =>
            {
                modLists.ForEach(modlist =>
                {

                    ModListData modListData = ModlistCalculator(modlist.Lat, modlist.Lon, int.Parse(resolution), landSatValue);
                    id++;
                    if (modlist.Cat == 8)
                    {
                        ModListJSON jSON = new ModListJSON();
                        jSON.Id = modlist.Id;
                        jSON.Lat = modlist.Lat;
                        jSON.Lon = modlist.Lon;
                        jSON.Pri = modlist.Pri;
                        jSON.IPOI = modlist.IPOI;
                        jSON.Cat = modlist.Cat;
                        jSON.Name = modlist.Name.Split(",")[0];

                        if (modListDataTable.Rows.Count > 0)
                        {
                            modListDataTable = CheckIfDataExists(modListDataTable, id, jSON, modListData.Row, modListData.Col, modListData.Resolution);
                        }
                        else
                        {
                            newModListPOI.POI.LandFeatures.Add(jSON);
                            json = JsonConvert.SerializeObject(newModListPOI);
                            modListDataTable.Rows.Add(id, json.Trim(), modListData.Row, modListData.Col, modListData.Resolution);
                        }
                    }
                    else if (modlist.Cat == 7)
                    {
                        ModListJSON jSON = new ModListJSON();
                        jSON.Id = modlist.Id;
                        jSON.Lat = modlist.Lat;
                        jSON.Lon = modlist.Lon;
                        jSON.Pri = modlist.Pri;
                        jSON.IPOI = modlist.IPOI;
                        jSON.Cat = modlist.Cat;
                        jSON.Name = modlist.Name.Split(",")[0];

                        if (modListDataTable.Rows.Count > 0)
                        {
                            modListDataTable = CheckIfDataExists(modListDataTable, id, jSON, modListData.Row, modListData.Col, modListData.Resolution);
                        }
                        else
                        {
                            newModListPOI.POI.WaterFeatures.Add(jSON);
                            json = JsonConvert.SerializeObject(newModListPOI);
                            modListDataTable.Rows.Add(id, json.Trim(), modListData.Row, modListData.Col, modListData.Resolution);

                        }
                    }
                    else if (modlist.Cat == 9)
                    {
                        ModListJSON jSON = new ModListJSON();
                        jSON.Id = modlist.Id;
                        jSON.Lat = modlist.Lat;
                        jSON.Lon = modlist.Lon;
                        jSON.Pri = modlist.Pri;
                        jSON.IPOI = modlist.IPOI;
                        jSON.Cat = modlist.Cat;
                        jSON.Name = modlist.Name.Split(",")[0];

                        if (modListDataTable.Rows.Count > 0)
                        {
                            modListDataTable = CheckIfDataExists(modListDataTable, id, jSON, modListData.Row, modListData.Col, modListData.Resolution);
                        }
                        else
                        {
                            newModListPOI.POI.Airports.Add(jSON);
                            json = JsonConvert.SerializeObject(newModListPOI);
                            modListDataTable.Rows.Add(id, json.Trim(), modListData.Row, modListData.Col, modListData.Resolution);
                        }
                    }
                    else
                    {
                        ModListJSON jSON = new ModListJSON();
                        jSON.Id = modlist.Id;
                        jSON.Lat = modlist.Lat;
                        jSON.Lon = modlist.Lon;
                        jSON.Pri = modlist.Pri;
                        jSON.IPOI = modlist.IPOI;
                        jSON.Cat = modlist.Cat;
                        jSON.Name = modlist.Name.Split(",")[0];

                        if (modListDataTable.Rows.Count > 0)
                        {
                            modListDataTable = CheckIfDataExists(modListDataTable, id, jSON, modListData.Row, modListData.Col, modListData.Resolution);
                        }
                        else
                        {
                            newModListPOI.POI.Cities.Add(jSON);
                            json = JsonConvert.SerializeObject(newModListPOI);
                            modListDataTable.Rows.Add(id, json.Trim(), modListData.Row, modListData.Col, modListData.Resolution);
                        }
                    }
                });
            });
            return modListDataTable;
        }

        /// <summary>
        /// Check if the data exisits in the data table if exisits update it if not add new entry in the datatype
        /// </summary>
        /// <param name="modListDataTable"></param>
        /// <param name="id"></param>
        /// <param name="modListJSON"></param>
        /// <param name="row"></param>
        /// <param name="col"></param>
        /// <param name="resolution"></param>
        /// <returns></returns>
        private DataTable CheckIfDataExists(DataTable modListDataTable, int id, ModListJSON modListJSON, double row, double col, double resolution)
        {
            ModListPOI newModListPOI = new ModListPOI();
            newModListPOI.POI = new POI();
            newModListPOI.POI.Airports = new List<ModListJSON>();
            newModListPOI.POI.Cities = new List<ModListJSON>();
            newModListPOI.POI.LandFeatures = new List<ModListJSON>();
            newModListPOI.POI.WaterFeatures = new List<ModListJSON>();

            string json = string.Empty;
            bool isAdded = false;
            foreach (DataRow dataRow in modListDataTable.Rows)
            {
                if (dataRow["Row"].ToString() == row.ToString() && dataRow["Col"].ToString() == col.ToString() && dataRow["Resolution"].ToString() == resolution.ToString())
                {
                    var jsonData = dataRow["FileJSON"].ToString();
                    ModListPOI modList = JsonConvert.DeserializeObject<ModListPOI>(jsonData);

                    if (modListJSON.Cat == 7)
                    {
                        modList.POI.WaterFeatures.Add(modListJSON);
                    }
                    else if (modListJSON.Cat == 8)
                    {
                        modList.POI.LandFeatures.Add(modListJSON);
                    }
                    else if (modListJSON.Cat == 9)
                    {
                        modList.POI.Airports.Add(modListJSON);
                    }
                    else
                    {
                        modList.POI.Cities.Add(modListJSON);
                    }

                    json = JsonConvert.SerializeObject(modList);
                    dataRow["FileJSON"] = json.Trim();
                    isAdded = true;
                    break;
                }
            }
            if (!isAdded)
            {
                if (modListJSON.Cat == 7)
                {
                    newModListPOI.POI.WaterFeatures.Add(modListJSON);
                }
                else if (modListJSON.Cat == 8)
                {
                    newModListPOI.POI.LandFeatures.Add(modListJSON);
                }
                else if (modListJSON.Cat == 9)
                {
                    newModListPOI.POI.Airports.Add(modListJSON);
                }
                else
                {
                    newModListPOI.POI.Cities.Add(modListJSON);
                }
                json = JsonConvert.SerializeObject(newModListPOI);
                modListDataTable.Rows.Add(id, json.Trim(), row, col, resolution);
            }
            return modListDataTable;
        }

        private async void UpdateDataFromDataTable (TaskEnvironment environment, DataTable dataTable)
        {
            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
            context.Repositories.ConfigurationRepository.UpdateModListData(environment.CurrentTask.ConfigurationID, dataTable);
            await context.SaveChanges();
        }

        private async Task GenerateVersionUpdateReport(TaskEnvironment environment, int configurationID, Guid CurrentUserID)
        {
            var uOfWork = environment.NewUnitOfWork();
            try
            {
                using var context = uOfWork.Create;
                var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationID);
                if (definition == null)
                {
                    environment.Logger.LogError("Invalid Configuration..!");
                    return;
                }
                var result = await context.Repositories.ConfigurationRepository.GetVersionUpdates(configurationID);
                string tempStorage = environment.GetOutputPath();
                string excelPath = Path.Combine(tempStorage, "VersionUpdates");
                if(result.Tables.Count == 2)
                {
                    {
                        CreateExcel(result, excelPath, definition.Version);
                    }
                }
                else
                {
                    environment.Logger.LogError("No Version Updates data available..!");
                    return;
                }
                //build as a single zip file and upload to blob storage
                if (Directory.Exists(excelPath) && Directory.GetFiles(excelPath, "*.xlsx").Length > 0)
                {
                    ZipFile.CreateFromDirectory(excelPath, excelPath + ".zip");
                    Directory.Delete(excelPath, true);
                    string containerName = environment.GetAzureBlobStorageContainerforVersionUpdates();
                    string connectionString = environment.GetAzureConnectionString();

                    if (connectionString == null || containerName == null)
                    {
                        environment.Logger.LogInfo("invalid azure configuration, skipping upload");
                    }
                    else
                    {
                        string blobName = definition.ConfigurationDefinitionId + "\\" + configurationID + "\\" + "VersionUpdates.zip";
                        environment.Logger.LogInfo("uploading to " + blobName);
                        await AzureFileHelper.UploadBlob(connectionString, containerName, blobName, excelPath + ".zip");
                        if (Directory.Exists(tempStorage))
                        {
                            Directory.Delete(tempStorage, true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = "Failed to generate Version Update Report";
                throw;
            }

        }

        private void CreateExcel(DataSet versionUpdates, string excelPath, int version)
        {
            using (XLWorkbook wb = new XLWorkbook())
            {
                DataTable configUpdatesTable = versionUpdates.Tables[0];
                if (configUpdatesTable.Rows.Count > 0)
                {
                    List<DataTable> result = configUpdatesTable.AsEnumerable().GroupBy(row => row.Field<string>("ContentType")).Select(g => g.CopyToDataTable()).ToList();
                    foreach (DataTable dt in result)
                    {
                        if (dt.Rows.Count > 0)
                        {
                            DataRow dr = dt.Rows[0];
                            string contentType = dr["ContentType"].ToString();
                            string[] columns = dt.Columns.OfType<DataColumn>().Where(c => c.ColumnName != "ContentType" && c.ColumnName != "ContentID").Select(c => c.ColumnName).ToArray();
                            //Remove TableName field
                            DataTable resultTable = new DataView(dt).ToTable(false, columns);
                            var ws = wb.Worksheets.Add(resultTable, contentType);
                            ws.Table(0).ShowAutoFilter = false;// Disable AutoFilter
                            ws.Table(0).Theme = XLTableTheme.None;// Remove Theme
                            ws.Row(1).Style.Font.Bold = true;
                            ws.Columns().AdjustToContents();// Resize all columns
                        }
                    }
                }
                DataTable releaseNotesTable = versionUpdates.Tables[1];
                if(releaseNotesTable.Rows.Count > 0)
                {
                    var ws = wb.Worksheets.Add(releaseNotesTable, "ReleaseNotes");
                    ws.Position = 1;
                    ws.Table(0).ShowAutoFilter = false;// Disable AutoFilter
                    ws.Table(0).Theme = XLTableTheme.None;// Remove Theme
                    ws.Row(1).Style.Font.Bold = true;
                    ws.Column(1).Width = 35;
                    ws.Row(2).Style.Alignment.WrapText = true;
                }
                //Save wb to temp path
                if (!Directory.Exists(excelPath))
                {
                    System.IO.Directory.CreateDirectory(excelPath);
                }
                wb.SaveAs(Path.Combine(excelPath, "V" + version.ToString() + ".xlsx"));
            }
        }

        /// <summary>
        /// 1. Method to create tgz files for the HD AudioVideoBriefings packages
        /// 2. This method will work for both audio/video briefings content and audio/video briefings config.
        /// 3. Based on input parameter audioVideoBriefingDataType , it will decide which data to be used for tgz creation.
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="categories"></param>
        /// <param name="definition"></param>
        /// <param name="partNumbers"></param>
        /// <param name="audioVideoBriefingDataType"></param>
        /// <returns></returns>
        private async Task<string> PackageAudioVideoBriefingsHd(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string audioVideoBriefingDataType)
        {

            try
            {
                await environment.UpdateDetailedStatus("Started to build Audio Video Briefings HD package");
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var audioVideoBriefingsBasePath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.Briefingsconfiguration)).Select(x => x.Path).FirstOrDefault();
                if (string.IsNullOrWhiteSpace(audioVideoBriefingsBasePath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = "";
                if (audioVideoBriefingDataType.ToLower() == "hdbrfcnt")
                {
                    partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.hdbrfcnt)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                }
                else if (audioVideoBriefingDataType.ToLower() == "hdbrfcfg")
                {
                    partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.hdbrfcfg)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                }

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string sourcePath = environment.GetOutputPath() + @"\" + audioVideoBriefingDataType;
                string finalAudioVideoBriefingsPath = environment.GetOutputPath() + @"\" + audioVideoBriefingDataType + "tgz";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalAudioVideoBriefingsPath))
                    Directory.Delete(finalAudioVideoBriefingsPath, true);
                Directory.CreateDirectory(finalAudioVideoBriefingsPath);

                //Create version_content text file and change the permission as required
                string message;
                if (audioVideoBriefingDataType.ToLower() == "hdbrfcnt")
                {
                    GeneratVersionContentTxtFile(definition, partNumber, sourcePath, "content");
                }
                else if (audioVideoBriefingDataType.ToLower() == "hdbrfcfg")
                {
                    GeneratVersionContentTxtFile(definition, partNumber, sourcePath, "config");
                }
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version_content.txt", "644", out message))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }


                string audioVideoBriefingsOutputPath = Path.Combine(sourcePath, "Briefing_HD.zip");
                if (!string.IsNullOrWhiteSpace(sourcePath))
                {
                    DownloadData(environment, audioVideoBriefingsBasePath, audioVideoBriefingsOutputPath);

                    buildPackageHelper.zipFileExtractor(audioVideoBriefingsOutputPath, sourcePath, true);
                }

                string[] directories = Directory.GetDirectories(sourcePath, ".",
                                             SearchOption.AllDirectories);

                directories.ToList().ForEach(directory =>
                {
                    if (audioVideoBriefingDataType.ToLower() == "hdbrfcnt" && directory.ToLower().Contains("content"))
                    {
                        packageHelper.CopyFilesRecursively(directory, sourcePath);
                    }
                    else if (audioVideoBriefingDataType.ToLower() == "hdbrfcfg" && directory.ToLower().Contains("config"))
                    {
                        packageHelper.CopyFilesRecursively(directory, sourcePath);
                    }
                });

                Directory.Delete(directories[0], true);
                Directory.Delete(directories[1], true);

                string tzgFileName = finalAudioVideoBriefingsPath + ".tgz";
                if (audioVideoBriefingDataType.ToLower() == "hdbrfcnt")
                {
                    tzgFileName = "hdbrfcnt_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                }

                else if (audioVideoBriefingDataType.ToLower() == "hdbrfcfg")
                {
                    tzgFileName = "hdbrfcfg_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                }

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, finalAudioVideoBriefingsPath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Audio Video Briefings HD package");
                return finalAudioVideoBriefingsPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                environment.Logger.LogError("Exception raised stack trace: " + ex.StackTrace);
                await environment.UpdateDetailedStatus("Error building Audio Video Briefings HD package");
                return ex.Message;
            }
        }

        /// <summary>
        /// 1. Method to create tgz files for the map Insets packages
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="categories"></param>
        /// <param name="definition"></param>
        /// <param name="partNumbers"></param>
        /// <param name="insets"></param>
        /// <param name="venueHybridScriptExtractPath"></param>
        /// <returns></returns>
        private async Task<string> PackageMinsetsForVenueHybrid(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, List<ASXiInset> insets, string venueHybridScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build Minsets package");
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;

                if (string.IsNullOrWhiteSpace(venueHybridScriptExtractPath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.minsets)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string sourcePath = environment.GetOutputPath() + @"\Minsets";
                string finalMinsetsPath = environment.GetOutputPath() + @"\MinsetsTgz";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalMinsetsPath))
                    Directory.Delete(finalMinsetsPath, true);
                Directory.CreateDirectory(finalMinsetsPath);

                //Create version text file and Change permission for version.txt
                string message;
                GeneratVersionTxtFile(definition, partNumber, sourcePath);
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version.txt", "644", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                string scriptDir = sourcePath + "\\minsets";
                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);
                Directory.CreateDirectory(scriptDir);

                //get install.sh and clean.sh from Venue_Next_Data under collins admin assets from azure
                if (!string.IsNullOrWhiteSpace(venueHybridScriptExtractPath))
                {
                    if (Directory.Exists(venueHybridScriptExtractPath + "\\minsets"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venueHybridScriptExtractPath + "\\minsets", scriptDir);
                    }
                }

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, scriptDir, "minsets", " -R  755 ", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                //generate release.txt file
                GenerateReleaseTxtFile(definition, partNumber, scriptDir);

                var temInsetsDir = Path.Combine(scriptDir, "teminsets");
                if (Directory.Exists(temInsetsDir))
                    Directory.Delete(temInsetsDir, true);
                Directory.CreateDirectory(temInsetsDir);

                //generate temdescription.xml file
                GenerateTemDescriptionXML(insets, temInsetsDir);

                //get insets from azure
                await DownloadInsets(environment, insets, temInsetsDir);

                //Set the access for the files
                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "release.txt", "777", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);
                if (!(buildPackageHelper.CreateSquashIMGFileSystem(cygwinPath, scriptDir, sourcePath, "minsets.img", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                environment.Logger.LogInfo(message);

                if (!(buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "minsets.img", "700", out message)))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }

                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);

                string tzgFileName = "minsets_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, finalMinsetsPath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Minsets package");
                return finalMinsetsPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building Minsets package: " + ex.Message);
                return ex.Message;
            }
        }
		
		private async Task<string> BuildMmcdpPackage(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venueHybridScriptExtractPath)
        {
            //get the time zone .dta file from azure storage
            try
            {
                await environment.UpdateDetailedStatus("Started building MMCDP package");
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var tzBasePath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.TimezoneDatabaseconfiguration)).Select(x => x.Path).FirstOrDefault();
                if (string.IsNullOrWhiteSpace(venueHybridScriptExtractPath) || string.IsNullOrWhiteSpace(tzBasePath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridBuildTypeEnum.mmcdp)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }
                string resourcePathName = "mmcdp_" + partNumber + "_" + definition.Version;
                string tzgFileName = "mmcdp_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                string resourcePath = environment.GetOutputPath() + @"\mmcdp";
                string finalTzPath = environment.GetOutputPath() + @"\mmcdpTZ";

                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);
                Directory.CreateDirectory(resourcePath);

                if (Directory.Exists(finalTzPath))
                    Directory.Delete(finalTzPath, true);
                Directory.CreateDirectory(finalTzPath);

                //Create Release text file
                GenerateVenueHybridReleaseTxtFile(definition, partNumber, resourcePath);
                
               
                string message;
                var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                var tzdbaseoutputPath = Path.Combine(resourcePath, "tzdbase.zip");
                
                string stringConfigDirectory = resourcePath + "\\config";
                if (Directory.Exists(stringConfigDirectory))
                    Directory.Delete(stringConfigDirectory, true);
                Directory.CreateDirectory(stringConfigDirectory);


                //tzdbase
                if (!string.IsNullOrWhiteSpace(tzBasePath))
                {
                    DownloadData(environment, tzBasePath, tzdbaseoutputPath);
                    buildPackageHelper.zipFileExtractor(tzdbaseoutputPath, stringConfigDirectory, true);
                }

                if (!string.IsNullOrWhiteSpace(venueHybridScriptExtractPath))
                {
                    if (Directory.Exists(venueHybridScriptExtractPath + "\\customdata"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venueHybridScriptExtractPath + "\\customdata", resourcePath );
                    }
                }
                //creates a MD5Sum Text File
                CreateMd5TextFile(resourcePath);

                buildPackageHelper.CreateTGZ(resourcePath, tzgFileName, Path.GetFullPath(finalTzPath));
                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);

                await environment.UpdateDetailedStatus("Completed building MMCDP package");
                return finalTzPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                environment.CurrentTask.TaskStatusID = 3;
                await environment.UpdateDetailedStatus("Error building MMCDP package: " + ex.Message);
                return ex.Message;
            }
            
        }

        private async Task<string> BuildBlueMarblePackage(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venueHybridScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build Blue Marble package");
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var mapPackage = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.MapPackageBlueMarble).ToLower()).Select(x => x.Path).FirstOrDefault();
                var mapPackageBorderless = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.MapPackageBorderlessBlueMarble).ToLower()).Select(x => x.Path).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(venueHybridScriptExtractPath) || (string.IsNullOrWhiteSpace(mapPackage) && string.IsNullOrWhiteSpace(mapPackageBorderless)))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridBuildTypeEnum.bmp)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string resourcePathName = "bmp_" + partNumber + "_" + definition.Version;
                string tzgFileName = "bmp_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                string resourcePath = environment.GetOutputPath() + @"\bmp";
                string finalTzPath = environment.GetOutputPath() + @"\bmpTGZ";
                var mapPackageBorderOutput = Path.Combine(resourcePath, "tembmborders.zip");
                var mapPackageBorderlessOutput = Path.Combine(resourcePath, "tembmborderless.zip");

                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);
                Directory.CreateDirectory(resourcePath);

                if (Directory.Exists(finalTzPath))
                    Directory.Delete(finalTzPath, true);
                Directory.CreateDirectory(finalTzPath);

                //Create Release text file
                GenerateVenueHybridReleaseTxtFile(definition, partNumber, resourcePath);

                // Download the data for borders folder
                if (!string.IsNullOrWhiteSpace(mapPackage))
                {
                    DownloadData(environment, mapPackage, mapPackageBorderOutput);
                    buildPackageHelper.zipFileExtractor(mapPackageBorderOutput, resourcePath, true);
                }

                // Download the data for bordersless folder
                if (!string.IsNullOrWhiteSpace(mapPackageBorderless))
                {
                    DownloadData(environment, mapPackageBorderless, mapPackageBorderlessOutput);
                    buildPackageHelper.zipFileExtractor(mapPackageBorderlessOutput, resourcePath, true);
                }

                // place venue hybrid script
                if (!string.IsNullOrWhiteSpace(venueHybridScriptExtractPath))
                {
                    if (Directory.Exists(venueHybridScriptExtractPath + "\\bluemarble"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venueHybridScriptExtractPath + "\\bluemarble", resourcePath);
                    }
                }

                //creates a MD5Sum Text File
                CreateMd5TextFile(resourcePath);

                buildPackageHelper.CreateTGZ(resourcePath, tzgFileName, Path.GetFullPath(finalTzPath));
                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Blue Marble package");
                return finalTzPath;

            }
            catch (Exception ex)
            {
                await environment.UpdateDetailedStatus("Error building Blue Marble package: " + ex.Message);
                return ex.Message;
            }
        }

        private async Task<string> BuildMmdbpPackage(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers, string venueHybridScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build MMDBP package");
                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                if (string.IsNullOrWhiteSpace(venueHybridScriptExtractPath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                string resourcePath = environment.GetOutputPath() + @"\Mmdbp";
                string finalTzPath = environment.GetOutputPath() + @"\MmdbpTZ";

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmdbp)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);
                Directory.CreateDirectory(resourcePath);

                if (Directory.Exists(finalTzPath))
                    Directory.Delete(finalTzPath, true);
                Directory.CreateDirectory(finalTzPath);


                string stringdataDirectory = Path.Combine(resourcePath, "data");
                if (Directory.Exists(stringdataDirectory))
                    Directory.Delete(stringdataDirectory, true);
                Directory.CreateDirectory(stringdataDirectory);

                string stringdbDirectory = Path.Combine(stringdataDirectory, "db");
                if (Directory.Exists(stringdbDirectory))
                    Directory.Delete(stringdbDirectory, true);
                Directory.CreateDirectory(stringdbDirectory);

                //get contents from directory installation scripts - Venue Hybrid
                if (!string.IsNullOrWhiteSpace(venueHybridScriptExtractPath))
                {
                    if (Directory.Exists(venueHybridScriptExtractPath + "\\data"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venueHybridScriptExtractPath + "\\data", resourcePath);
                    }
                }

                //generate release.txt file
                GenerateReleaseTxtFile(definition, partNumber, resourcePath);

                //generate asxnet.sql and asxnet.sqlite3 files
                await GenerateASXNetDatabase(environment, stringdbDirectory);

                string asxnet = Directory.EnumerateFiles(environment.TempStoragePath, "asxnet.sql", SearchOption.AllDirectories).First();
                string asxnetSqlite = Directory.EnumerateFiles(environment.TempStoragePath, "asxnet.sqlite3", SearchOption.AllDirectories).First();

                if (!string.IsNullOrWhiteSpace(asxnet))
                {
                    File.Move(asxnet, Path.Combine(stringdbDirectory, "asxnet.sql"));
                }
                if (!string.IsNullOrWhiteSpace(asxnetSqlite))
                {
                    File.Move(asxnetSqlite, Path.Combine(stringdbDirectory, "asxnet.sqlite3"));
                }

                string tgzfilepath = finalTzPath;
                string tzgFileName = "mmdbp_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                //creates a MD5Sum Text File
                CreateMd5TextFile(resourcePath);

                buildPackageHelper.CreateTGZ(resourcePath, tzgFileName, Path.GetFullPath(tgzfilepath));
                if (Directory.Exists(resourcePath))
                    Directory.Delete(resourcePath, true);

                await environment.UpdateDetailedStatus("Completed building MMDBP package");
                return finalTzPath;
            }

            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building MMDBP package");
                return ex.Message;
            }
        }

        #endregion


        /// <summary>
        /// 1. Method to create tgz files for the AudioVideoBriefings packages
        /// 2. This method will work for both audio/video briefings content and audio/video briefings config.
        /// 3. Based on input parameter audioVideoBriefingDataType , it will decide which data to be used for tgz creation.
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="currentTask"></param>
        /// <param name="audioVideoBriefingDataType"></param>
        /// <returns></returns>
        private async Task<string> PackageAudioVideoBriefingsNonHd(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories,Configuration definition, List<BuildDefaultPartnumber> partNumbers, string audioVideoBriefingDataType)
        {

            try
            {
                await environment.UpdateDetailedStatus("Started to build Audio Video Briefings package");
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();

                var audioVideoBriefingsBasePath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.BriefingsNonHd).ToLower()).Select(x => x.Path).FirstOrDefault();
                if (string.IsNullOrWhiteSpace(audioVideoBriefingsBasePath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = "";
                if (audioVideoBriefingDataType.ToLower() == "audiovideobriefingcnt")
                {
                    partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.avb)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                }
                else if (audioVideoBriefingDataType.ToLower() == "audiovideobriefingcfg")
                {
                    partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.brfcfg)).Select(x => x.DefaultPartNumber).FirstOrDefault();
                }

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }

                string sourcePath = environment.GetOutputPath() + @"\" + audioVideoBriefingDataType;
                string finalAudioVideoBriefingsPath = environment.GetOutputPath() + @"\" + audioVideoBriefingDataType + "tgz";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalAudioVideoBriefingsPath))
                    Directory.Delete(finalAudioVideoBriefingsPath, true);
                Directory.CreateDirectory(finalAudioVideoBriefingsPath);

                //Create version_content text file and change the permission as required
                string message;
                if (audioVideoBriefingDataType.ToLower() == "audiovideobriefingcnt")
                {
                    GeneratVersionContentTxtFile(definition, partNumber, sourcePath, "content");
                }
                else if (audioVideoBriefingDataType.ToLower() == "audiovideobriefingcfg")
                {
                    GeneratVersionContentTxtFile(definition, partNumber, sourcePath, "config");
                }
                    var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
                if (!buildPackageHelper.ChangeFileAccess(cygwinPath, sourcePath, "version_content.txt", "644", out message))
                {
                    environment.Logger.LogError(message);
                    throw new Exception(message);
                }
                

                string audioVideoBriefingsOutputPath = Path.Combine(sourcePath, "Briefing_HD.zip");
                if (!string.IsNullOrWhiteSpace(sourcePath))
                {
                    DownloadData(environment, audioVideoBriefingsBasePath, audioVideoBriefingsOutputPath);

                    buildPackageHelper.zipFileExtractor(audioVideoBriefingsOutputPath, sourcePath, true);
                }

                string[] directories = Directory.GetDirectories(sourcePath, ".",
                                             SearchOption.AllDirectories);

                directories.ToList().ForEach(directory =>
                {
                    if (audioVideoBriefingDataType.ToLower() == "audiovideobriefingcnt" && directory.ToLower().Contains("content"))
                    {
                        packageHelper.CopyFilesRecursively(directory, sourcePath);
                    }
                    else if (audioVideoBriefingDataType.ToLower() == "audiovideobriefingcfg" && directory.ToLower().Contains("config"))
                    {
                        packageHelper.CopyFilesRecursively(directory, sourcePath);
                    }
                });

                Directory.Delete(directories[0], true);
                Directory.Delete(directories[1], true);

                string tzgFileName = finalAudioVideoBriefingsPath + ".tgz";
                if (audioVideoBriefingDataType.ToLower() == "audiovideobriefingcnt")
                {
                    tzgFileName = "avb_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                }

                else if (audioVideoBriefingDataType.ToLower() == "audiovideobriefingcfg")
                {
                    tzgFileName = "brfcfg_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                }

                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, finalAudioVideoBriefingsPath);
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Audio Video Briefings package");
                return finalAudioVideoBriefingsPath;
            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building Audio Video package: " + ex.Message);
                return ex.Message;
            }
        }

        private static void GeneratContentVersionTxtFile(Configuration definition, string partNumer, string buildDirecotry)
        {
            StreamWriter oStreamWriter = File.CreateText(buildDirecotry + "\\release.txt");
            oStreamWriter.WriteLine("Date : " + DateTime.Now.ToString());
            oStreamWriter.WriteLine("Customer Config Part Number: " + partNumer);
            oStreamWriter.WriteLine("Configuration Tool Version : " + definition.Version);
            oStreamWriter.WriteLine("Package Part Number: " + partNumer + "_" + definition.Version);
            oStreamWriter.Flush();
            oStreamWriter.Close();
        }


        private async Task<string> PackageContent(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers,string venueHybridScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build Content package");
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;

                var contentHtse1280x720Path = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.ContentHtse1280x720).ToLower()).Select(x => x.Path).FirstOrDefault();
                var standard3dPath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.ContentASXI3Standard3d).ToLower()).Select(x => x.Path).FirstOrDefault();
                var aircraft3DPath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.ContentASXI3AircraftModals).ToLower()).Select(x => x.Path).FirstOrDefault();
                var mapPackagePath = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.MapPackageBlueMarble).ToLower()).Select(x => x.Path).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(contentHtse1280x720Path) ||
                    string.IsNullOrWhiteSpace(standard3dPath) || string.IsNullOrWhiteSpace(aircraft3DPath))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmcntp)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }
                string tzgFileName = "mmcntp_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";

                string sourcePath = environment.GetOutputPath() + @"\mmcntp";
                string finalContentPath = environment.GetOutputPath() + @"\mmcntpTgz";


                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalContentPath))
                    Directory.Delete(finalContentPath, true);
                Directory.CreateDirectory(finalContentPath);

                string contentDirectory = sourcePath + @"\content";
                if (Directory.Exists(contentDirectory))
                    Directory.Delete(contentDirectory, true);
                Directory.CreateDirectory(contentDirectory);

                string asxiMapsDirectory = contentDirectory + @"\asxmaps";
                if (Directory.Exists(asxiMapsDirectory))
                    Directory.Delete(asxiMapsDirectory, true);
                Directory.CreateDirectory(asxiMapsDirectory);

                //installation scripts

                if (!string.IsNullOrWhiteSpace(venueHybridScriptExtractPath))
                {
                    if (Directory.Exists(venueHybridScriptExtractPath + "\\Content"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venueHybridScriptExtractPath + "\\Content", sourcePath);
                    }
                }
                //release.txt

                GenerateVenueHybridReleaseTxtFile(definition, partNumber, sourcePath);

                //Generate xml for NightMapWorld*.xml,TimeZoneMap*.xml,World*.xml,TemGlobalData.xml,t*.xml

                if (!string.IsNullOrEmpty(mapPackagePath))
                {
                    var tempFolder = environment.GetOutputPath() + @"\MapPackage";
                    if (Directory.Exists(tempFolder))
                        Directory.Delete(tempFolder, true);
                    Directory.CreateDirectory(tempFolder);

                    DownloadData(environment, mapPackagePath, tempFolder + @"\Mappackage.zip");

                    buildPackageHelper.zipFileExtractor(tempFolder + @"\Mappackage.zip", tempFolder, true);

                    if (Directory.Exists(tempFolder + "\\tembmborders"))
                    {
                        await GenerateWorldLevelXML(environment, asxiMapsDirectory, tempFolder + "\\tembmborders");

                    }

                    //TemGlobalDataGenerateWorldLevelXML
                    await GenerateTemGlobalData(environment, asxiMapsDirectory, "TemGlobalData.xml", definition);
                    if (Directory.Exists(tempFolder))
                        Directory.Delete(tempFolder, true);


                }

                string _1280_720DirectoryOutputPath = Path.Combine(sourcePath, " _1280_720.zip");
                if (!string.IsNullOrWhiteSpace(sourcePath))
                {
                    DownloadData(environment, contentHtse1280x720Path, _1280_720DirectoryOutputPath);

                    buildPackageHelper.zipFileExtractor(_1280_720DirectoryOutputPath, contentDirectory, true);
                    var aircraftDirectory = contentDirectory + "\\1280x720\\images\\map_aircraft";
                    if (Directory.Exists(aircraftDirectory))
                    {
                        //extract all tz to folders
                        DirectoryInfo directoryInfo = new DirectoryInfo(aircraftDirectory); 
                        FileInfo[] files = directoryInfo.GetFiles("*.tar");
                        foreach (var file in files)
                        {
                            if (File.Exists(file.FullName))
                            {
                                buildPackageHelper.tarFileExtractor(file.FullName);
                                File.Delete(file.FullName);
                            }
                        }
                    }
                }

                string _3dDirectory = contentDirectory;

                string _3dDirectoryOutputPath = Path.Combine(sourcePath, "_3d.zip");
                if (!string.IsNullOrWhiteSpace(sourcePath))
                {
                    DownloadData(environment, standard3dPath, _3dDirectoryOutputPath);

                    buildPackageHelper.zipFileExtractor(_3dDirectoryOutputPath, contentDirectory, true);
                }

                //if (!Directory.Exists(_3dDirectory + @"\3d")) 
                //{
                //    Directory.CreateDirectory(_3dDirectory + @"\3d");
                //} else
                //{
                //    _3dDirectory = Path.GetFullPath(_3dDirectory + @"\3d");
                //}
                //string _3dModalDirectory = _3dDirectory + @"\models";
               

                //string _3dModalDirectoryOutputPath = Path.Combine(sourcePath, "_3dModal.zip");
                //if (!string.IsNullOrWhiteSpace(sourcePath))
                //{
                //    DownloadData(environment, aircraft3DPath, _3dModalDirectoryOutputPath);

                //    buildPackageHelper.zipFileExtractor(_3dModalDirectoryOutputPath, _3dModalDirectory, true);
                //}
                //buildPackageHelper.CreateZip(scriptDir);
                CreateMd5TextFile(sourcePath);
                

                //md5sum for sourcePath


                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, Path.GetFullPath(finalContentPath));
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Content package");
                return finalContentPath;
            }
            catch(Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building Content package: " + ex.Message);
                return ex.Message;
            }
        }


        private async Task GenerateWorldLevelXML(TaskEnvironment environment, string path, string imageFolderPath)
        {


            string[] tileFileNames = System.IO.Directory.GetFiles(imageFolderPath, "*.jpg");

            foreach (var tileName in tileFileNames)
            {
                Bitmap bitmap = new Bitmap(tileName);

                string stringPoiRecords = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n";
                stringPoiRecords += string.Format("<temtile w=\"{0}\" h=\"{1}\">\r\n<poi_records>\r\n",
                    bitmap.Width,
                    bitmap.Height);
                string worldXml = await PrepareWroldXML(environment, tileName);
                if (!string.IsNullOrWhiteSpace(worldXml))
                {
                    stringPoiRecords += worldXml;
                    stringPoiRecords += "</poi_records>\r\n</temtile>";

                    string stringMapFilename = Path.GetFileName(tileName.ToLower());

                    string stringTmp = stringMapFilename.Replace(".jpg", ".xml");

                    XDocument doc = XDocument.Parse(stringPoiRecords);
                    StreamWriter output = environment.OpenWriter(path + @"\" + stringTmp);
                    output.Write(doc.ToString());
                    output.Close();
                    output.Dispose();
                    bitmap.Dispose();
                }
            }

        }

        private async Task<string> PrepareWroldXML(TaskEnvironment environment, string tileName)
        {
            XmlDocument xDoc = new XmlDocument();
            try
            {

                XmlNodeList nodes;
                XmlNode xmlnodeMapPlacenames;

                Bitmap bitmap = new Bitmap(tileName);
                Encoding enc = System.Text.ASCIIEncoding.ASCII;
                string stringComment = enc.GetString(bitmap.GetPropertyItem(40092).Value);
                int intIndex1 = stringComment.IndexOf('(') + 1;
                int intIndex2 = stringComment.IndexOf(',');
                float m_floatTileLat1 = (float)Convert.ToDecimal(stringComment.Substring(intIndex1, intIndex2 - intIndex1));
                intIndex1 = stringComment.IndexOf(',') + 1;
                intIndex2 = stringComment.IndexOf(')');
                float m_floatTileLon1 = (float)Convert.ToDecimal(stringComment.Substring(intIndex1, intIndex2 - intIndex1));

                intIndex1 = stringComment.LastIndexOf('(') + 1;
                intIndex2 = stringComment.LastIndexOf(',');
                float m_floatTileLat2 = (float)Convert.ToDecimal(stringComment.Substring(intIndex1, intIndex2 - intIndex1));

                intIndex1 = stringComment.LastIndexOf(',') + 1;
                intIndex2 = stringComment.LastIndexOf(')');
                float m_floatTileLon2 = (float)Convert.ToDecimal(stringComment.Substring(intIndex1, intIndex2 - intIndex1));

                var uOfWork = environment.NewUnitOfWork();
                using var context = uOfWork.Create;
                var configurationId = environment.CurrentTask.ConfigurationID;

                var global = await context.Repositories.Simple<ConfigGlobal>().FirstMappedAsync(environment.CurrentTask.ConfigurationID);
                var exportLanguages = await ExtractLanguages(context, global.Global, environment.CurrentTask.ConfigurationID);

                // to load geo ref id

                var worldMapPlaceNames = await context.Repositories.Simple<ConfigWorldMapPlaceNames>().FirstMappedAsync(configurationId);
                var worldTimeZonePlaceNames = await context.Repositories.Simple<ConfigWorldTimeZonePlaceNames>().FirstMappedAsync(configurationId);

                StringBuilder xmlStr = new StringBuilder();
                if (worldTimeZonePlaceNames != null && tileName.Contains("timezone"))
                {
                    xmlStr.Append(worldTimeZonePlaceNames.PlaceNames);
                }
                else if (worldMapPlaceNames != null && !tileName.Contains("timezone"))
                {
                    xmlStr.Append(worldMapPlaceNames.PlaceNames);
                }
                else
                {
                    bitmap.Dispose();
                    return string.Empty;
                }
                xDoc.LoadXml(xmlStr.ToString());
                if (!tileName.Contains("timezone"))
                    xmlnodeMapPlacenames = xDoc.SelectSingleNode("world_map_placenames");
                else
                    xmlnodeMapPlacenames = xDoc.SelectSingleNode("world_timezone_placenames");

                nodes = xmlnodeMapPlacenames.SelectNodes("comment()");
                foreach (XmlNode n in nodes)
                    xmlnodeMapPlacenames.RemoveChild(n);

                // Get asxi/worldmap_cities/city
                nodes = xmlnodeMapPlacenames.SelectNodes("city");
                List<string> listGeoRef = new List<string>();
                if (nodes != null)
                {
                    foreach (XmlNode n in nodes)
                    {
                        listGeoRef.Add(n.InnerText);
                    }
                }
                float floatYPixelPoint = 0;
                float floatXPixelPoint = 0;
                float floatTileLatPoint = 0;
                float floatTileLonPoint = 0;

                PointF pointTopLeftLonLat = new PointF(m_floatTileLon1, m_floatTileLat1);
                PointF pointBotLeftLonLat = new PointF(m_floatTileLon2, m_floatTileLat2);

                float floatTileLonCoverage = 0;
                if (pointTopLeftLonLat.X > pointBotLeftLonLat.X)
                    floatTileLonCoverage = pointTopLeftLonLat.X - pointBotLeftLonLat.X;
                else
                    floatTileLonCoverage = pointBotLeftLonLat.X - pointTopLeftLonLat.X;

                float floatTileLatCoverage = 0;
                if (pointTopLeftLonLat.Y > pointBotLeftLonLat.Y)
                    floatTileLatCoverage = pointTopLeftLonLat.Y - pointBotLeftLonLat.Y;
                else
                    floatTileLatCoverage = pointBotLeftLonLat.Y - pointTopLeftLonLat.Y;

                floatYPixelPoint = floatTileLatPoint * (bitmap.Height / floatTileLatCoverage);
                floatXPixelPoint = floatTileLonPoint * (bitmap.Width / floatTileLonCoverage);

                bool isWorldMap = false;
                if (360 == (Math.Abs(m_floatTileLon1) + Math.Abs(m_floatTileLon2)) && 180 == (Math.Abs(m_floatTileLat1) + Math.Abs(m_floatTileLat2)))
                    //&& (m_stringOrgWorldMapFilename.Contains("Map") || m_stringOrgWorldMapFilename.Contains("World")))
                    isWorldMap = true;
                else
                    isWorldMap = false;

                int tileRes = 0;
                // Get geo ref with spelling
               
                if (isWorldMap)
                {
                    //Package.m_intTileQuality.ToString()
                    stringComment = enc.GetString(bitmap.GetPropertyItem(40091).Value);
                    intIndex1 = stringComment.IndexOf(':') + 1;
                    intIndex2 = stringComment.IndexOf(' ');
                    tileRes = Convert.ToInt32(stringComment.Substring(intIndex1, intIndex2 - intIndex1));
                }
                else
                {
                    intIndex1 = Path.GetFileName(tileName).LastIndexOf("\\t") + 2;
                    intIndex2 = Path.GetFileName(tileName).IndexOf('_', intIndex1);
                    tileRes = Convert.ToInt32(Path.GetFileName(tileName).Substring(intIndex1, intIndex2 - intIndex1));
                }

                XmlDocument xmlGlobal = new XmlDocument();
                //xmlGlobal.LoadXml(global.Global);
                XDocument tree = XDocument.Parse(global.Global);
                var langNode = tree.Root.Element("language_set");
                var defaultLanguage = langNode.Attribute("default").Value;

                if (!string.IsNullOrEmpty(defaultLanguage))
                {
                    defaultLanguage = exportLanguages.Where(x => x.Name.ToUpper() == defaultLanguage.ToUpper().Substring(1)).FirstOrDefault().TwoLetterID_ASXi;
                }
                StringBuilder poiXML = new StringBuilder();
                var airports = await context.Repositories.AirportInfo.GetExportAllAirports(environment.CurrentTask.ConfigurationID);

                //Dictionary<string, List<FontInfo>> fontsLang = new Dictionary<string, List<FontInfo>>();

                //foreach (var lang in exportLanguages)
                //{
                //    var lstInfo = await context.Repositories.FontConfigurationMappingRepository.GetFontInfoForLangugaeId(lang.LanguageID, 1, tileRes);
                //    fontsLang.Add(lang.Name, lstInfo);
                //}

                using (SqlDataReader reader = await context.Repositories.GeoRefs.GetExportASXI3dGeoRefIds(configurationId, exportLanguages, string.Join(",", listGeoRef)))
                {
                    int? markerId = null;
                    int wgmarkerid = 0;
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            //loop all languages
                            StringBuilder langXML = new StringBuilder();
                            foreach (var lang in exportLanguages)
                            {
                                Dictionary<string, List<FontInfo>> fontsLang = new Dictionary<string, List<FontInfo>>();
                                int geoRefCatTypeId = DbHelper.DBValueToInt(reader["GeoRefIdCatTypeId"]);
                                using var newcontext = uOfWork.Create;
                                var lstInfo = await newcontext.Repositories.FontConfigurationMappingRepository.GetFontInfoForLangugaeId(lang.LanguageID, geoRefCatTypeId, tileRes);
                                fontsLang.Add(lang.Name, lstInfo);
                                var lstFontInfo = fontsLang.Where(x => x.Key == lang.Name).Select(x => x.Value).FirstOrDefault();
                                if (lstFontInfo.Count > 0)
                                {
                                    //foreach (var fontInfo in lstFontInfo)
                                    //{
                                        string m_boolLtToRt = string.Empty;
                                        if (lang.HorizontalScroll == 2)
                                            m_boolLtToRt = "true";
                                        else
                                            m_boolLtToRt = "false";
                                        langXML.AppendFormat("\t\t\t<{0} fontid=\"{1}\" " +
                                        "ltr=\"{2}\">{3}</{4}>\r\n",
                                        lang.TwoLetterID_ASXi.ToLower(),
                                        lstFontInfo[0].FontID,
                                        m_boolLtToRt.ToString().ToLower(),
                                        DbHelper.StringFromDb(reader[lang.TwoLetterID_ASXi]),
                                        lang.TwoLetterID_ASXi.ToLower());
                                        if (markerId == null)
                                            markerId = lstFontInfo[0].FontMarkerIdID;

                                    //}
                                }

                            }
                            int geoRefId = DbHelper.DBValueToInt(reader["geoRefId"]);
                            string lat = DbHelper.DBValueToString(reader["Lat"]);
                            string lon = DbHelper.DBValueToString(reader["Lon"]);
                            poiXML.AppendFormat("\t<poi_record geoid=\"{0}\" x=\"{1}\" y=\"{2}\"" +
                                    " priority=\"{3}\" markerid=\"{4}\" wgmarkerid=\"{7}\" lat=\"{5}\" lon=\"{6}\">\r\n",
                                    geoRefId.ToString(),
                                    Math.Round((decimal)floatXPixelPoint),
                                    Math.Round((decimal)floatYPixelPoint),
                                    Convert.ToString(DbHelper.IntFromDb(reader["Priority"])),
                                    markerId.ToString(),
                                    lat,
                                    lon,
                                    wgmarkerid.ToString());
                            if (!isWorldMap)
                            {
                                //get the airport for the georef id and form the <ap tag
                                var geoAirport = airports.Where(x => x.GeoRefID == geoRefId).ToList();
                                foreach (var airport in geoAirport)
                                {

                                    Point oPointPoi = GetPixPosFromLatLon(new PointF((float)airport.Lon, (float)airport.Lat), tileRes);
                                    Point oPointTileTopLt = GetPixPosFromLatLon(pointTopLeftLonLat, tileRes);
                                    float floatXPxPoint = Math.Abs(oPointPoi.X - oPointTileTopLt.X);
                                    float floatYPxPoint = Math.Abs(oPointPoi.Y - oPointTileTopLt.Y);

                                    poiXML.AppendFormat("\t\t<ap x=\"{0}\" y=\"{1}\" id=\"{2}\"/>\r\n",
                                                floatXPxPoint, floatYPxPoint, airport.FourLetID);
                                }
                            }
                            poiXML.AppendFormat("\t\t<languages def=\"{0}\">\r\n", defaultLanguage.ToLower());
                            poiXML.Append(langXML.ToString());
                            poiXML.Append("\t\t</languages>\r\n\t</poi_record>\r\n");
                        }
                    }
                    bitmap.Dispose();
                }

                return poiXML.ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private Point GetPixPosFromLatLon(PointF oPointF, float floatRes)
        {
            Point oPoint = new Point();

            oPoint.X = (int)Math.Round(((oPointF.X + 180.0) * 3600.0 * (1 / floatRes)));
            oPoint.Y = (int)Math.Round(((oPointF.Y + 90.0) * 3600.0 * (1 / floatRes)));
            return oPoint;
        }


        private async Task GenerateTemGlobalData(TaskEnvironment environment, string path, string fileName, Configuration definition)
        {

            var work = environment.NewUnitOfWork();
            using var context = work.Create;
            var repos = context.Repositories;

            string stringGlobalInfo = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n";
            stringGlobalInfo += "<temglobal>\r\n";
            stringGlobalInfo += "<!--" + "" + "-->\r\n";
            stringGlobalInfo += "<fonts>\r\n\t";
            var stringLangXml = new StringBuilder();
            var global = await repos.Simple<ConfigGlobal>().FirstMappedAsync(environment.CurrentTask.ConfigurationID);

            var exportLanguages = await ExtractLanguages(context, global.Global, environment.CurrentTask.ConfigurationID);
            StringBuilder fontXML = new StringBuilder();
            foreach (var lang in exportLanguages)
            {
                //Getdefault lang data

                var lstFontInfo = await repos.FontConfigurationMappingRepository.GetFontInfoForLangugaeId(lang.LanguageID,1,0);
                if (lstFontInfo.Count>0)
                {
                    foreach (var font in lstFontInfo)
                        fontXML.AppendFormat("<font id=\"{0}\" " +
                                            "face=\"{1}\" size=\"{2}\" px_size=\"{3}\" color=\"{4}\" shdw_color=\"{5}\" style=\"{6}\" " +
                                            "txt_effect=\"{7}\"/>", font.FontID,
                                            font.FaceName, font.Size,
                                            "", font.Color, font.ShadowColor,
                                            font.FontID, "");
                }

                stringLangXml.AppendFormat("\t\t<lang name=\"{0}\" id=\"{1}\" let2=\"{2}\" let3=\"{3}\" hohsvs=\"{4}\"/>\r\n",
                        lang.Name.ToString().ToLower(),
                        lang.LanguageID.ToString(),
                        lang.TwoLetterID_4xxx.ToLower(),
                        lang.TwoLetterID_ASXi.ToLower(),
                        lang.HorizontalOrder.ToString());
            }
            stringGlobalInfo += fontXML.ToString();
            stringGlobalInfo += "\t</fonts>\r\n\t<map_langs>";
            XDocument tree = XDocument.Parse(global.Global);
            stringGlobalInfo += tree.Root.Element("language_set");
            stringGlobalInfo += "</map_langs>\r\n";

            stringGlobalInfo += "\t<langs>\r\n" + stringLangXml.ToString() + "\t</langs>\r\n";

            var marker = await repos.Simple<FontMarker>().FilterMappedAsync(environment.CurrentTask.ConfigurationID);

            StringBuilder sbMarker = new StringBuilder();
            foreach (var mark in marker)
            {
                sbMarker.AppendFormat("\t\t<marker id=\"{0}\">{1}</marker>\r\n", mark.MarkerID, mark.Filename);
            }
            stringGlobalInfo += "\t<markers>\r\n";
            stringGlobalInfo += sbMarker.ToString();
            stringGlobalInfo += "\t</markers>\r\n</temglobal>";

          
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(stringGlobalInfo);
            xmlDocument.Save(path + "\\" + fileName);
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

        private async Task<string> PackageConfig(TaskEnvironment environment, IEnumerable<ConfigurationComponents> categories, Configuration definition, List<BuildDefaultPartnumber> partNumbers,string venueHybridScriptExtractPath)
        {
            try
            {
                await environment.UpdateDetailedStatus("Started to build Config package");
                BuildPackageHelper buildPackageHelper = new BuildPackageHelper();
                var unitOfWork = environment.NewUnitOfWork();
                using var context = unitOfWork.Create;

                var flightDataConfig = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.FlightDataconfiguration)).Select(x => x.Path).FirstOrDefault();
                var acarsConfig = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.ACARSDataconfiguration)).Select(x => x.Path).FirstOrDefault();
                var flightPhaseProfile = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.FlightPhaseconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();
                var flightDeckController = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.FlightDeckconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();
                var siteIdentification = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.SiteIdentificationconfiguration)).Select(x => x.Path).FirstOrDefault();
                var sizesConfig = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.Sizesconfiguration).ToLower()).Select(x => x.Path).FirstOrDefault();
                var timeZone = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.TimezoneDatabaseconfiguration)).Select(x => x.Path).FirstOrDefault();
                var mobileconfigurationplatform = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.mobileconfigurationplatform)).Select(x => x.Path).FirstOrDefault();
                var mMobileBasePath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.mmobileccconfiguration)).Select(x => x.Path).FirstOrDefault();
                var content3daircraftmodels = categories.Where(x => x.Name.ToLower() == GetDescriptionFromEnum(ConfigurationCustomComponentType.ContentASXI3AircraftModals).ToLower()).Select(x => x.Path).FirstOrDefault();
                var fontsPath = categories.Where(x => x.Name == GetDescriptionFromEnum(ConfigurationCustomComponentType.FontData)).Select(x => x.Path).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(flightDataConfig) ||
                    string.IsNullOrWhiteSpace(acarsConfig) || string.IsNullOrWhiteSpace(flightPhaseProfile)
                    || string.IsNullOrWhiteSpace(flightDeckController)
                    || string.IsNullOrWhiteSpace(siteIdentification) || string.IsNullOrWhiteSpace(sizesConfig)
                    || string.IsNullOrWhiteSpace(timeZone))
                {
                    environment.Logger.LogError("Missing required components");
                    throw new Exception("Missing required components");
                }

                var partNumber = partNumbers.Where(x => x.Name == GetDescriptionFromEnum(VenueHybridPartNumberCollection.mmcfgp)).Select(x => x.DefaultPartNumber).FirstOrDefault();

                if (string.IsNullOrWhiteSpace(partNumber))
                {
                    environment.Logger.LogError("Missing required PartNmber");
                    throw new Exception("Missing required PartNmber");
                }
                string tzgFileName = "mmcfgp_" + partNumber + "_" + definition.Version.ToString("D2") + ".tgz";
                string sourcePath = environment.GetOutputPath() + @"\mmcfgp";
                string finalConfigPath = environment.GetOutputPath() + @"\mmcfgpTz";

                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);
                Directory.CreateDirectory(sourcePath);

                if (Directory.Exists(finalConfigPath))
                    Directory.Delete(finalConfigPath, true);
                Directory.CreateDirectory(finalConfigPath);

                //installation scripts

                if (!string.IsNullOrWhiteSpace(venueHybridScriptExtractPath))
                {
                    if (Directory.Exists(venueHybridScriptExtractPath + "\\Config"))
                    {
                        buildPackageHelper.CopyFilesRecursively(venueHybridScriptExtractPath + "\\Config", sourcePath);
                    }
                }
                //release.txt

                GenerateVenueHybridReleaseTxtFile(definition, partNumber, sourcePath);

                string configDirectory = sourcePath + @"\config";
                if (Directory.Exists(configDirectory))
                    Directory.Delete(configDirectory, true);
                Directory.CreateDirectory(configDirectory);


                string flightDataConfigOutputPath = Path.Combine(configDirectory, "flightDataConfig.zip");
                if (!string.IsNullOrWhiteSpace(configDirectory))
                {
                    DownloadData(environment, flightDataConfig, flightDataConfigOutputPath);

                    buildPackageHelper.zipFileExtractor(flightDataConfigOutputPath, configDirectory, true);

                    string acarsOutputPath = Path.Combine(configDirectory, "acarsConfig.zip");

                    DownloadData(environment, acarsConfig, acarsOutputPath);

                    buildPackageHelper.zipFileExtractor(acarsOutputPath, configDirectory, true);


                    string flightPhaseProfileOutputPath = Path.Combine(configDirectory, "flightPhaseProfile.zip");

                    DownloadData(environment, flightPhaseProfile, flightPhaseProfileOutputPath);

                    buildPackageHelper.zipFileExtractor(flightPhaseProfileOutputPath, configDirectory, true);


                    string flightDeckOutputPath = Path.Combine(configDirectory, "flightDeck.zip");

                    DownloadData(environment, flightDeckController, flightDeckOutputPath);

                    buildPackageHelper.zipFileExtractor(flightDeckOutputPath, configDirectory, true);


                    string siteIdOutputPath = Path.Combine(configDirectory, "siteId.zip");

                    DownloadData(environment, siteIdentification, siteIdOutputPath);

                    buildPackageHelper.zipFileExtractor(siteIdOutputPath, configDirectory, true);


                    string sizeConfigOutputPath = Path.Combine(configDirectory, "sizeConfig.zip");

                    DownloadData(environment, sizesConfig, sizeConfigOutputPath);

                    buildPackageHelper.zipFileExtractor(sizeConfigOutputPath, configDirectory, true);

                }

                var dbLanguages = await context.Repositories.Simple<Language>().FilterMappedAsync(environment.CurrentTask.ConfigurationID);
                var defaultLangauge = dbLanguages.Find(item => item.ID == -1);
                if (defaultLangauge != null)
                {
                    dbLanguages.Remove(defaultLangauge);
                }
                ////Custom XML
                await GenerateCustomXML(environment, configDirectory, true);

                //Custom3d xml
                await GenerateCustom3DXML(environment, configDirectory, dbLanguages);

                //InfoSpelling xml
                await GenerateInfoSpellingXML(environment, context, dbLanguages, configDirectory);


                //ipadConfig XML
                GenerateIPadConfigXML(environment, definition, configDirectory, "/ipad/ipadconfig.zip", true);

                //language xml
                await GenerateLanguageXML(environment, context, dbLanguages, configDirectory);

                //tz_*. xml
                await GenerateTZXML(environment, context, dbLanguages, configDirectory);

                //ipad
                string ipadDirectory = configDirectory + @"\ipad";
                if (Directory.Exists(ipadDirectory))
                    Directory.Delete(ipadDirectory, true);
                Directory.CreateDirectory(ipadDirectory);


                string scriptDir = ipadDirectory + "\\ipadconfig";
                if (Directory.Exists(scriptDir))
                    Directory.Delete(scriptDir, true);
                Directory.CreateDirectory(scriptDir);

                //create ipadxml into scriptDir

                var mobileccOutputPath = Path.Combine(scriptDir, "ipadconfig.zip");
                var mobileconfigurationplatformOutputPath = Path.Combine(ipadDirectory, "Mobile_Config_Data.zip");


                if (!string.IsNullOrEmpty(mobileconfigurationplatform))
                {
                    DownloadData(environment, mobileconfigurationplatform, mobileconfigurationplatformOutputPath);

                    var afterZipExtract = buildPackageHelper.zipFileExtractor(mobileconfigurationplatformOutputPath);
                    buildPackageHelper.CopyFilesRecursively(afterZipExtract, ipadDirectory);
                    Directory.Delete(Path.Combine(ipadDirectory, "Mobile_Config_Data"), true);
                    File.Delete(mobileconfigurationplatformOutputPath);
                }
                // generate Release txt file and change access of the file.

                // Mmobile CC download
                if (!string.IsNullOrEmpty(mMobileBasePath))
                {
                    DownloadData(environment, mMobileBasePath, mobileccOutputPath);
                    buildPackageHelper.zipFileExtractor(mobileccOutputPath, scriptDir, true);
                    var iPadConfigDirectory = scriptDir + "\\asxi\\config";
                    if (!Directory.Exists(iPadConfigDirectory))
                    {
                        Directory.CreateDirectory(iPadConfigDirectory);
                    }
                    
                    await GenerateCustomXML(environment, iPadConfigDirectory);
                    
                    var contentDirectory = scriptDir + "\\asxi\\web\\content";
                    if (!Directory.Exists(contentDirectory))
                    {
                        Directory.CreateDirectory(contentDirectory);
                    }
                    var directory_3d = contentDirectory + "\\3d";
                    if (!Directory.Exists(directory_3d))
                    {
                        Directory.CreateDirectory(directory_3d);
                        DownloadData(environment, content3daircraftmodels, directory_3d + "\\Aircraft_Models_Data.zip");
                        var tempDirectory = directory_3d + "\\temp_3d";
                        if (!Directory.Exists(tempDirectory))
                        {
                            Directory.CreateDirectory(tempDirectory);
                        }
                        buildPackageHelper.zipFileExtractor(directory_3d + "\\Aircraft_Models_Data.zip", tempDirectory, true);
                        if (Directory.Exists(tempDirectory + "\\map_images"))
                            Directory.Move(tempDirectory + "\\map_images", directory_3d + "\\map_images");
                        else if (Directory.Exists(tempDirectory + "\\map") && Directory.Exists(directory_3d + "\\map"))
                            Directory.Move(tempDirectory + "\\map", directory_3d + "\\map");

                        Directory.Move(tempDirectory + "\\models", directory_3d + "\\models");
                        Directory.Delete(tempDirectory);

                        //get the images
                        await GetConfigImages(environment, directory_3d, ImageType.Logo);
                        await GetConfigImages(environment, directory_3d, ImageType.Splash);
                        await GetConfigImages(environment, directory_3d, ImageType.Script, true);

                    }

                    //Font .ttf files copy
                    if (!string.IsNullOrEmpty(fontsPath))
                    {
                        var fontDirectory = directory_3d + "\\fonts";
                        if (!Directory.Exists(fontDirectory))
                        {
                            Directory.CreateDirectory(fontDirectory);
                        }

                        ExtractFontFiles(environment, buildPackageHelper, fontsPath, directory_3d, fontDirectory);
                    }
                    //get the images and download it for each resolution in directory_3d

                    var modalDirectory = directory_3d + "\\models";
                    if (!Directory.Exists(modalDirectory))
                    {
                        Directory.CreateDirectory(modalDirectory);
                    }

                    var mapImagesDirectory = directory_3d + "\\map_images";
                    if (!Directory.Exists(mapImagesDirectory))
                    {
                        Directory.CreateDirectory(mapImagesDirectory);
                    }

                    var dataDirectory = directory_3d + "\\data";
                    if (!Directory.Exists(dataDirectory))
                    {
                        Directory.CreateDirectory(dataDirectory);
                    }


                    var dbDirectory = dataDirectory + "\\db";
                    if (!Directory.Exists(dbDirectory))
                    {
                        Directory.CreateDirectory(dbDirectory);
                    }
                    await GenerateASXIInfoDB(environment, dbDirectory);
                    string asxinfo = Directory.EnumerateFiles(environment.TempStoragePath, "asxinfo.sqlite3", SearchOption.AllDirectories).First();
                    if (!string.IsNullOrWhiteSpace(asxinfo))
                    {
                        File.Move(asxinfo, dbDirectory + @"\\asxinfo.sqlite3", true);
                    }

                    var mapImageDirectory = dataDirectory + "\\map";
                    if (!Directory.Exists(mapImageDirectory))
                    {
                        Directory.CreateDirectory(mapImageDirectory);
                    }
                    //get the mod list json file and place it here
                    List<ModListData> listModlistData = await context.Repositories.ConfigurationRepository.GetModlistData(definition.ConfigurationId, false);
                    int fileCount = 0;
                    listModlistData.ForEach(modlist =>
                    {
                        int resolution = modlist.Resolution;
                        var modListResolutionDirectory = mapImageDirectory + "\\" + resolution;
                        if (!Directory.Exists(modListResolutionDirectory))
                        {
                            Directory.CreateDirectory(modListResolutionDirectory);
                        }
                        if (modListResolutionDirectory.Contains(resolution.ToString()))
                        {
                            var fileDirectory = modListResolutionDirectory + "\\" + modlist.Row;
                            if (!Directory.Exists(fileDirectory))
                            {
                                Directory.CreateDirectory(fileDirectory);
                                fileCount = 0;
                            }
                            string fileName = "t" + resolution + "_" + modlist.Row + "_" + fileCount + ".json";
                            StreamWriter jsonStreaWriter = File.CreateText(fileDirectory + "\\" + fileName);
                            jsonStreaWriter.WriteLine(modlist.FileJSON);
                            jsonStreaWriter.Flush();
                            jsonStreaWriter.Close();
                            fileCount++;
                        }
                    });
                }

                buildPackageHelper.CreateZipFile(scriptDir, scriptDir + ".zip");

                //md5sum for sourcePath
                CreateMd5TextFile(sourcePath);
                buildPackageHelper.CreateTGZ(sourcePath, tzgFileName, Path.GetFullPath(finalConfigPath));
                if (Directory.Exists(sourcePath))
                    Directory.Delete(sourcePath, true);

                await environment.UpdateDetailedStatus("Completed building Config package");
                return finalConfigPath;

            }
            catch (Exception ex)
            {
                environment.CurrentTask.ErrorLog = ex.Message.ToString();
                environment.Logger.LogError("Exception raised: " + ex);
                await environment.UpdateDetailedStatus("Error building Config package: " + ex.Message);
                return ex.Message;
            }
        }

        private static async Task GenerateInfoSpellingXML(TaskEnvironment environment, IUnitOfWorkAdapter context, List<Language> dbLanguages, string configDirectory)
        {

            var infoSepllings = await context.Repositories.CustomContentRepository.GetInfoSpelling(environment.CurrentTask.ConfigurationID, dbLanguages);

            StringBuilder stringxml = new StringBuilder();
            stringxml.Append("<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n");
            stringxml.Append("<infospellings>");
            foreach (dynamic infoSpel in infoSepllings)
            {
                var dictinary = (IDictionary<string, object>)infoSpel;
                stringxml.Append("<li id=\""+dictinary["InfoId"]+"\">");


                foreach (var lang in dbLanguages)
                {
                    stringxml.Append("<lan id=\"" + lang.LanguageID + "\" name=\"" + lang.Name + "\">" + dictinary[lang.Name] + "</lan>");
                }

                stringxml.Append("</li>");
            }
            stringxml.Append("</infospellings>");

            XmlDocument doc = new XmlDocument();
            doc.LoadXml(stringxml.ToString());
            doc.Save(configDirectory + "\\infospellings.xml");
        }

        private async Task GenerateLanguageXML(TaskEnvironment environment, IUnitOfWorkAdapter context, List<Language> dbLanguages, string configDirectory)
        {
            StringBuilder stringxml = new StringBuilder();

            var global = await context.Repositories.Simple<ConfigGlobal>().FirstMappedAsync(environment.CurrentTask.ConfigurationID);
            XmlDocument xmlGlobal = new XmlDocument();
            xmlGlobal.LoadXml(global.Global);

            stringxml.Append("<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n");
            stringxml.Append("<languages ");


            XDocument tree = XDocument.Parse(global.Global);
            var langNode = tree.Root.Element("language_set");
            if (langNode.HasAttributes)
            {
                var defaultLanguage = langNode.Attribute("default").Value;
                if (!string.IsNullOrEmpty(defaultLanguage))
                {
                    stringxml.Append("default=\"" + defaultLanguage + "\"");
                }
            }
            stringxml.Append(">");
            stringxml.Append("<airport_language></airport_language> ");

            XDocument xmlGlobal1 = XDocument.Parse(global.Global);


            foreach (var lan in dbLanguages)
            {
                var langElement = xmlGlobal1.Root.Element(lan.TwoLetterID_4xxx.ToLower());
                if (langElement != null && langElement.HasAttributes)
                {
                    var clock = langElement.Attribute("clock").Value;
                    var units = langElement.Attribute("units").Value;

                    stringxml.Append(@"<lan id=""" + lan.LanguageID.ToString() + "\" name=\"" + lan.Name + "\" twolet=\"" + lan.TwoLetterID_ASXi + "\" " +
                        "threelet=\"" + lan.ThreeLetterID_ASXi + "\" units=\"" + units + "\" clockunits=\"" + clock + "\" l2r=\"" + "true" + "\" />");
                }
            }

            stringxml.Append("</languages>");

            XmlDocument doc = new XmlDocument();
            doc.LoadXml(stringxml.ToString());
            doc.Save(configDirectory + "\\language.xml");
        }
        private async Task GenerateTZXML(TaskEnvironment environment, IUnitOfWorkAdapter context, List<Language> dbLanguages, string configDirectory)
        {
            //get timezome cities from custom3d xml
            //loop through he cities create xml for each languages


            var cityData = GetCityXml(environment);
            var infoSpellings = await context.Repositories.CustomContentRepository.GetInfoSpelling(environment.CurrentTask.ConfigurationID, dbLanguages);

            
            foreach (var lang in dbLanguages)
            {
                var langCityData=cityData.Where(x => x.LanguageId == lang.LanguageID).ToList();
                
                    XmlDocument xmlDoc = new XmlDocument();
                    string stringLangFilename = configDirectory + "\\tz_" + lang.TwoLetterID_ASXi.ToLower() + ".xml";
                    FileStream objFileStream = File.Create(stringLangFilename);
                    objFileStream.Close();
                    StringBuilder stringBuilder = new StringBuilder();
                    stringBuilder.Append("<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n");
                    stringBuilder.Append("<citylist>");

                    
                    foreach (var data in langCityData)
                    {
                        stringBuilder.Append("<city georefid=\"" + data.GeoRefId + "\" lat=\"" + data.Lat + "\" lon=\"" + data.Lon + "\" name=\"" + data.PlaceName + "\" />");
                    }
                    stringBuilder.Append("</citylist>");
                    xmlDoc.LoadXml(stringBuilder.ToString());
                    xmlDoc.Save(stringLangFilename);
                
            }
        }

        private List<CityData> GetCityXml(TaskEnvironment environment)
        {
            XmlNodeList objXmlNodeList;
            XmlAttribute objXmlAttribute;
            List<CityData> cityList = new List<CityData>();

            XmlDocument xDoc = new XmlDocument();
            //load custom3d xml
            var customXmlPath = environment.GetOutputPath("mmcfgp/config/custom3d.xml");
            xDoc.Load(customXmlPath);
            XmlNode xmlnodeTimezoneCities = xDoc.SelectSingleNode("asxi3d/timezone_cities");

            // Delete comments
            if (xmlnodeTimezoneCities != null)
            {
                objXmlNodeList = xmlnodeTimezoneCities.SelectNodes("comment()");
                foreach (XmlNode n in objXmlNodeList)
                    xmlnodeTimezoneCities.RemoveChild(n);

                objXmlNodeList = xmlnodeTimezoneCities.SelectNodes("city");
                
                CityData city;
                foreach (XmlNode objXmlNode in objXmlNodeList)
                {

                    objXmlAttribute = objXmlNode.Attributes["geoid"];
                    if (objXmlAttribute != null)
                    {
                        city = new CityData();
                        city.GeoRefId = Convert.ToInt32(objXmlAttribute.InnerText); ;
                        city.Lat = objXmlNode.Attributes["lat"].InnerText;
                        city.Lon = objXmlNode.Attributes["lon"].InnerText;
                        var childNods = objXmlNode.ChildNodes;
                        foreach (XmlNode cityNode in childNods)
                        {

                            city.LanguageId = Convert.ToInt32(cityNode.Attributes["id"].InnerText);
                            city.PlaceName = cityNode.InnerText;
                            cityList.Add(city);
                        }
                    }
                }
            }
            return cityList;
        }

        private static async Task GenerateCustom3DXML(TaskEnvironment environment, string stringConfigDirectory, List<Language> dbLanguages)
        {
            var customXmlPath = environment.GetOutputPath("custom3d.xml");
            if (!File.Exists(customXmlPath))
            {
                TaskDevelopmentExport taskDevelopmentExport = new TaskDevelopmentExport();
                await taskDevelopmentExport.GenerateCustom3dXML(environment, dbLanguages);
            }
            File.Copy(customXmlPath, stringConfigDirectory + "//custom3d.xml");
            File.Delete(customXmlPath);

        }
    }
    
}