using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.MergeConfiguration;
using backend.DataLayer.Models.Task;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers;
using backend.Helpers.Azure;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Configuration = backend.DataLayer.Models.Configuration.Configuration;

namespace backend.BusinessLayer.Services
{
    public  class MergeConfigurationService : IMergeConfigurationService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly Helpers.Configuration _configuration;
        private readonly ILoggerManager _logger;

        public MergeConfigurationService(IUnitOfWork unitOfWork, Helpers.Configuration configuration, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _configuration = configuration;
            _logger = logger;
        }

        /// <summary>
        /// Method to get all the versions which are available for update.
        /// </summary>
        /// <param name="configurationDefinitionID"></param>
        /// <returns></returns>
        public async Task<List<MergeConfigurationUpdateDetails>> GetMergeConfigurationUpdateDetails(int configurationDefinitionID)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.MergeConfigurationRepository.GetMergeConfigurationUpdateDetails(configurationDefinitionID);
        }

        public async Task<MergeConfigurationAvailable> CheckUpdatesAvailable(int definitionId, int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.MergeConfigurationRepository.CheckUpdatesAvailable(definitionId, configurationId);
        }

        public async Task<ActionResult> DownloadVersionUpdatesReport(int configurationId, List<string> configurationIds)
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
                foreach (string configId in configurationIds)
                {
                    string versionUpdateReportDownloadPath = Path.Combine(outputFolder, "VersionUpdates.zip");
                    //Download file from azure
                    string container = _configuration.AzureBlobStorageContainerforVersionUpdates;
                    string connectString = _configuration.AzureWebJobsStorage;
                    var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configId);
                    if (definition != null)
                    {
                        string blobName = definition.ConfigurationDefinitionId + "\\" + configId + "\\" + "VersionUpdates.zip";
                        if (AzureFileHelper.BlobExists(connectString, container, blobName))
                        {
                            await AzureFileHelper.DownloadFromBlob(connectString, container, versionUpdateReportDownloadPath, blobName);
                            //Extract the file and copy to result folder
                            string versionUpdateReportExtractPath = Regex.Replace(versionUpdateReportDownloadPath, ".zip", "");
                            ZipFile.ExtractToDirectory(versionUpdateReportDownloadPath, versionUpdateReportExtractPath);
                            if (File.Exists(versionUpdateReportDownloadPath))
                            {
                                File.Delete(versionUpdateReportDownloadPath);
                            }
                        }
                    }
                }

                //build as a single zip file and return to UI
                if (Directory.Exists(Path.Combine(outputFolder, "VersionUpdates")))
                {
                    string outputFileName = Path.Combine(new DirectoryInfo(outputFolder).Parent.ToString() + "\\VersionUpdates.zip");
                    ZipFile.CreateFromDirectory(Path.Combine(outputFolder, "VersionUpdates"), outputFileName);
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
                _logger.LogError("DownloadVersionUpdate Report failed for : " + ex);
                return new OkObjectResult(new DataCreationResultDTO { IsError = true, Message = "internal error: DownloadVersionUpdate Report failed" });
            }
        }
        public async Task<DataCreationResultDTO> UpdateMergeTaskDetails(int childConfigurationId, string parentConfigurationIds, UserListDTO user)
        {
            using var context = _unitOfWork.Create;

            var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", childConfigurationId);
            if (definition == null)
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Invalid configuration"
                };
            }

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "UI Merge Configuration");
            if (taskType == null)
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Unable to determine Task type"
                };
            }

            string connectionString = _configuration.AzureWebJobsStorage;

            BuildQueueItem item = new BuildQueueItem
            {
                Debug = false,
                Config = new BuildTask()
            };
            item.Config.ID = Guid.NewGuid();
            item.Config.ConfigurationID = childConfigurationId;
            item.Config.ConfigurationDefinitionID = definition.ConfigurationDefinitionId;
            item.Config.TaskTypeID = taskType.ID;
            item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
            item.Config.DateStarted = DateTime.Now;
            item.Config.DateLastUpdated = DateTime.Now;
            item.Config.PercentageComplete = 0f;
            item.Config.StartedByUserID = user.Id;
            item.Config.TaskDataJSON = parentConfigurationIds;
            item.Config.DetailedStatus = "Not Started";

            var result = await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);

            // build the queue message and uploaded it to azure for the webjobs to see
            string queueName = _configuration.AzureWebJobsQueue;
            string message = JsonConvert.SerializeObject(item);
            var bytes = Encoding.ASCII.GetBytes(message);
            var base64 = System.Convert.ToBase64String(bytes);
            await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);

            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO
                {
                    IsError = false,
                    Message = "Data updated successfully",
                    Id = item.Config.ID
                };
            }
            else
            {
                return new DataCreationResultDTO
                {
                    IsError = true,
                    Message = "Data updation failed",
                    Id = item.Config.ID
                };
            }
        }

        public async Task<List<MergeTaskInfo>> GetMergeConfigurationTaskData(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.MergeConfigurationRepository.GetMergeConfigurationTaskData(configurationId);
        }
		
		public async Task<List<MergeConflictData>> GetMergeConflictData(int configurationId, Guid taskId, UserListDTO user)
        {
            using var context = _unitOfWork.Create;
            List<MergeConflictDetails> conflictDetails = await context.Repositories.MergeConfigurationRepository.GetMergeConflictData(taskId);
            List<MergeConflictData> conflictDatas = new List<MergeConflictData>();
            //Group By ContentType like Country, PlaceName, Region
            var groupedByContentType = conflictDetails.GroupBy(x => x.ContentType);
            foreach(var groupedConflicts in groupedByContentType)
            {
                MergeConflictData conflictData = new MergeConflictData();
                conflictData.ConflictSection = groupedConflicts.Key;
                //Group By individual Content based on CountryID, GeoRefID, RegionID
                var groupedByContent = groupedConflicts.GroupBy(x => new { x.ContentID, x.Description });
                foreach (var conflictItem in groupedByContent)
                {
                    MergeConflictItem conflict = new MergeConflictItem();
                    conflict.ItemId = conflictItem.Key.ContentID;
                    conflict.Description = conflictItem.Key.Description;
                    Dictionary<string, string> collinsBuild = new Dictionary<string, string>();
                    Dictionary<string, string> childBuild = new Dictionary<string, string>();
                    Dictionary<string, string> selectedBuild = new Dictionary<string, string>();
                    List<int> conflictIds = new List<int>();
                    foreach (var item in conflictItem)
                    {
                        conflictIds.Add(item.ID);
                        collinsBuild[item.DisplayName] = item.ParentValue;
                        childBuild[item.DisplayName] = item.ChildValue;
                        if (item.SelectedValue != null)
                        {
                            selectedBuild[item.DisplayName] = item.SelectedValue;
                        }
                    }
                    conflict.ConflictIds = conflictIds;
                    conflict.CollinsBuild = collinsBuild;
                    conflict.ChildBuild = childBuild;
                    if (selectedBuild.Count > 0)
                    {
                        if (DictionaryHelper.AreDictionariesEqual(collinsBuild, selectedBuild))
                            conflict.SelectedBuild = MergeBuildType.CollinsBuild;
                        else if (DictionaryHelper.AreDictionariesEqual(childBuild, selectedBuild))
                            conflict.SelectedBuild = MergeBuildType.ChildBuild;
                    }
                    if (conflictData.ConflictItems == null)
                    {
                        conflictData.ConflictItems = new List<MergeConflictItem>();
                    }
                    conflictData.ConflictItems.Add(conflict);
                }
                conflictDatas.Add(conflictData);
            }
            return conflictDatas;
        }

        public async Task<DataCreationResultDTO> UpdateMergeConflictSelection(int configurationId, Guid taskId, string conflictIds, MergeBuildType buildSelection, UserListDTO user)
        {
            //call SP to update the mergedetails table selection
            //if buildType is Collins -> update parentKey as selectedkey for all conflictIds
            //else if buildType is Yours -> update chiuldKey as selectedkey for all conflictIds
            string collinsContentIds = "";
            string childContentIds = "";
            int mergeStatus = (int)MergeChoice.Conflicted;
            if (buildSelection == MergeBuildType.CollinsBuild)
            {
                collinsContentIds = conflictIds;
                mergeStatus = (int)MergeChoice.SelectedParent;
            }
            else if (buildSelection == MergeBuildType.ChildBuild)
            {
                childContentIds = conflictIds;
                mergeStatus = (int)MergeChoice.SelectedChild;
            }
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.MergeConfigurationRepository.UpdateMergeConflictSelection(taskId, collinsContentIds, childContentIds, mergeStatus);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Merge Conflict Selection Updated!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Updating the Merge Conflict Selection" };
        }

        public async Task<DataCreationResultDTO> ResolveConflicts(int configurationId, Guid taskId, List<MergeConflictData> mergData, UserListDTO user)
        {           
            using var context = _unitOfWork.Create;           
            List<int> collinsSelections = new List<int>();
            List<int> childSelections = new List<int>();
            if(mergData != null && mergData.Count > 0)
            {
                foreach(MergeConflictData conflictData in mergData)
                {
                    if(conflictData.ConflictItems.Count > 0)
                    {
                        foreach(MergeConflictItem item in conflictData.ConflictItems)
                        {
                            if(item.SelectedBuild == MergeBuildType.CollinsBuild)
                            {
                                collinsSelections.AddRange(item.ConflictIds);
                            }
                            else if(item.SelectedBuild == MergeBuildType.ChildBuild)
                            {
                                childSelections.AddRange(item.ConflictIds);
                            }
                        }
                    }
                }
            }
            string collinsContentIds = "";
            collinsContentIds = string.Join(",", collinsSelections.Select(n => n.ToString()).ToArray());
            string childContentIds = "";
            childContentIds = string.Join(",", childSelections.Select(n => n.ToString()).ToArray());
            //call SP to update the mergedetails table with selections
            var result = await context.Repositories.MergeConfigurationRepository.UpdateMergeConflictSelection(taskId, collinsContentIds, childContentIds, (int)MergeChoice.Resolved);
            if (result > 0)
            {
                await context.SaveChanges();
                //Create Task to Perform final merge(update mapping tables based on the tblMergeDetails selectedkey field)
                using var taskContext = _unitOfWork.Create;
                var definition = await taskContext.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                if (definition == null)
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Invalid configuration" };
                }

                var taskType = await taskContext.Repositories.Simple<TaskType>().FirstAsync("Name", "PerformDataMerge");
                if (taskType == null)
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Unable to determine Task type" };
                }

                string connectionString = _configuration.AzureWebJobsStorage;

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
                item.Config.StartedByUserID = user.Id;
                item.Config.TaskDataJSON = taskId.ToString();

                result = await taskContext.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
                if (result > 0)
                {
                    await taskContext.SaveChanges();
                    // build the queue message and uploaded it to azure for the webjobs to see

                    var taskInfo = await taskContext.Repositories.Simple<BuildTask>().FirstAsync("ID", taskId);
                    taskInfo.TaskStatusID= (int)DataLayer.Models.Task.TaskStatus.Succeeded;
                    await taskContext.Repositories.Simple<BuildTask>().UpdateAsync(taskInfo);

                    string queueName = _configuration.AzureWebJobsQueue;
                    string message = JsonConvert.SerializeObject(item);
                    var bytes = Encoding.ASCII.GetBytes(message);
                    var base64 = System.Convert.ToBase64String(bytes);
                    await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);




                    return new DataCreationResultDTO { IsError = false, Message = "Merge task is created for " + configurationId };
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Merge task creation failed" };
                }
            }
            return new DataCreationResultDTO { IsError = true, Message = "Resolving Conflicts failed" };
        }
    }
}
