using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Task;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers.Azure;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services.Export
{
    public class ExportService : IExportService
    {
        private IUnitOfWork _unitOfWork;
        private Helpers.Configuration _configuration;
        private IAzureBlobService _blobService;

        public ExportService(IUnitOfWork unitOfWork, Helpers.Configuration configuration, IAzureBlobService blobService)
        {
            _unitOfWork = unitOfWork;
            _configuration = configuration;
            _blobService = blobService;
        }

        public async Task<ActionResult> DownloadProductByDefinition(int configurationDefinitionId, UserListDTO user)
        {
            using var context = _unitOfWork.Create;
            var configuration = await context.Repositories.ConfigurationDefinitions.GetLatestConfiguration(configurationDefinitionId);
            if (configuration == null)
            {
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "no configuration defined" });
            }
            context.Dispose();

            return await DownloadProduct(configuration.ConfigurationId, user);
        }

        /**
         * method that triggers a download of the product database. This method will search the build history
         * for a build that has already been successful and return a file stream to that output file
         * if one is not found then if a build is in progress the id of the build is provided, otherwise
         * a new build is created based off of the configuration definitions output type
         **/
        public async Task<ActionResult> DownloadProduct(int configurationId, UserListDTO user)
        {
            using var context = _unitOfWork.Create;

            // assumes that only a single in-progress or successful export is present. failed ones are ignored
            // if this assumption changes for some reason then we will need to adjust the logic here accordingly
            var tasks = await context.Repositories.BuildTaskRepository.GetProductExports(configurationId);
            var config = await context.Repositories.Simple<backend.DataLayer.Models.Configuration.Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (config == null)
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "invalid configuration" });

            var definition = await context.Repositories.Simple<ConfigurationDefinition>().FirstAsync("ConfigurationDefinitionID", config.ConfigurationDefinitionId);
            if (definition == null)
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "invalid configuration definition" });

            var topLevePartNumber = await context.Repositories.ConfigurationDefinitions.GetTopLevelPartNumber(definition.ConfigurationDefinitionID);
            // more than one export present ... whoops, return an error
            if (tasks.Count > 1)
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "internal error: multiple exports present" });

            // only one record, check if its finished, if not return its id
            else if (tasks.Count == 1)
            {
                
                if (tasks[0].TaskStatusID == (int)DataLayer.Models.Task.TaskStatus.Succeeded)
                {
                    var fileName = tasks[0].ID.ToString().ToLower();
                    //if (!string.IsNullOrEmpty(topLevePartNumber.TopLevelPartnumber))
                    //{
                    //    fileName = topLevePartNumber.TopLevelPartnumber.ToLower();
                    //}
                    var blobConnectionString = _configuration.AzureExportBlobStorage;
                    var blobContainerName = _configuration.AzureExportBlobStorageContainer;
                    var blobName = $"{fileName}.zip";
                    var blobStream = await _blobService.OpenBlobStream(
                        blobConnectionString,
                        blobContainerName,
                        blobName);
                    return new FileStreamResult(blobStream, "application/zip");
                }

                return new OkObjectResult(new DataCreationResultDTO { IsError = false, Id = tasks[0].ID });
            }

            // no records that we could reference, lets kick off a new export for the record based off of its output type and
            // return the build id

            var outputType = await context.Repositories.Simple<OutputType>().FirstAsync("OutputTypeID", definition.OutputTypeID);

            OutputTypeEnum outputTypeEnum = (OutputTypeEnum)Enum.Parse(typeof(OutputTypeEnum), outputType.OutputTypeName, true);

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
            }
            if (taskType == null)
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "internal error: could not determine task type" });
            var taskTypeRecord = await context.Repositories.Simple<TaskType>().FirstAsync("Name", taskType);

            BuildQueueItem item = new BuildQueueItem();
            item.Debug = false;
            item.Config = new BuildTask();
            item.Config.ID = Guid.NewGuid();
            item.Config.ConfigurationDefinitionID = config.ConfigurationDefinitionId; 
            item.Config.ConfigurationID = configurationId;
            item.Config.StartedByUserID = user.Id;
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

            string connectionString = _configuration.AzureWebJobsStorage;
            string queueName = _configuration.AzureWebJobsQueue;
            string message = JsonConvert.SerializeObject(item);
            var bytes = Encoding.ASCII.GetBytes(message);
            var base64 = Convert.ToBase64String(bytes);
            await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);

            return new OkObjectResult(new DataCreationResultDTO()
            {
                IsError = false,
                Id = item.Config.ID
            });
        }

        public async Task<DataCreationResultDTO> ExportDevelopmentConfig(int configurationId, UserListDTO user)
        {
            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Export Development Config");
            if (taskType == null)
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "unable to determine export type"
                };


            var definition = await context.Repositories.Simple<backend.DataLayer.Models.Configuration.Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (definition == null)
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "invalid configuration"
                };

            BuildQueueItem item = new BuildQueueItem();
            item.Debug = false;
            item.Config = new BuildTask();
            item.Config.ConfigurationID = configurationId;
            item.Config.ID = Guid.NewGuid();
            item.Config.TaskTypeID = taskType.ID;
            item.Config.StartedByUserID = user.Id;
            item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
            item.Config.DateStarted = DateTime.Now;
            item.Config.DateLastUpdated = DateTime.Now;
            item.Config.PercentageComplete = 0f;
            item.Config.ConfigurationDefinitionID = definition.ConfigurationDefinitionId;
            
            // look for an associated aircraft id
            var aircraftConfiguration = await context.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("ConfigurationDefinitionID", definition.ConfigurationDefinitionId);
            if (aircraftConfiguration != null)
                item.Config.AircraftID = aircraftConfiguration.AircraftID;
            
            await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
            await context.SaveChanges();

            // build the queue message and uploaded it to azure for the webjobs to see
            string connectionString = _configuration.AzureWebJobsStorage;
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
    }
}
