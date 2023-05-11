using backend.BusinessLayer.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using backend.Helpers.Azure;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using backend.DataLayer.Models.CustomContent;
using System.Linq;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Task;

namespace backend.BusinessLayer.Services
{
    public class CustomContentService : ICustomContentService
    {
        private IUnitOfWork _unitOfWork;
        private Helpers.Configuration _configuration;
        private readonly ILoggerManager _logger;
        private readonly string imageContainerName;
        public CustomContentService(IUnitOfWork unitofWork, Helpers.Configuration configuration, ILoggerManager logger)
        {
            _unitOfWork = unitofWork;
            _configuration = configuration;
            _logger = logger;
            imageContainerName = _configuration.AzureBlobStorageContainerforImages;
        }
        public async Task<DataCreationResultDTO> UploadImageToAzure(int configurationId, IFormFile file, int type, string currentImageId, string resolutionId)
        {
            if (resolutionId != "-1")
            {
                return await UploadResolutionSepcImage(configurationId, file, type, currentImageId, resolutionId);
            }
            using var context = _unitOfWork.Create;
            string connectionString = _configuration.AzureWebJobsStorage;
            var resolutions = await context.Repositories.CustomContentRepository.GetResolutions();
            int maxImageId = await context.Repositories.CustomContentRepository.GetMaxImageId();
            int imageId = maxImageId + 1;

            MemoryStream ms = new MemoryStream();
            await file.OpenReadStream().CopyToAsync(ms);
            var imageNameGuid = Guid.NewGuid().ToString();
            var imageSplit = file.FileName.Split('.');
            var guidFileName = imageNameGuid + '.' + imageSplit[1];
            var uri = await AzureFileHelper.UploadFileBlobToPath(connectionString, imageContainerName, ms.ToArray(), guidFileName, imageId.ToString());
            var result = await context.Repositories.CustomContentRepository.InsertImages(configurationId, imageId, file.FileName, guidFileName, uri.AbsoluteUri, type);
            foreach (var str in resolutions)
            {
                var resolution = str.Value.ToUpper().Split('X');
                var image = Image.FromStream(file.OpenReadStream());
                var resized = new Bitmap(image, new Size(Convert.ToInt32(resolution[0]), Convert.ToInt32(resolution[1])));
                using var imageStream = new MemoryStream();
                resized.Save(imageStream, ImageFormat.Jpeg);
                var imageBytes = imageStream.ToArray();

                string folderPath = imageId.ToString() + '/' + str.Value;
                var imageURI = await AzureFileHelper.UploadFileBlobToPath(connectionString, imageContainerName, imageBytes, file.FileName, folderPath);
                await context.Repositories.CustomContentRepository.InsertResolutionSpecImage(configurationId, imageId, str.Key, imageURI.AbsoluteUri);
            }
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Image uploaded successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to upload image..!" };
        }

        private async Task<DataCreationResultDTO> UploadResolutionSepcImage(int configurationId, IFormFile file, int type, string currentImageId, string resolutionId)
        {
            using var context = _unitOfWork.Create;
            string connectionString = _configuration.AzureWebJobsStorage;

            var resolutions = await context.Repositories.CustomContentRepository.GetResolutions();
            string selectedResulution;
            resolutions.TryGetValue(Convert.ToInt32(resolutionId), out selectedResulution);
            MemoryStream ms = new MemoryStream();
            await file.OpenReadStream().CopyToAsync(ms);
            var imageInfo = await context.Repositories.CustomContentRepository.GetImageDetails(configurationId, Convert.ToInt32(currentImageId));
            string folderPath = currentImageId.ToString() + '/' + selectedResulution;
            await AzureFileHelper.RemoveFile(connectionString, imageContainerName, folderPath + "/" + imageInfo.ImageName);

            var imageURI = await AzureFileHelper.UploadFileBlobToPath(connectionString, imageContainerName, ms.ToArray(), imageInfo.ImageName, folderPath);
            await context.Repositories.CustomContentRepository.UpdateResolutionSpecImage(configurationId, Convert.ToInt32(currentImageId), Convert.ToInt32(resolutionId), imageURI.AbsoluteUri);
            await context.SaveChanges();
            return new DataCreationResultDTO { IsError = false, Message = "Image uploaded successfully..!" };
        }

        public async Task<List<string>> GetResolutionText(int configurationId, string resolutionId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetResolutionText(configurationId, resolutionId);

        }

        public async Task<List<ImageDetails>> GetConfigImages(int configurationId, int type)
        {
            using var context = _unitOfWork.Create;
            var images = await context.Repositories.CustomContentRepository.GetConfigImages(configurationId, type);

            return images;
        }

