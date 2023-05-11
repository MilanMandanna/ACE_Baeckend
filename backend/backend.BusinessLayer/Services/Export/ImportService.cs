using backend.BusinessLayer.Contracts;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Task;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers;
using backend.Helpers.Azure;
using backend.Helpers.Validator;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Configuration = backend.DataLayer.Models.Configuration.Configuration;

namespace backend.BusinessLayer.Services.Export
{

    public class ImportService : IImportService
    {
        private IUnitOfWork _unitOfWork;
        private Helpers.Configuration _configuration;
        private readonly ILoggerManager _logger;

        public ImportService(IUnitOfWork unitofWork, Helpers.Configuration configuration, ILoggerManager logger)
        {
            _unitOfWork = unitofWork;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<DataCreationResultDTO> ImportInitialConfig(int configurationId, UserListDTO user, string filePath, string taskName)
        {
            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", taskName);
            if (taskType == null)
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "unable to determine Task type"
                };

            var definition = await context.Repositories.Simple<backend.DataLayer.Models.Configuration.Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (definition == null)
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "invalid configuration"
                };

            BuildQueueItem item = new BuildQueueItem
            {
                Debug = false,
                Config = new BuildTask
                {
                    ConfigurationID = configurationId,
                    ID = Guid.NewGuid(),
                    TaskTypeID = taskType.ID,
                    StartedByUserID = user.Id,
                    TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted,
                    DateStarted = DateTime.Now,
                    DateLastUpdated = DateTime.Now,
                    PercentageComplete = 0f,
                    ConfigurationDefinitionID = definition.ConfigurationDefinitionId
                }
            };

            // look for an associated aircraft id
            var aircraftConfiguration = await context.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("ConfigurationDefinitionID", definition.ConfigurationDefinitionId);
            if (aircraftConfiguration != null)
                item.Config.AircraftID = aircraftConfiguration.AircraftID;

            await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
            await context.SaveChanges();


