using AutoMapper;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Task;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers.Azure;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services.Configurations
{
    public class CollinsAdminOnlyFeaturesService : ICollinsAdminOnlyFeaturesService
    {
        private const char filePathDelimiter = '/';
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;
        private Helpers.Configuration _configuration;
        
        public CollinsAdminOnlyFeaturesService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger, Helpers.Configuration configuration)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
            _configuration = configuration;
        }

        public string zipFileExtractor(string path)
        {
            //string fileName = Path.GetFileName(path);
            string resultPath = Regex.Replace(path, ".zip", "");
            if (!Directory.Exists(resultPath))
                Directory.CreateDirectory(resultPath);
            ZipFile.ExtractToDirectory(path, resultPath);
            var dir = new DirectoryInfo(resultPath);
            resultPath = Path.Combine(resultPath, dir.Name);
            return resultPath;
        }

        public string zipFileExtractor(string path, bool overwrite)
        {
            string resultPath = Regex.Replace(path, ".zip", "");
            if (!Directory.Exists(resultPath))
                Directory.CreateDirectory(resultPath);
            ZipFile.ExtractToDirectory(path, resultPath, overwrite);
            return resultPath;
        }
        public async Task<DataDownloadResultDTO> DownloadArtifactsByRevision(int configurationid, string[] inputDetails)
        {
            DataDownloadResultDTO resultDTO = new DataDownloadResultDTO();
            using var context = _unitOfWork.Create;
            var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationid);
            if (definition == null)
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Configuration is not present";
            }

            bool isValid = Guid.TryParse(inputDetails[0], out Guid guidOutput);

            if (isValid)
            {
                var TaskID = inputDetails[0];
                if (!TaskID.Equals(Guid.Empty))
                {

                    var outputPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) + @"\Downloads", TaskID + ".zip");
                    var blobConnectionString = _configuration.AzureExportBlobStorage;
                    var blobContainerName = _configuration.AzureBlobStorageContainerforCollinsAdminAssets;
                    var blobName = inputDetails[2] + "\\" + inputDetails[1] + "\\" + inputDetails[0].ToLower() + ".zip";
                    blobName = blobName.Replace("\\\\", "\\");
                    blobName = blobName.Replace("\\", "/");

                    resultDTO.Data = await AzureFileHelper.GetSASURL(inputDetails[0], blobName,  blobContainerName, blobConnectionString);
                    resultDTO.IsError = false;
                    resultDTO.Message = "Artifacts are downloaded";
                }
                else
                {
                    resultDTO.IsError = true;
                    resultDTO.Message = "Artifacts are not present";
                }
            }
            else
            {
                string urlPath = _configuration.AzureFileUploadPath;
                string downloadURL = await context.Repositories.ConfigurationRepository.GetDownloadURL(int.Parse(inputDetails[1]), inputDetails[0]);
                if (!string.IsNullOrWhiteSpace(downloadURL) && !string.IsNullOrWhiteSpace(urlPath))
                {
                    urlPath += downloadURL;
                    try
                    {
                        resultDTO.Data = urlPath;

                        resultDTO.IsError = false;
                        resultDTO.Message = "Artifacts are downloaded";
                    }
                    catch (Exception ex)
                    {
                        resultDTO.IsError = true;
                        resultDTO.Message = "Failed to download artifacts";
                    }
                }
                else
                {
                    resultDTO.IsError = true;
                    resultDTO.Message = "Artifacts are not present";
                }
            }

            return resultDTO;
        }

        /// <summary>
        /// 1. Method to get the details of the admin items.
        /// 2. It will return a list of string.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<List<string>> GetCollinsAdminItems(int configurationId)
        {
            using var context = _unitOfWork.Create;
            string buttonNames = string.Empty;
            List<string> adminItems = new List<string>();
            buttonNames = await context.Repositories.ConfigurationRepository.GetCollinsAdminItems(configurationId);
            adminItems = buttonNames.Split(",").ToList();
            return adminItems;
        }

        /// <summary>
        /// 1. Get the download details of the selected page.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        public async Task<List<AdminOnlyDownloadDetails>> GetDownloadDetails(int configurationId, string pageName)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ConfigurationRepository.GetDownloadDetails(configurationId, pageName);
        }

        /// <summary>
        /// 1.Method to upload file to azure storage.
        /// 2. This method calls individual methods based on type.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="tempPath"></param>
        /// <param name="pageName"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UploadRequiredFeatures(int configurationId, string tempPath, string pageName, string mapPackageType, Guid userId)
        {
            DataCreationResultDTO result = new DataCreationResultDTO();
            switch (pageName.ToLower())
            {
                case "citypopulation":
                    result = await UpdateCityPopulation(configurationId, tempPath, userId);
                    break;
                case "newairport":
                    result = await AddNewAirpots(configurationId, tempPath, userId);
                    break;
                case "addnewwgcities":
                    result = await AddNewWGCities(configurationId, tempPath, userId);
                    break;
                case "site identification":
                    result = await SiteIdentificationData(configurationId, tempPath, userId, pageName);
                    break;
                case "system config":
                    result = await XmlDataUpload(configurationId, tempPath, userId, "system", "System Config", pageName);
                    break;
                case "flight data configuration":
                    result = await AddFlightData(configurationId, tempPath, userId, pageName);
                    break;
                case "timezone database":
                    result = await TimezoneData(configurationId, tempPath, userId, pageName);
                    break;
                case "flight phase profile":
                    result = await XmlDataUpload(configurationId, tempPath, userId, "asxiprofile", "Flight Phase Profile", pageName);
                    break;
                case "acars configuration":
                    result = await XmlDataUpload(configurationId, tempPath, userId, "acars", "ACARS Data", pageName);
                    break;
                case "sizes configuration":
                    result = await XmlDataUpload(configurationId, tempPath, userId, "sizes", "Sizes Configuration", pageName);
                    break;
                case "content 3d configuration":
                    result = await FileDataUpload(configurationId, tempPath, userId, "Content 3D Configuration", pageName);
                    break;
                case "mobile":
                    result = await FileDataUpload(configurationId, tempPath, userId, "Content Mobile Configuration", pageName);
                    break;
                case "installation scripts venue next":
                    result = await VenueNextScripts(configurationId, tempPath, userId, pageName);
                    break;
                case "ces":
                    result = await CESScripts(configurationId, tempPath, userId, pageName);
                    break;
                case "resolution":
                    result = await XmlDataUpload(configurationId, tempPath, userId, "resolution_map", "Resolution Map Configuration", pageName);
                    break;
                case "briefings configuration":
                    result = await BriefingsData(configurationId, tempPath, userId, pageName);
                    break;
                case "flight deck controller menu":
                    result = await FlightDeckData(configurationId, tempPath, userId, pageName);
                    break;
                case "placenames":
                    result = await AddNewPlaceNames(configurationId, tempPath, userId);
                    break;
                case "mobile configuration platform":
                    result = await MobileConfigurationData(configurationId, tempPath, userId, pageName);
                    break;
                case "content 3d aircraft models":
                    result = await AircraftModelsData(configurationId, tempPath, userId, pageName);
                    break;
                case "ticker ads configuration":
                    result = await TickerAdsConfigurationData(configurationId, tempPath, userId, pageName);
                    break;
                case "mmobilecc configuration":
                    result = await MmobileccConfigurationData(configurationId, tempPath, userId, pageName);
                    break;
                case "discrete inputs":
                    result = await XmlDataUpload(configurationId, tempPath, userId, "arincdinputs", "discrete inputs", pageName);
                    break;
                case "briefings (non hd)":
                    result = await BriefingsNonHD(configurationId, tempPath, userId, pageName);
                    break;
                case "map package blue marble":
                    result = await MapPackageBlueMarble(configurationId, tempPath, userId, pageName);
                    break;
                case "map package blue marble borderless":
                    result = await MapPackageBlueMarbleBorderless(configurationId, tempPath, userId, pageName);
                    break;
                case "content htse 1280x720":
                    result = await ContentHTSE1280x720(configurationId, tempPath, userId, pageName);
                    break;
                case "content asxi3 standard 3d":
                    result = await ContentASXi3Standard3D(configurationId, tempPath, userId, pageName);
                    break;
                case "content asxi3 aircraft models":
                    result = await ContentASXi3AircraftModels(configurationId, tempPath, userId, pageName);
                    break;
                case "content asxi4/5 aircraft models":
                    result = await ContentASXi45AircraftModels(configurationId, tempPath, userId, pageName);
                    break;
                case "installation scripts venue hybrid":
                    result = await InstallationScriptsVenueHybrid(configurationId, tempPath, userId, pageName);
                    break;
                case "fdc map menu list":
                    result = await XmlDataUpload(configurationId, tempPath, userId, "fdcmapmenulistconfig", "Flight Deck Control Map Menu list config", pageName);
                    break;
                case "insets":
                    result = await ImportMapInsets(configurationId, tempPath, mapPackageType, userId, pageName);
                    break;

                case "info spelling":
                    result = await UpdateInfoSpelling(configurationId, tempPath, userId);
                    break;

                case "font data":
                     result = await AddnewFonts(configurationId, tempPath, userId);
                    break;
                case "customxml":
                    result = await ImportCustomXML(configurationId, tempPath, userId);
                    break;

            }

            return result;
        }

        /// <summary>
        /// 1. To retrieve error logs for for uploads.
        /// 2. Errors will be logged if any failures during upload.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        public async Task<string> GetErrorLog(int configurationId, string pageName)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ConfigurationRepository.GetErrorLog(configurationId, pageName);
        }

        #region Private Methods

        /**
         * The lsit data from ImportLatestPopulationData fed here for the second level of formation
         * Will apply some filtering to sort the data 
         * Validation of the format happens here using csvHelper, violation of this will raise a excepthion
         * The complete formated data copied to a temp table in to the sql server using sqlbulkcopy for further actions
         * **/
        private async Task<DataCreationResultDTO> UpdateCityPopulation(int configurationId, string path, Guid userId)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string csvFilePath = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains(".csv"))
                    {
                        csvFilePath = f;
                    }

                }
                if (!File.Exists(csvFilePath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Import CityPopulation");
            if (taskType == null)
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Unable to determine Task type"
                };

            bool fileType = await DeleteUploadedFile(taskType.ID, configurationId);
            if (fileType)
            {
                return await UploadToAzureBlobStorage(configurationId, taskType, userId, zipfilePath);
            } 
            else
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "File deletion failed"
                };
            }
        }

       
        /// <summary>
        /// 1. Method to upload City populations files to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> AddNewAirpots(int configurationId, string path, Guid userId)
        {

            string[] filePaths = Directory.GetFiles(path, "*.zip",
                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                         SearchOption.AllDirectories);
                string airportCsvFilePath = "";
                string DB_name = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains(".csv"))
                    {
                        airportCsvFilePath = f;
                    }
                    if (f.ToLower().Contains(".db"))
                    {
                        DB_name = f;
                    }
                }
                if (!File.Exists(airportCsvFilePath) || !File.Exists(DB_name))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Import NewAirportFromNavDB");
            if (taskType == null)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "unable to determine Task type"
                };
            }

            bool fileType = await DeleteUploadedFile(taskType.ID, configurationId);
            if (fileType)
            {
                return await UploadToAzureBlobStorage(configurationId, taskType, userId, zipfilePath);
            }
            else
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "File deletion failed"
                };
            }

        }

        /// <summary>
        /// 1. Method to upload world guide cities data to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="currentUserId"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> AddNewWGCities(int configurationId, string path, Guid currentUserId)
        {

            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = string.Empty;

            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                string xmlDocRockwell = string.Empty;
                string xmlDocFlightPoi = string.Empty;
                string poiidtoGeoRefIdCSV = string.Empty;
                string cityidtoGeoRefIdCSV = string.Empty;
                string wgcontentPath = string.Empty;

                filePaths = Directory.GetFiles(path, "*.*", SearchOption.AllDirectories);
                foreach (string s in filePaths)
                {
                    if (s.Contains("Rockwell.xml"))
                    {
                        xmlDocRockwell = s;
                    }
                    if (s.Contains("flight_POI.xml"))
                    {
                        xmlDocFlightPoi = s;
                    }
                    if (s.Contains("poiid-to-georefid.csv"))
                    {
                        poiidtoGeoRefIdCSV = s;
                    }
                    if (s.Contains("cityid-to-georefid.csv"))
                    {
                        cityidtoGeoRefIdCSV = s;
                    }
                    if (s.EndsWith(".jpg"))
                    {
                        wgcontentPath = Path.GetDirectoryName(s);
                    }
                }

                if (!File.Exists(xmlDocRockwell) || !File.Exists(xmlDocFlightPoi) || !File.Exists(poiidtoGeoRefIdCSV) || !File.Exists(cityidtoGeoRefIdCSV))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing." };
                }

                if(!Directory.Exists(wgcontentPath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "WGContent Images are missing." };
                }
            }
            catch(Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }

            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Import WGCities");
            if (taskType == null)
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Unable to determine Task type"
                };
            }

            bool fileType = await DeleteUploadedFile(taskType.ID, configurationId);
            if (fileType)
            {
                return await UploadToAzureBlobStorage(configurationId, taskType, currentUserId, zipfilePath);
            }
            else
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "File deletion failed"
                };
            }
        }

        /// <summary>
        /// 1. Methods to upload flight data to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> AddFlightData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string fms_type = string.Empty;
                string fdata_cfg = string.Empty;
                string fdata_p1_cfg = string.Empty;
                string fdata_p2_cfg = string.Empty;
                string fdata_p3_cfg = string.Empty;
                string fdata_p4_9_cfg = string.Empty;

                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("fms_type.xml"))
                    {
                        fms_type = f;
                    }
                    if (f.ToLower().Contains("fdata_cfg.xml"))
                    {
                        fdata_cfg = f;
                    }
                    if (f.ToLower().Contains("fdata_p1_cfg.xml"))
                    {
                        fdata_p1_cfg = f;
                    }
                    if (f.ToLower().Contains("fdata_p2_cfg.xml"))
                    {
                        fdata_p2_cfg = f;
                    }
                    if (f.ToLower().Contains("fdata_p3_cfg.xml"))
                    {
                        fdata_p3_cfg = f;
                    }
                    if (f.ToLower().Contains("fdata_p4_9_cfg.xml"))
                    {
                        fdata_p4_9_cfg = f;
                    }


                }
                if (!File.Exists(fms_type) || !File.Exists(fdata_cfg) || !File.Exists(fdata_p1_cfg) || 
                    !File.Exists(fdata_p2_cfg) || !File.Exists(fdata_p3_cfg) || !File.Exists(fdata_p4_9_cfg))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Flight_Config_Data", pageName);
        }

        /// <summary>
        /// 1. Methods to upload MobileConfigurationData to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>

        private async Task<DataCreationResultDTO> MobileConfigurationData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string ipadconfig = string.Empty;
               
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("ipadconfig.xml"))
                    {
                        ipadconfig = f;
                    }

                }
                
                if (!File.Exists(ipadconfig))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Mobile_Config_Data", pageName);
        }

        /// <summary>
        /// 1. Methods to upload AircraftModelsData to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>

        private async Task<DataCreationResultDTO> AircraftModelsData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);

                string[] directories = Directory.GetDirectories(path, ".", SearchOption.AllDirectories);

                string mapImagesDirectory = string.Empty;
                string mapImagesAircraft = string.Empty;
                string mapImagesAircraft2d = string.Empty;
                string modelsDirectory = string.Empty;
                string modelsAircraft = string.Empty;
                string modelsAircraftEtc = string.Empty;
                string modelsAircraftPng = string.Empty;
                string modelsAircraftPvr = string.Empty;
                string modelsAircraft2d = string.Empty;
                directories.ToList().ForEach(directory =>
                {
                    if (directory.ToLower().Contains("map"))
                    {
                        mapImagesDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("aircraft.png"))
                                mapImagesAircraft = file;

                            if (file.ToLower().Contains("aircraft2d-shadow.png"))
                                mapImagesAircraft2d = file;

                        });
                    }
                    if (directory.ToLower().Contains("models"))
                    {
                        modelsDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("aircraft.3ds"))
                                modelsAircraft = file;
                            if (file.ToLower().Contains("aircraft.etc"))
                                modelsAircraftEtc = file;
                            if (file.ToLower().Contains("aircraft.png"))
                                modelsAircraftPng= file;
                            if (file.ToLower().Contains("aircraft.pvr"))
                                modelsAircraftPvr = file;
                            if (file.ToLower().Contains("aircraft2d-shadow.png"))
                                modelsAircraft2d = file;
                        });
                    }
                    
                });



                if (!File.Exists(mapImagesAircraft) || !File.Exists(mapImagesAircraft2d) || !File.Exists(modelsAircraft) ||!File.Exists(modelsAircraftEtc) || !File.Exists(modelsAircraftPng) ||!File.Exists(modelsAircraftPvr) ||  !File.Exists(modelsAircraft2d)|| !Directory.Exists(mapImagesDirectory) || !Directory.Exists(modelsDirectory))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Aircraft_Models_Data", pageName);
        }

        /// <summary>
        /// 1. Methods to upload TickerAdsConfigurationData to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>

        private async Task<DataCreationResultDTO> TickerAdsConfigurationData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string adconfig = string.Empty;

                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("asxi-ad-config.xml"))
                    {
                        adconfig = f;
                    }


                }
                if (!File.Exists(adconfig))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Tickerads_Config_Data", pageName);
        }

        private async Task<DataCreationResultDTO> MmobileccConfigurationData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                string ipadconfig = string.Empty;

                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("ipadconfig.zip"))
                    {
                        zipfilePath = f;
                    }
                }
                if (!File.Exists(zipfilePath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Mmobilecc_Config_Data", pageName);
        }


        /// <summary>
        /// 1. Methods to upload timezone data to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> TimezoneData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string siteFilePath = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("tzdbase.dat"))
                    {
                        siteFilePath = f;
                    }

                }
                if (!File.Exists(siteFilePath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Time_Zone_Data", pageName);
        }

        /// <summary>
        /// 1. Methods to upload site identification data to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> SiteIdentificationData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string siteFilePath = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("siteid.dat"))
                    {
                        siteFilePath = f;
                    }

                }
                if (!File.Exists(siteFilePath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Site_Identification_Data", pageName);
        }

        /// <summary>
        /// 1. Methods to upload venue next scripts to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> VenueNextScripts(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string[] directoriesPaths = Directory.GetDirectories(path, ".", SearchOption.AllDirectories);

                string mccDirectory = string.Empty;
                string mcfgDirectory = string.Empty;
                string mcntDirectory = string.Empty;
                string mdataDirectory = string.Empty;
                string minsetsDirectory = string.Empty;
                string mmobileccDirectory = string.Empty;
                string mtzDirectory = string.Empty;
                string mccInstall = string.Empty;
                string mccClean = string.Empty;
                string mcfgInstall = string.Empty;
                string mcfgClean = string.Empty;
                string mcntInstall = string.Empty;
                string mcntClean = string.Empty;
                string mdataInstall = string.Empty;
                string mdataCleam = string.Empty;
                string minsetsInstall = string.Empty;
                string minsetsClean = string.Empty;
                string mmobileccInstall = string.Empty;
                string mmobileccClean = string.Empty;
                string mtzInstall = string.Empty;
                string mtzClean = string.Empty;

                directoriesPaths.ToList().ForEach(directory =>
                {
                    if (directory.ToLower().Contains("mcc"))
                    {
                        mccDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("install.sh"))
                                mccInstall = file;
                            if (file.ToLower().Contains("clean.sh"))
                                mccClean = file;
                        });
                    }

                    if (directory.ToLower().Contains("mcfg"))
                    {
                        mcfgDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("install.sh"))
                                mcfgInstall = file;
                            if (file.ToLower().Contains("clean.sh"))
                                mcfgClean = file;
                        });
                    }
                    if (directory.ToLower().Contains("mcnt"))
                    {
                        mcntDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("install.sh"))
                                mcntInstall = file;
                            if (file.ToLower().Contains("clean.sh"))
                                mcntClean = file;
                        });
                    }
                    if (directory.ToLower().Contains("minsets"))
                    {
                        minsetsDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("install.sh"))
                                minsetsInstall = file;
                            if (file.ToLower().Contains("clean.sh"))
                                minsetsClean = file;
                        });
                    }
                    if (directory.ToLower().Contains("mdata"))
                    {
                        mdataDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("install.sh"))
                                mdataInstall = file;
                            if (file.ToLower().Contains("clean.sh"))
                                mdataCleam = file;
                        });
                    }
                    if (directory.ToLower().Contains("mtz"))
                    {
                        mtzDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("install.sh"))
                                mtzInstall = file;
                            if (file.ToLower().Contains("clean.sh"))
                                mtzClean = file;
                        });
                    }
                    if (directory.ToLower().Contains("mmobilecc"))
                    {
                        mmobileccDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("install.sh"))
                                mmobileccInstall = file;
                            if (file.ToLower().Contains("clean.sh"))
                                mmobileccClean = file;
                        });
                    }

                });

                if (!File.Exists(mtzClean) || !File.Exists(mtzInstall) || !File.Exists(mmobileccClean) || !File.Exists(mmobileccInstall) || 
                    !File.Exists(mdataCleam) || !File.Exists(mdataInstall) || !File.Exists(mcntClean) || !File.Exists(mcntInstall) ||
                    !File.Exists(mcfgClean) || !File.Exists(mcfgInstall) || !File.Exists(mccClean) || !File.Exists(mccInstall) ||
                    !File.Exists(minsetsClean) || !File.Exists(minsetsInstall) || !Directory.Exists(minsetsDirectory) || !Directory.Exists(mccDirectory) ||
                    !Directory.Exists(mcfgDirectory) || !Directory.Exists(mcntDirectory) || !Directory.Exists(mtzDirectory)  ||
                    !Directory.Exists(mdataDirectory) || !Directory.Exists(mmobileccDirectory))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Venue_Next_Data", pageName);
        }

        /// <summary>
        /// 1. Methods to upload CES scripts to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> CESScripts(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string[] directories = Directory.GetDirectories(path, ".", SearchOption.AllDirectories);

                string configInstall = string.Empty;
                string contentInstall = string.Empty;
                string blueMarbleInstall = string.Empty;
                string customDataInstall = string.Empty;
                string dataInstall = string.Empty;
                string configDirectory = string.Empty;
                string contentDirectory = string.Empty;
                string blueMarbleDirectory = string.Empty;
                string customDataDirectory = string.Empty;
                string dataDirectory = string.Empty;

                directories.ToList().ForEach(directory =>
                {
                    if (directory.ToLower().Contains("config"))
                    {
                        configDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                configInstall = file;
                        });
                    }
                    if (directory.ToLower().Contains("content"))
                    {
                        contentDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                contentInstall = file;
                        });
                    }
                    if (directory.ToLower().Contains("bluemarble"))
                    {
                        blueMarbleDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                blueMarbleInstall = file;
                        });
                    }
                    if (directory.ToLower().Contains("customdata"))
                    {
                        customDataDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                customDataInstall = file;
                        });
                    }
                    if (directory.ToLower().Contains("data"))
                    {
                        dataDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                dataInstall = file;
                        });
                    }
                });
                if (!File.Exists(configInstall) || !File.Exists(contentInstall) || !File.Exists(blueMarbleInstall) || !File.Exists(customDataInstall) || !File.Exists(dataInstall) ||
                    !Directory.Exists(contentDirectory) || !Directory.Exists(configDirectory) || !Directory.Exists(blueMarbleDirectory) || !Directory.Exists(customDataDirectory) ||
                    !Directory.Exists(dataDirectory))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "CES_Data", pageName);
        }

        /// <summary>
        /// 1. Methods to upload briefings data to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> BriefingsData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string configDuration = string.Empty;
                string configFDCMenuBriefingsConfig = string.Empty;

                filePaths.ToList().ForEach(file =>
                {
                    if (file.ToLower().Contains("durations.xml"))
                        configDuration = file;
                    if (file.ToLower().Contains("fdcbriefingsmenulistconfig.xml"))
                        configFDCMenuBriefingsConfig = file;
                });
                if (!File.Exists(configDuration) || !File.Exists(configFDCMenuBriefingsConfig))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }

                string[] directories = Directory.GetDirectories(path, ".", SearchOption.AllDirectories);
                string contentDirectory = string.Empty;

                directories.ToList().ForEach(directory =>
                {
                    {
                        contentDirectory = directory;
                    }
                });
                if (string.IsNullOrWhiteSpace(contentDirectory))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Briefings_Data", pageName);
        }

        /// <summary>
        /// 1. Methods to upload flight deck data to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> FlightDeckData(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string fdcMapMenuListConfigFilePath = "";
                string fdcMamMenuListControlFileFilePath = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("fdcmapmenulistconfig.xml"))
                    {
                        fdcMapMenuListConfigFilePath = f;
                    }

                }
                if (!File.Exists(fdcMapMenuListConfigFilePath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Flight_Deck_Data", pageName);
        }

        /// <summary>
        /// Uploading BriefingsNonHD data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> BriefingsNonHD(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string[] directories = Directory.GetDirectories(path, ".", SearchOption.AllDirectories);
                string configDirectory = string.Empty;
                string configDuration = string.Empty;
                string configfdcMenu = string.Empty;
                string contentDirectory = string.Empty;
                directories.ToList().ForEach(directory =>
                {
                    if (directory.ToLower().Contains("config"))
                    {
                        configDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("durations.xml"))
                                configDuration = file;
                            if (file.ToLower().Contains("fdcbriefingsmenulistconfig.xml".ToLower()))
                                configfdcMenu = file;
                        });
                    }
                    if (directory.ToLower().Contains("content"))
                    {
                        contentDirectory = directory;
                    }
                });

                if (!Directory.Exists(configDirectory) || !Directory.Exists(contentDirectory) || !File.Exists(configDuration)
                    || !File.Exists(configfdcMenu))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Briefings_Non_HD", pageName);
        }

        /// <summary>
        /// Updaloading MapPackageBlueMarble custom component data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> MapPackageBlueMarble(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string[] directories = Directory.GetDirectories(path, ".", SearchOption.AllDirectories);
                string tembmbordersDirectory = string.Empty;
                directories.ToList().ForEach(directory =>
                {
                    if (directory.ToLower().Contains("tembmborders"))
                    {
                        tembmbordersDirectory = directory;
                    }

                });

                if (!Directory.Exists(tembmbordersDirectory))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Map_Package_BlueMarble", pageName);
        }

        /// <summary>
        /// Updaloading MapPackageBlueMarbleBorderless custom component data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> MapPackageBlueMarbleBorderless(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string[] directories = Directory.GetDirectories(path, ".", SearchOption.AllDirectories);
                string tembmbordersDirectory = string.Empty;
                directories.ToList().ForEach(directory =>
                {
                    if (directory.ToLower().Contains("tembmborderless"))
                    {
                        tembmbordersDirectory = directory;
                    }

                });

                if (!Directory.Exists(tembmbordersDirectory))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Map_Package_BlueMarble_Borderless", pageName);
        }

        /// <summary>
        /// Updaloading ContentHTSE1280x720 custom component data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> ContentHTSE1280x720(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                
                string[] directories = Directory.GetDirectories(path, ".", SearchOption.AllDirectories).Where(a => a.Contains("map_aircraft")).ToArray();
                var mapAircraftPath = string.Empty;
                foreach (var name in directories)
                {
                    if (new DirectoryInfo(name).Name == "map_aircraft")
                    {
                        mapAircraftPath = name;
                        break;
                    }
                }

                if (!string.IsNullOrEmpty(mapAircraftPath))
                {
                    string[] airplaneTypesPath = Directory.GetDirectories(mapAircraftPath, ".", SearchOption.AllDirectories);

                    List<string> aerplaneTypesName = new List<string>();
                    foreach (var type in airplaneTypesPath)
                    {
                        aerplaneTypesName.Add(new DirectoryInfo(type).Name);
                    }

                    if (aerplaneTypesName.Count > 0)
                    {
                        //extract the aeroplane type names and insert into tables
                        await ExtractAeroPlaneType(configurationId, String.Join(",", aerplaneTypesName), userId);
                    }
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Content_HTSE_1280x720", pageName);
        }

        private async System.Threading.Tasks.Task ExtractAeroPlaneType(int configurationId, string aertPlanTypes, Guid userId)
        {
            using var context = _unitOfWork.Create;
            await context.Repositories.ViewsConfigurationRepository.InserUpdateAeroplaneTyes(configurationId, aertPlanTypes, userId);
            await context.SaveChanges();
        }

        /// <summary>
        /// Updaloading ContentASXi3Standard3D custom component data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> ContentASXi3Standard3D(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Content_ASXi3_Standard_3D", pageName);
        }

        /// <summary>
        /// Updaloading ContentASXi3AircraftModels custom component data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> ContentASXi3AircraftModels(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Content_ASXi3_Aircraft_Models", pageName);
        }

        /// <summary>
        /// Updaloading ContentASXi45AircraftModels custom component data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> ContentASXi45AircraftModels(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Content_ASXi45_Aircraft_Models", pageName);
        }

        /// <summary>
        /// Updaloading InstallationScriptsVenueHybrid custom component data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> InstallationScriptsVenueHybrid(int configurationId, string path, Guid userId, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string[] directoriesPaths = Directory.GetDirectories(path, ".", SearchOption.AllDirectories);

                string configDirectory = string.Empty;
                string contentDirectory = string.Empty;
                string customDataDirectory = string.Empty;
                string dataDirectory = string.Empty;
                string bluemarbleDirectory = string.Empty;
                string configInstall = string.Empty;
                string contentInstall = string.Empty;
                string customDataInstall = string.Empty;
                string dataInstall = string.Empty;
                string bluemarbleInstall = string.Empty;

                directoriesPaths.ToList().ForEach(directory =>
                {
                    if (directory.ToLower().Contains("config"))
                    {
                        configDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                configInstall = file;
                        });
                    }

                    if (directory.ToLower().Contains("content"))
                    {
                        contentDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                contentInstall = file;
                        });
                    }
                    if (directory.ToLower().Contains("customdata"))
                    {
                        customDataDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                customDataInstall = file;
                        });
                    }
                    if (directory.ToLower().Contains("data"))
                    {
                        dataDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                dataInstall = file;
                        });
                    }
                    if (directory.ToLower().Contains("bluemarble"))
                    {
                        bluemarbleDirectory = directory;
                        filePaths.ToList().ForEach(file =>
                        {
                            if (file.ToLower().Contains("mapinstall.sh"))
                                bluemarbleInstall = file;
                        });
                    }
                });

                if (!File.Exists(configInstall) || !File.Exists(contentInstall) || !File.Exists(customDataInstall) ||
                    !File.Exists(dataInstall) || !File.Exists(bluemarbleInstall)
                    || !Directory.Exists(configDirectory) || !Directory.Exists(contentDirectory) || !Directory.Exists(customDataDirectory)
                    || !Directory.Exists(dataDirectory) || !Directory.Exists(bluemarbleDirectory))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, "Installation_Scripts_Venue_Hybrid", pageName);
        }


        /// <summary>
        /// 1. Common method for data which is only 1 xml.
        /// 2. Data which call this methods are System config, ACARS data, site configuration, resolution map and sflight phase profile data.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="fileName"></param>
        /// <param name="apiType"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> XmlDataUpload(int configurationId, string path, Guid userId, string fileName, string apiType, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string datFilePath = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains(fileName + ".xml"))
                    {
                        datFilePath = f;
                    }

                }
                if (!File.Exists(datFilePath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, apiType, pageName);
        }

        /// <summary>
        /// Common method for data upload for 3D content and 3D mobile data.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="apiType"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> FileDataUpload(int configurationId, string path, Guid userId, string apiType, string pageName)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                if(Directory.GetFiles(path).Length == 0)
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            return await UploadToBlobStorage(configurationId, userId, zipfilePath, apiType, apiType);
        }

        /// <summary>
        /// 1. Method to upload data to azure  storage container.
        /// 2. This method will create a task and a queue.
        /// 3. The queue will be picked up from the backend worker and do the data processing.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="taskType"></param>
        /// <param name="userId"></param>
        /// <param name="zipfilePath"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> UploadToAzureBlobStorage(int configurationId, TaskType taskType, Guid userId, string zipfilePath)
        {
            using var context = _unitOfWork.Create;

            var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (definition == null)
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Invalid configuration"
                };
            }
            BuildQueueItem item = new BuildQueueItem
            {
                Debug = false,
                Config = new BuildTask()
            };
            item.Config.ID = Guid.NewGuid();
            item.Config.ConfigurationID = configurationId;
            item.Config.ConfigurationDefinitionID = definition.ConfigurationDefinitionId;
            item.Config.TaskTypeID = taskType.ID;
            item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
            item.Config.DateStarted = DateTime.Now;
            item.Config.DateLastUpdated = DateTime.Now;
            item.Config.PercentageComplete = 0f;
            item.Config.StartedByUserID = userId;

            await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
            await context.SaveChanges();

            //Upload the file to Blob container
            string connectionString = _configuration.AzureWebJobsStorage;
            string blobContainer = _configuration.AzureBlobStorageContainerforCollinsAdminAssets;
            string blobName = definition.ConfigurationDefinitionId + "\\" + configurationId + "\\" + item.Config.ID.ToString() + ".zip";
            FileInfo currentFile = new FileInfo(zipfilePath);
            string destFile = currentFile.Directory.FullName + "\\" + item.Config.ID.ToString() + ".zip";
            if (File.Exists(destFile))
                File.Delete(destFile);
            currentFile.CopyTo(destFile);
            await AzureFileHelper.UploadBlob(connectionString, blobContainer, blobName, currentFile.FullName);

            // build the queue message and uploaded it to azure for the webjobs to see
            string queueName = _configuration.AzureWebJobsQueue;
            string message = JsonConvert.SerializeObject(item);
            var bytes = Encoding.ASCII.GetBytes(message);
            var base64 = System.Convert.ToBase64String(bytes);
            await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);

            return new DataCreationResultDTO()
            {
                IsError = false,
                Id = item.Config.ID,
                Message = "The files are uploaded Successfully! and Queue is Created for the Webjob"
            };
        }

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
        private async Task<DataCreationResultDTO> UploadToBlobStorage(int configurationId, Guid userId, string zipfilePath, string fileName, string pageName)
        {
            using var context = _unitOfWork.Create;
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
            string connectionString = _configuration.AzureWebJobsStorage;
            string blobContainer = _configuration.AzureBlobStorageContainerforCollinsAdminAssets;
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
                if (!url.ToLower().Equals("error"))
                    truncatedURL = url.ToString()[(url.ToString().LastIndexOf('/') + 1)..];

                var result = await context.Repositories.ConfigurationRepository.UpdateFilePath(truncatedURL, configurationId, fileName, userId, pageName, error);

                if (!url.ToLower().Equals("error"))
                {
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
                    resultDTO.Message = "error";
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
        
        /// <summary>
        /// Methods to upload PlaceName Source Files
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="path"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        private async Task<DataCreationResultDTO> AddNewPlaceNames(int configurationId, string path, Guid userId)
        {

            string[] filePaths = Directory.GetFiles(path, "*.zip",
                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                         SearchOption.AllDirectories);

                string nationalCensusSourcefile = "";
                string majorCityList = "";
                string GlobalPlaceNamesSourceFile = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("usnationalfile.txt"))
                    {
                        nationalCensusSourcefile = f;
                    }
                    if (f.ToLower().Contains(".csv"))
                    {
                        majorCityList = f;
                    }
                    if (f.ToLower().Contains("internationalfile.txt"))
                    {
                        GlobalPlaceNamesSourceFile = f;
                    }
                }
                if (!(File.Exists(nationalCensusSourcefile) ^ File.Exists(GlobalPlaceNamesSourceFile)) || !File.Exists(majorCityList))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Import NewPlaceNames");
            if (taskType == null)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "unable to determine Task type"
                };
            }
            return await UploadToAzureBlobStorage(configurationId, taskType, userId, zipfilePath);
        }
        private async Task<DataCreationResultDTO> AddnewFonts(int configurationId, string path, Guid userId)
        {

            string[] filePaths = Directory.GetFiles(path, "*.zip",
                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                         SearchOption.AllDirectories);

                string tbfont = "";
                string tbfontcategory = "";
                string tbfontfamily = "";
                string tbfontmarker = "";
                string DroidSans = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("tbfont.csv"))
                    {
                        tbfont = f;
                    }
                    if (f.ToLower().Contains("tbfontcategory.csv"))
                    {
                        tbfontcategory = f;
                    }
                    if (f.ToLower().Contains("tbfontfamily.csv"))
                    {
                        tbfontfamily = f;
                    }
                    if (f.ToLower().Contains("tbfontmarker.csv"))
                    {
                        tbfontmarker = f;
                    }
                    if (f.ToLower().Contains(".ttf"))
                    {
                        DroidSans = f;
                    }
                }
                if (!(File.Exists(tbfont) && File.Exists(tbfontcategory) && File.Exists(tbfontfamily) && File.Exists(tbfontmarker) && File.Exists(DroidSans)))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            using var context = _unitOfWork.Create;
            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Import Fonts");
            if (taskType == null)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "unable to determine Task type"
                };
            }
            bool fileType = await DeleteUploadedFile(taskType.ID, configurationId);
            if (fileType)
            {
                return await UploadToAzureBlobStorage(configurationId, taskType, userId, zipfilePath);
            }
            else
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "File deletion failed"
                };
            }
        }
        /// <summary>
        /// 1. Method to delete the file in azure container
        /// 2. Get the file name from database
        /// 3. Get the filepath, container name and file extension and send to built-in method
        /// 4. Old file will be deleted and new file will be created.
        /// </summary>
        /// <param name="taskId"></param>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        private async Task<bool> DeleteUploadedFile(Guid taskId, int configurationId)
        {
            bool fileDeleted = false;
            using var context = _unitOfWork.Create;

            var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (definition == null)
            {
                return fileDeleted;
            }

            string connectionString = _configuration.AzureWebJobsStorage;
            string blobContainer = _configuration.AzureBlobStorageContainerforCollinsAdminAssets;
            string uploadPath = definition.ConfigurationDefinitionId.ToString() + filePathDelimiter + configurationId.ToString() + filePathDelimiter;

            Guid fileId = await context.Repositories.ConfigurationRepository.GetTaskIDDetails(taskId, configurationId);

            if (fileId != Guid.Empty)
            {
                fileDeleted = await AzureFileHelper.RemoveFile(connectionString, blobContainer, uploadPath + fileId.ToString() + ".zip");
            }
            else
            {
                //for the initial upload file is not even presented for delete. So returning fileDeleted true
                fileDeleted = true;
            }
            return fileDeleted;
        }

        public async Task<DataCreationResultDTO> ImportMapInsets(int configurationId, string path, string mappackagetype, Guid userId, string pageName)
        {
            //Extract the Build
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string mapInsetPath = "";
            foreach (var filePath in filePaths)
            {
                if (File.Exists(filePath))
                {
                    mapInsetPath = zipFileExtractor(filePath, true);
                }
            }  
            DataCreationResultDTO dataCreationResultDTO = new DataCreationResultDTO();
            string connectionString = _configuration.AzureWebJobsStorage;
            string azureUrl = _configuration.AzureBlobURL;
            string blobContainer = _configuration.AzureBlobStorageContainerforHiFocusMapInsets;
            IDictionary<string, double> resolutionMap = new Dictionary<string, double>(){
                        {"t15", 15},
                        {"t7.5", 7.5},
                        {"t3.75", 3.75}
                        };
            string[] mapinsetNames = Directory.GetDirectories(mapInsetPath);
            if (mapinsetNames.Length == 0) return new DataCreationResultDTO { IsError = true, Message = "No Insets" };
            List<string> mappackagetypes = new List<string> { "landsat7", "landsat8" };
            bool isUhf = false;
            bool isHf = false;
            if (!mappackagetypes.Contains(mappackagetype)) return new DataCreationResultDTO { IsError = true, Message = "No Insets" };

            foreach (var inets in mapinsetNames)
            {
                var dir = new DirectoryInfo(inets);
                string insetName = dir.Name;
                double resolution;
                var resDirectories = dir.GetDirectories();
                var fileNames = Directory.GetDirectories(dir.FullName.ToLower()).Select(Path.GetFileName).ToArray();

                if (fileNames.Contains("t3.75"))
                {
                    isUhf = true;
                }
                if (fileNames.Contains("t7.5"))
                {
                    isHf = true;
                }
                foreach (var res in resDirectories)
                {
                    if (resolutionMap.ContainsKey(res.Name.ToLower()) && Directory.Exists(res.FullName.ToLower()))
                    {
                        if (resolutionMap.TryGetValue(res.Name.ToLower(), out resolution))
                        {
                            var result = await updatetblASXiInset(configurationId, insetName, res.FullName, resolution, mappackagetype, connectionString, blobContainer, userId, isUhf, isHf);
                            if (result > 0)
                            {
                                dataCreationResultDTO.IsError = false;
                                dataCreationResultDTO.Message = "Success";
                            }
                            else
                            {
                                dataCreationResultDTO.IsError = true;
                                dataCreationResultDTO.Message = "failure";
                                Directory.Delete(path, true);
                            }
                        }
                    }
                    else
                    {
                        _logger.LogWarn(String.Format(
                            "Inset is not presnt for the resolution [%s]", res.Name));
                    }
                }
            }
            //update FileUpload details to provide download options
            using var context = _unitOfWork.Create;
            string error = string.Empty;
            string azurePath = Path.Combine(azureUrl, blobContainer, configurationId.ToString());
            var updateResult = await context.Repositories.ConfigurationRepository.UpdateFilePath(azurePath, configurationId, mapInsetPath, userId, pageName, error);
            if (updateResult > 0)
            {
                await context.SaveChanges(); 
                dataCreationResultDTO.IsError = false;
                dataCreationResultDTO.Message = "Success";
            }
            else
            {
                dataCreationResultDTO.IsError = true;
                dataCreationResultDTO.Message = "failure";
            }
            return dataCreationResultDTO;
        }
        private async Task<int> updatetblASXiInset(int configurationId, string insetName, string insetPath, double zoomLevel, string mappackagetype, string connectionString, string blobContainer, Guid userId, bool isUhf, bool isHf)
        {
            ZipFile.CreateFromDirectory(insetPath, insetPath + ".zip");
            string uploadFile = insetPath + ".zip";
            FileInfo currentFile = new FileInfo(uploadFile);
            string blobName = $"{configurationId}/{insetName}/{zoomLevel}";
            
            await AzureFileHelper.UploadBlob(connectionString, blobContainer, blobName, currentFile.FullName);

            string azurePath = AzureFileHelper.getFilePath(connectionString, blobContainer, blobName, currentFile.FullName);
            using var context = _unitOfWork.Create;
            
            ASXiInset _mapInset = new ASXiInset();
            _mapInset.InsetName = insetName;
            _mapInset.Zoom = zoomLevel;
            _mapInset.Path = azurePath;
            _mapInset.MapPackageType = mappackagetype;
            _mapInset.IsHf = isHf;
            _mapInset.IsUHf = isUhf;
            TileMathHelper.GetTileBoundaries(_mapInset, insetPath);
            var result = await context.Repositories.ASXiInsetRepository.AddASXiInset(1, _mapInset, userId);
            if (result > 0)
            {
                await context.SaveChanges();
            } 
            return result;
        }

        public async Task<ActionResult> DownloadInsetsByRevision(int configurationId)
        {
            string tempStorage = _configuration.LocalTempStorageRoot;
            try
            {
                using var context = _unitOfWork.Create;
                if (tempStorage == null)
                {
                    return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "internal error: local storage path not configured" });
                }
                tempStorage = Path.Join(tempStorage, Path.GetRandomFileName());
                Directory.CreateDirectory(tempStorage);
                string outputFolder = Path.Combine(tempStorage, "output");
                if (!Directory.Exists(outputFolder))
                {
                    Directory.CreateDirectory(outputFolder);
                }
                string connectString = _configuration.AzureWebJobsStorage;
                string azureURL = _configuration.AzureBlobURL;
                string container = _configuration.AzureBlobStorageContainerforHiFocusMapInsets;
                var insets = await context.Repositories.ASXiInsetRepository.GetASXiInsets(configurationId);
                foreach (ASXiInset inset in insets)
                {
                    if (!string.IsNullOrEmpty(inset.Path))
                    {
                        string insetsOutPath = Path.Combine(outputFolder, "Insets", inset.InsetName, "t" + inset.Zoom.ToString() + ".zip");
                        if (!Directory.Exists(Path.Combine(outputFolder, "Insets", inset.InsetName)))
                        {
                            Directory.CreateDirectory(Path.Combine(outputFolder, "Insets", inset.InsetName));
                        }
                        string insetBlobName = AzureFileHelper.getBlobNameFromURL(inset.Path);
                        await AzureFileHelper.DownloadFromBlob(connectString, container, insetsOutPath, insetBlobName);
                        zipFileExtractor(insetsOutPath, true);
                        File.Delete(insetsOutPath);
                    }
                }
                    
                //build as a single zip file and return to UI
                if (Directory.Exists(Path.Combine(outputFolder, "Insets")))
                {
                    string outputFileName = Path.Combine(new DirectoryInfo(outputFolder).Parent.ToString() + "\\Insets.zip");
                    ZipFile.CreateFromDirectory(Path.Combine(outputFolder, "Insets"), outputFileName);
                    if (Directory.Exists(outputFolder))
                    {
                        Directory.Delete(outputFolder, true);
                    }
                    FileStream fileStream = new FileStream(outputFileName, FileMode.Open, FileAccess.Read, FileShare.Read);
                    return new FileStreamResult(fileStream, "application/zip");
                }
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "internal error: no files available" });
            }
            catch (Exception ex)
            {
                _logger.LogError("Download Insets failed for : " + ex);
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "internal error: Download Insets failed" });
            }
        }

        //infospelling
        private async Task<DataCreationResultDTO> UpdateInfoSpelling(int configurationId, string path, Guid userId)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string csvFilePath = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains(".csv"))
                    {
                        csvFilePath = f;
                    }

                }
                if (!File.Exists(csvFilePath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Import InfoSpelling");
            if (taskType == null)
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Unable to determine Task type"
                };

            bool fileType = await DeleteUploadedFile(taskType.ID, configurationId);
            if (fileType)
            {
                return await UploadToAzureBlobStorage(configurationId, taskType, userId, zipfilePath);
            }
            else
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "File deletion failed"
                };
            }
        }

        private async Task<DataCreationResultDTO> ImportCustomXML(int configurationId, string path, Guid userId)
        {
            string[] filePaths = Directory.GetFiles(path, "*.zip",
                                         SearchOption.AllDirectories);
            string zipfilePath = "";
            try
            {
                foreach (var filePath in filePaths)
                {
                    if (File.Exists(filePath))
                    {
                        zipfilePath = filePath;
                        zipFileExtractor(zipfilePath);
                    }
                }

                filePaths = Directory.GetFiles(path, ".",
                                             SearchOption.AllDirectories);
                string csvFilePath = "";
                foreach (var f in filePaths)
                {
                    if (f.ToLower().Contains("custom.xml"))
                    {
                        csvFilePath = f;
                    }

                }
                if (!File.Exists(csvFilePath))
                {
                    if (Directory.Exists(path)) Directory.Delete(path, true);
                    return new DataCreationResultDTO()
                    { IsError = true, Message = "The required files are missing" };
                }
            }
            catch (Exception ex)
            {
                if (Directory.Exists(path)) Directory.Delete(path, true);
                _logger.LogError("Exception raised: " + ex);
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Upload is not Successfull"
                };
            }
            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Import Initial Config - custom.xml");
            if (taskType == null)
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Unable to determine Task type"
                };

            bool fileType = await DeleteUploadedFile(taskType.ID, configurationId);
            if (fileType)
            {
                return await UploadToAzureBlobStorage(configurationId, taskType, userId, zipfilePath);
            }
            else
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "File deletion failed"
                };
            }
        }

        #endregion
    }
}