        public async Task<DataCreationResultDTO> DeleteImage(int configurationId, int imageId, int type)
        {
            using var context = _unitOfWork.Create;
            string connectionString = _configuration.AzureWebJobsStorage;
            //var imageInfo = await context.Repositories.CustomContentRepository.GetImageDetails(configurationId, imageId);
            //var resolutions = await context.Repositories.CustomContentRepository.GetResolutions();
            var result = await context.Repositories.CustomContentRepository.DeleteImage(configurationId, imageId);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Image deleted successfully..!" };
            }
            //if (!await AzureFileHelper.RemoveFile(connectionString, imageContainerName, imageId.ToString() + "/" + imageInfo.ImageName))
            //{
            //    return new DataCreationResultDTO { IsError = true, Message = "Failed to delete image..!" };
            //}
            //if (result > 0)
            //{
            //    if (resolutions.Count > 0)
            //    {
            //        foreach (var image in resolutions)
            //        {
            //            if (!await AzureFileHelper.RemoveFile(connectionString, imageContainerName, imageId.ToString() + "/" + image.Value + "/" + imageInfo.ImageName))
            //                return new DataCreationResultDTO { IsError = true, Message = "Failed to delete image..!" };
            //        }
            //    }
            //    else
            //        return new DataCreationResultDTO { IsError = true, Message = "Failed to delete image..!" };
            //    await context.SaveChanges();
            //    return new DataCreationResultDTO { IsError = false, Message = "Image deleted successfully..!" };
            //}
            return new DataCreationResultDTO { IsError = true, Message = "Failed to delete image..!" };
        }
        public async Task<Dictionary<int, string>> GetResolutions()
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetResolutions();
        }

        public async Task<DataCreationResultDTO> SetConfigImage(int configurationId, string imageIds, int type, int scriptId, int index)
        {
            using var context = _unitOfWork.Create;
            imageIds = imageIds.Replace("-1", "");
            imageIds=imageIds.Replace("-1", "").TrimStart(',').TrimEnd(',');
            var result = "0";
            result = await context.Repositories.CustomContentRepository.SetConfigImage(configurationId, imageIds, type, scriptId, index);
            if (type == (int)ImageType.Script)
            {
                var scriptItem = await context.Repositories.ScriptConfigurationRepository.GetScriptItemDetails(scriptId, index, configurationId);
                scriptItem.FileName = result;
                var tempResult = await context.Repositories.ScriptConfigurationRepository.SaveScriptItem(scriptItem, scriptId, configurationId);
                result = tempResult.Result.ToString();
            }
            if (Convert.ToInt32(result) > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Config updated successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to update config..!" };
        }

        public async Task<Dictionary<string, int>> GetImageCount(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetImageCount(configurationId);
        }

        public async Task<List<ImageDetails>> PreviewImages(int configurationId, int imageId, int type)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.PreviewImages(configurationId, imageId, type);
        }
        public async Task<List<City>> GetAllCities(int configurationId, string type)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetAllCities(configurationId, type);

        }

        public async Task<DataCreationResultDTO> RenameFile(int configurationId, int imageId, int type, string fileName)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.CustomContentRepository.RenameFile(configurationId, imageId, type, fileName);
            if (Convert.ToInt32(result) > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "File name modified..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to modify the file name..!" };
        }
        public async Task<List<City>> GetSelectedHFCities(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetSelectedHFCities(configurationId);

        }


        public async Task<DataCreationResultDTO> SelectHFCity(int configurationId, int[] cities)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.CustomContentRepository.SelectHFCity(configurationId, cities);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "City updated successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to update city..!" };

        }
        public async Task<DataCreationResultDTO> DeleteHFCity(int configurationId, int aSXiInsetID)
        {
            using var context = _unitOfWork.Create;
            string connectionString = _configuration.AzureWebJobsStorage;
            var result = await context.Repositories.CustomContentRepository.DeleteHFCity(configurationId, aSXiInsetID);
            if (result > 0)
            {
                //if (await AzureFileHelper.RemoveFile(connectionString, "images", imageId.ToString()))
                //{
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "City deleted successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to delete city..!" };
        }

        public async Task<DataCreationResultDTO> DeleteAllHFCities(int configurationId, int[] aSXiInsetIDs)
        {
            using var context = _unitOfWork.Create;
            string connectionString = _configuration.AzureWebJobsStorage;
            var result = await context.Repositories.CustomContentRepository.DeleteAllHFCities(configurationId, aSXiInsetIDs);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "All High focus cities deleted successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to delete cities..!" };
        }

        //Ultra high focus
        public async Task<List<City>> GetSelectedUHFCities(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetSelectedUHFCities(configurationId);

        }

        public async Task<DataCreationResultDTO> SelectUHFCity(int configurationId, int[] cities)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.CustomContentRepository.SelectUHFCity(configurationId, cities);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "City updated successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to update city..!" };

        }

        public async Task<DataCreationResultDTO> DeleteUHFCity(int configurationId, int aSXiInsetID)
        {
            using var context = _unitOfWork.Create;
            string connectionString = _configuration.AzureWebJobsStorage;
            var result = await context.Repositories.CustomContentRepository.DeleteUHFCity(configurationId, aSXiInsetID);
            if (result > 0)
            {
                //if (await AzureFileHelper.RemoveFile(connectionString, "images", imageId.ToString()))
                //{
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "City deleted successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to delete city..!" };
        }

        public async Task<DataCreationResultDTO> DeleteAllUHFCities(int configurationId, int[] aSXiInsetIDs)
        {
            using var context = _unitOfWork.Create;
            string connectionString = _configuration.AzureWebJobsStorage;
            var result = await context.Repositories.CustomContentRepository.DeleteAllUHFCities(configurationId, aSXiInsetIDs);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "All Ultra high focus cities deleted successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to delete cities..!" };
        }

        public async Task<List<PlaceName>> GetPlaceNames(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetPlaceNames(configurationId);
        }

        public async Task<List<PlaceNameLanguage>> GetPlaceNameInfo(int configurationId, int placeNameId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetPlaceNameInfo(configurationId, placeNameId);
        }

        public async Task<List<PlaceCatType>> GetCatTypes(int configurationId, int placeNameId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetCatTypes(configurationId, placeNameId);
        }

        public async Task<List<Visibility>> GetVisibility(int configurationId, int placeNameGeoRefId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetVisibility(configurationId, placeNameGeoRefId);
        }

        public async Task<DataCreationResultDTO> UpdatePlaceNameCatType(int configurationId, int placeNameId, int catType , Guid userId)
        {
            using var context = _unitOfWork.Create;
            ListModlist listModlistInfo = new ListModlist();
            listModlistInfo.ModlistArray = new List<ModlistInfo>();
            List<string> resolutions = new List<string>();
            Helpers.ModListHelper modListHelper = new Helpers.ModListHelper();
            Helpers.ModListData _modlistdata = new Helpers.ModListData();
            string landSatValue = await context.Repositories.AirportInfo.getlandsatvalue(configurationId);
            var data = await context.Repositories.ConfigurationRepository.GetFeature(configurationId, "Modlist-resolutions");
            var geodata = await context.Repositories.CustomContentRepository.GetLatLonValue(placeNameId, 0);
            resolutions = data.Value.Split(",").ToList();


            if (!string.IsNullOrWhiteSpace(landSatValue) && resolutions.Count > 0)
            {
                resolutions.ForEach(resolution =>
                {
                    ModlistInfo modlist = new ModlistInfo();
                    _modlistdata = modListHelper.ModlistCalculator(Convert.ToSingle(geodata.Lat1), Convert.ToSingle(geodata.Lon1), double.Parse(resolution), landSatValue);

                    modlist.Row = _modlistdata.Row;
                    modlist.Column = _modlistdata.Column;
                    modlist.Resolution = _modlistdata.Resolution;

                    listModlistInfo.ModlistArray.Add(modlist);
                });

            }
            listModlistInfo.Lat1 = geodata.Lat1;
            listModlistInfo.Lon1 = geodata.Lon1;
            listModlistInfo.CatType = catType;
            var result = await context.Repositories.CustomContentRepository.UpdatePlaceNameCatType(configurationId, placeNameId, listModlistInfo);
            if (result > 0)
            {
                await context.SaveChanges();
                var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Build Modlist Json");


                if (definition == null)
                {
                    return new DataCreationResultDTO { IsError = false, Message = "Cat Type updated successfully..!" };

                }

                BuildQueueItem queue = new BuildQueueItem
                {
                    Debug = false,
                    Config = new BuildTask()
                };
                queue.Config.ID = Guid.NewGuid();
                queue.Config.ConfigurationID = configurationId;
                queue.Config.ConfigurationDefinitionID = definition.ConfigurationDefinitionId;
                queue.Config.TaskTypeID = taskType.ID;
                queue.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                queue.Config.DateStarted = DateTime.Now;
                queue.Config.DateLastUpdated = DateTime.Now;
                queue.Config.PercentageComplete = 0f;
                queue.Config.StartedByUserID = userId;

                await context.Repositories.Simple<BuildTask>().InsertAsync(queue.Config);
                return new DataCreationResultDTO { IsError = false, Message = "Cat Type updated successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to update Cat Type..!" };
        }

        public async Task<DataCreationResultDTO> SavePlaceNameSpelling(int configurationId, int placeNameGeoRefId, PlaceNameLanguage[] placeNameLanguages)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.CustomContentRepository.SavePlaceNameSpelling(configurationId, placeNameGeoRefId, placeNameLanguages);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Place Name saved successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to Save place name..!" };
        }

        public async Task<PlaceName> GetAdvancedPlaceNameInfo(int configurationId, int placeNameId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.CustomContentRepository.GetAdvancedPlaceNameInfo(configurationId, placeNameId);
        }

        public async Task<DataCreationResultPlaceName> SavePlaceInfo(int configurationId, PlaceName placeName, Guid userId)
        {
            using var context = _unitOfWork.Create;
            int returnId = 0;
            int returnGeoRefId = 0;
            ListModlistsave listModlistInfosave = new ListModlistsave();
            listModlistInfosave.ModlistArrayPlaceName = new List<ModlistInfo>();
            List<string> resolutions = new List<string>();
            Helpers.ModListHelper modListHelper = new Helpers.ModListHelper();
            Helpers.ModListData _modlistdata = new Helpers.ModListData();
            string landSatValue = await context.Repositories.AirportInfo.getlandsatvalue(configurationId);
            var data = await context.Repositories.ConfigurationRepository.GetFeature(configurationId, "Modlist-resolutions");
            resolutions = data.Value.Split(",").ToList();
            if (!string.IsNullOrWhiteSpace(landSatValue) && resolutions.Count > 0)
            {
                resolutions.ForEach(resolution =>
                {
                    ModlistInfo modlist = new ModlistInfo();
                    _modlistdata = modListHelper.ModlistCalculator(Convert.ToSingle(placeName.Lat1), Convert.ToSingle(placeName.Lon1), double.Parse(resolution), landSatValue);
                    modlist.Row = _modlistdata.Row;
                    modlist.Column = _modlistdata.Column;
                    modlist.Resolution = _modlistdata.Resolution;
                    listModlistInfosave.ModlistArrayPlaceName.Add(modlist);
                });
            }
            listModlistInfosave.Lat1 = placeName.Lat1;
            listModlistInfosave.Lon1 = placeName.Lon1;
            listModlistInfosave.Lat2 = placeName.Lat2;
            listModlistInfosave.Lon2 = placeName.Lon2;
            listModlistInfosave.Id = placeName.Id;
            listModlistInfosave.GeoRefId = placeName.GeoRefId;
            listModlistInfosave.CountryId = placeName.CountryId;
            listModlistInfosave.CountryName = placeName.CountryName;
            listModlistInfosave.Name = placeName.Name;
            listModlistInfosave.RegionId = placeName.RegionId;
            listModlistInfosave.RegionName = placeName.RegionName;
            listModlistInfosave.SegmentId = placeName.SegmentId;
            var result = await context.Repositories.CustomContentRepository.SavePlaceInfo(configurationId, listModlistInfosave);
            if (result.Count > 0)
            {
                foreach (var item in result)
                {
                    returnId = item.Key;
                    returnGeoRefId = item.Value;
                }
                await context.SaveChanges();
                var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Build Modlist Json");

               
                if (definition == null)
                {
                    return new DataCreationResultPlaceName { IsError = false, Message = "Place Name saved successfully..!", ReturnId = returnId, ReturnGeoRefId = returnGeoRefId };
                   
                }
                
                    BuildQueueItem queue = new BuildQueueItem
                    {
                        Debug = false,
                        Config = new BuildTask()
                    };
                    queue.Config.ID = Guid.NewGuid();
                    queue.Config.ConfigurationID = configurationId;
                    queue.Config.ConfigurationDefinitionID = definition.ConfigurationDefinitionId;
                    queue.Config.TaskTypeID = taskType.ID;
                    queue.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                    queue.Config.DateStarted = DateTime.Now;
                    queue.Config.DateLastUpdated = DateTime.Now;
                    queue.Config.PercentageComplete = 0f;
                    queue.Config.StartedByUserID = userId;

                    await context.Repositories.Simple<BuildTask>().InsertAsync(queue.Config);
                   

                    return new DataCreationResultPlaceName { IsError = false, Message = "Place Name saved successfully..!", ReturnId = returnId, ReturnGeoRefId = returnGeoRefId };
                
            }

            return new DataCreationResultPlaceName { IsError = true, Message = "Failed to Save place name..!" };
        }

        public async Task<DataCreationResultDTO> SaveVisibility(int configurationId, int PlaceNameGeoRefId, Visibility[] visibilities, Guid userId)
        {
            using var context = _unitOfWork.Create;
            ListModlistVisiblity listModlistInfosaveVisiblity = new ListModlistVisiblity();
            listModlistInfosaveVisiblity.ModlistArrayVisiblity = new List<ModlistInfo>();
            List<string> resolutions = new List<string>();
            Helpers.ModListHelper modListHelper = new Helpers.ModListHelper();
            Helpers.ModListData _modlistdata = new Helpers.ModListData();
            string landSatValue = await context.Repositories.AirportInfo.getlandsatvalue(configurationId);
            var data = await context.Repositories.ConfigurationRepository.GetFeature(configurationId, "Modlist-resolutions");
            var visiblityData = await context.Repositories.CustomContentRepository.GetLatLonValue(0, PlaceNameGeoRefId);
            resolutions = data.Value.Split(",").ToList();
            if (!string.IsNullOrWhiteSpace(landSatValue) && resolutions.Count > 0)
            {
                resolutions.ForEach(resolution =>
                {
                    ModlistInfo modlist = new ModlistInfo();
                    _modlistdata = modListHelper.ModlistCalculator(Convert.ToSingle(visiblityData.Lat1), Convert.ToSingle(visiblityData.Lon1), double.Parse(resolution), landSatValue);
                    modlist.Row = _modlistdata.Row;
                    modlist.Column = _modlistdata.Column;
                    modlist.Resolution = _modlistdata.Resolution;
                    listModlistInfosaveVisiblity.ModlistArrayVisiblity.Add(modlist);
                });
            }
            var result = await context.Repositories.CustomContentRepository.SaveVisibility(configurationId, PlaceNameGeoRefId, visibilities, listModlistInfosaveVisiblity);
            if (result > 0)
            {
                await context.SaveChanges();
                var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Build Modlist Json");


                if (definition == null)
                {
                    return  new DataCreationResultDTO { IsError = false, Message = "Place Name saved successfully..!" };

                }

                BuildQueueItem queue = new BuildQueueItem
                {
                    Debug = false,
                    Config = new BuildTask()
                };
                queue.Config.ID = Guid.NewGuid();
                queue.Config.ConfigurationID = configurationId;
                queue.Config.ConfigurationDefinitionID = definition.ConfigurationDefinitionId;
                queue.Config.TaskTypeID = taskType.ID;
                queue.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                queue.Config.DateStarted = DateTime.Now;
                queue.Config.DateLastUpdated = DateTime.Now;
                queue.Config.PercentageComplete = 0f;
                queue.Config.StartedByUserID = userId;

                await context.Repositories.Simple<BuildTask>().InsertAsync(queue.Config);
                return new DataCreationResultDTO { IsError = false, Message = "Place Name saved successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to Save place name..!" };
        }


        public async Task<InfoSepllingDisplay> GetInfoSpelling(int configurationId)
        {

            using var context = _unitOfWork.Create;

            var dbLanguages = await context.Repositories.Simple<Language>().FilterMappedAsync(configurationId);
            //var allLanguages = await context.Repositories.Simple<Language>().FindAllAsync();

            var defaultLangauge = dbLanguages.Find(item => item.ID == -1);
            if (defaultLangauge != null)
            {
                dbLanguages.Remove(defaultLangauge);
            }

            var infoSepllings = await context.Repositories.CustomContentRepository.GetInfoSpelling(configurationId, dbLanguages);

            InfoSepllingDisplay displayItem = new InfoSepllingDisplay();

            displayItem.Headers = dbLanguages;
            displayItem.Spellings = infoSepllings;
            return displayItem;

        }

        public async Task<DataCreationResultDTO> UpdateInfoSpelling(int configurationId, int infoId, KeyValues[] keyVal)
        {
            using var context = _unitOfWork.Create;
            var listObj = keyVal.ToList();
            foreach (var item in listObj)
            {
                infoId = await context.Repositories.CustomContentRepository.UpdateInfoSpelling(configurationId, infoId, item.Key, item.Value);
            }
            if (infoId >= 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Info Spelling Updated successfully..!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to Update Info Spelling..!" };
        }

    }
}