            //Upload the file to Blob container
            string connectionString = _configuration.AzureWebJobsStorage;
            string blobContainer = _configuration.AzureImportBlobStorageContainer;
            string blobName = definition.ConfigurationDefinitionId + "\\" + configurationId + "\\" + item.Config.ID.ToString() + ".zip";
            FileInfo currentFile = new FileInfo(filePath);
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
                Id = item.Config.ID
            };

        }

        /**
         * This function upload  all custom content package to cloud and update ConfigurationCoponent table for given
         * Configuration
         **/
        public async Task<int> UpdatetblConfigurationComponent(int configurationId, CustomComponentFile ccFile, string connectionString, string blobContainer, ConfigurationCustomComponentType componentType, Guid userId)
        {
            try
            {
                using var context = _unitOfWork.Create;

                var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                if (definition == null)
                {
                    return 0;
                }
                FileInfo currentFile = new FileInfo(ccFile.FilePath);
                string blobName = definition.ConfigurationDefinitionId + "\\" + configurationId + "\\" + currentFile.Name;
                await AzureFileHelper.UploadBlob(connectionString, blobContainer, blobName, currentFile.FullName);
                string azurePath = AzureFileHelper.getFilePath(connectionString, blobContainer, blobName, currentFile.FullName);

                ConfigurationComponents currentConfigurationComponent = null;

                // new currentConfigurationComponent being created
                if (currentConfigurationComponent == null)
                {
                    var sasUrl = await AzureFileHelper.GetSASURL(currentFile.Name, blobName, blobContainer, connectionString);
                    var truncatedUrl = sasUrl.ToString()[(sasUrl.ToString().LastIndexOf('/') + 1)..];

                    var result = await context.Repositories.ConfigurationRepository.UpdateFilePath(truncatedUrl, configurationId, currentFile.Name, userId, GetDescriptionFromEnum(componentType), "");
                    if (result > 0)
                    {
                        await context.SaveChanges();
                    }
                    return result;
                }
                else
                    return 0;
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

        /**
         * This function upload  all custom content package to cloud for given configuration
         **/
        public async Task<DataCreationResultDTO> ImportCustomContent(int configurationId, FileUploadType fp, UserListDTO user)
        {

            DataCreationResultDTO dataCreationResultDTO = new DataCreationResultDTO();
            string connectionString = _configuration.AzureWebJobsStorage;
            //string blobContainer = _configuration.AzureBlobStorageContainerforCustomContents;
            string blobContainer = _configuration.AzureBlobStorageContainerforCollinsAdminAssets;
            if (fp != null)
            {
                if (fp._ccConfigData.IsFilePresent)
                {
                    var result = await UpdatetblConfigurationComponent(configurationId, fp._ccConfigData, connectionString, blobContainer, ConfigurationCustomComponentType.FlightDataconfiguration, user.Id);
                    if (result > 0)
                    {
                        dataCreationResultDTO.IsError = false;
                        dataCreationResultDTO.Message = "Success";
                    }
                    else
                    {
                        dataCreationResultDTO.IsError = true;
                        dataCreationResultDTO.Message = "failure";
                    }
                }
                //if (fp._ccBriefingsConfig.IsFilePresent)
                //{
                //    var result = await UpdatetblConfigurationComponent(configurationId, fp._ccBriefingsConfig, connectionString, blobContainer, ConfigurationCustomComponentType.Briefingsconfiguration, user.Id);
                //    if (result > 0)
                //    {
                //        dataCreationResultDTO.IsError = false;
                //        dataCreationResultDTO.Message = "Success";
                //    }
                //    else
                //    {
                //        dataCreationResultDTO.IsError = true;
                //        dataCreationResultDTO.Message = "failure";
                //    }
                //}
                if (fp._ccHDBriefings.IsFilePresent)
                {
                    var result = await UpdatetblConfigurationComponent(configurationId, fp._ccHDBriefings, connectionString, blobContainer, ConfigurationCustomComponentType.Briefingsconfiguration, user.Id);
                    if (result > 0)
                    {
                        dataCreationResultDTO.IsError = false;
                        dataCreationResultDTO.Message = "Success";
                    }
                    else
                    {
                        dataCreationResultDTO.IsError = true;
                        dataCreationResultDTO.Message = "failure";
                    }
                }
                if (fp._ccBuildSupportScripts.IsFilePresent)
                {
                    var result = await UpdatetblConfigurationComponent(configurationId, fp._ccBuildSupportScripts, connectionString, blobContainer, ConfigurationCustomComponentType.VenueNextscripts, user.Id);
                    if (result > 0)
                    {
                        dataCreationResultDTO.IsError = false;
                        dataCreationResultDTO.Message = "Success";
                    }
                    else
                    {
                        dataCreationResultDTO.IsError = true;
                        dataCreationResultDTO.Message = "failure";
                    }
                }
                if (fp._cciPadConfigzip.IsFilePresent)
                {
                    var result = await UpdatetblConfigurationComponent(configurationId, fp._cciPadConfigzip, connectionString, blobContainer, ConfigurationCustomComponentType.mmobileccconfiguration, user.Id);
                    if (result > 0)
                    {
                        dataCreationResultDTO.IsError = false;
                        dataCreationResultDTO.Message = "Success";
                    }
                    else
                    {
                        dataCreationResultDTO.IsError = true;
                        dataCreationResultDTO.Message = "failure";
                    }
                }
                if (fp._ccModels.IsFilePresent)
                {
                    var result = await UpdatetblConfigurationComponent(configurationId, fp._ccModels, connectionString, blobContainer, ConfigurationCustomComponentType.content3daircraftmodels, user.Id);
                    if (result > 0)
                    {
                        dataCreationResultDTO.IsError = false;
                        dataCreationResultDTO.Message = "Success";
                    }
                    else
                    {
                        dataCreationResultDTO.IsError = true;
                        dataCreationResultDTO.Message = "failure";
                    }
                }
                if (fp._ccTextures.IsFilePresent)
                {
                    var result = await UpdatetblConfigurationComponent(configurationId, fp._ccTextures, connectionString, blobContainer, ConfigurationCustomComponentType.Texturesconfiguration, user.Id);
                    if (result > 0)
                    {
                        dataCreationResultDTO.IsError = false;
                        dataCreationResultDTO.Message = "Success";
                    }
                    else
                    {
                        dataCreationResultDTO.IsError = true;
                        dataCreationResultDTO.Message = "failure";
                    }
                }

                if (fp._ccTicker.IsFilePresent)
                {
                    var result = await UpdatetblConfigurationComponent(configurationId, fp._ccTicker, connectionString, blobContainer, ConfigurationCustomComponentType.tickeradsconfiguration, user.Id);
                    if (result > 0)
                    {
                        dataCreationResultDTO.IsError = false;
                        dataCreationResultDTO.Message = "Success";
                    }
                    else
                    {
                        dataCreationResultDTO.IsError = true;
                        dataCreationResultDTO.Message = "failure";
                    }
                }
            }
            else
            {
                dataCreationResultDTO.IsError = true;
                dataCreationResultDTO.Message = "failure";
            }
            return dataCreationResultDTO;
        }
    }
}
