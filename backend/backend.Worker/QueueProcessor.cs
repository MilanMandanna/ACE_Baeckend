using AutoMapper;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Task;
using backend.Helpers.Azure;
using backend.worker;
using backend.Worker.Data;
using backend.Worker.Services;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace backend.Worker.Tasks
{
    public class QueueProcessor
    {
        /**
         * Helper routine that returns the task type name given the id
         **/
        private static async Task<string> getTaskType(TaskEnvironment environment, Guid taskTypeId)
        {
            using var context = environment.NewUnitOfWork().Create;
            var type = await context.Repositories.Simple<TaskType>().FirstAsync("ID", taskTypeId);
            if (type == null) return null;
            return type.Name;
        }

        /**
        * Helper routine that returns if the task is with given the id
        **/
        private static async Task<bool> isCancelledTask(TaskEnvironment environment, Guid taskId)
        {
            using var context = environment.NewUnitOfWork().Create;
            var task = await context.Repositories.Simple<BuildTask>().FirstAsync("ID", taskId);
            if (task == null) return false;
            return task.Cancelled;
        }

        /**
         * Main processing routine that processes messages received in the Azure storage queue named "queue". As messages are received
         * it configures an execution environment for the task and calls the appropriate task handler. After the task handler
         * completes any outputs and logs are zipped up and uploaded to the configured azure blob storage container.
         * 
         * If an exception occurs in the task processing routine, then the output directory will not be uploaded, but the logs
         * will still be uploaded for processing.
         **/
        [Singleton]
        public async static System.Threading.Tasks.Task DoExport([QueueTrigger("%WebjobQueueName%")] BuildQueueItem task, ILogger logger)
        {
            // to Trigger uploading mechanism to Blob storage based on the type of Taks
            bool uploadOutput = true;

            // to Trigger Downloading mechanism from Blob storage based on the type of Taks
            bool downloadInput = true;
            // get a temp storage path for whatever we are about todo
            string tempStorage = Program.Configuration.GetValue<string>("LocalTempStorageRoot", null);
            if (tempStorage == null)
            {
                logger.LogError("local temp storage path undefined, skipping build");
                return;
            }
            tempStorage = System.IO.Path.Join(tempStorage, System.IO.Path.GetRandomFileName());
            System.IO.Directory.CreateDirectory(tempStorage);

            var loggingService = new LoggingService();
            loggingService.setLogDirectory(System.IO.Path.Join(tempStorage, "logs"));

            var mapperConfig = new MapperConfiguration(cfg =>
            {
                cfg.AddProfile(new Mappers.Maps());
            });

            var environment = new TaskEnvironment(Program.Configuration);
            environment.Mapper = new AutoMapper.Mapper(mapperConfig);
            environment.TempStoragePath = tempStorage;
            environment.TaskId = task.Config.ID;
            environment.CurrentTask = task.Config;
            environment.Logger = loggingService.logger;

            string name = await getTaskType(environment, task.Config.TaskTypeID);
            await environment.UpdateDetailedStatus("Task Type :- " + name);
            if (name == null) return;
            int retval = -1;

            bool cancelled = await isCancelledTask(environment, task.Config.ID);
            if (cancelled)
            {
                await environment.Fail("Failed due to cancellation");
                return;
            }
            ConfigureCygwin(environment);

            
          await environment.InProgress();
            await environment.UpdateDetailedStatus("Task Type :- " + name + " is started");
            try
            {
                switch (name)
                {
                    case "Export Development Config":
                        retval = await (new TaskDevelopmentExport()).Run(environment, null);
                        break;

                    case "Export Product Database - AS4XXX":
                        retval = await (new TaskExportProductDatabase()).GenerateAS4000SqlFile(environment, environment.CurrentTask.ConfigurationID);
                        break;

                    case "Import Initial Config":
                        string outputConfigPath = environment.GetTempPath(environment.CurrentTask.TaskTypeID.ToString());
                        outputConfigPath = environment.GetTempPath(environment.CurrentTask.ID.ToString());
                        string containerName = Program.Configuration.GetValue<string>("AzureImportBlobStorageContainer", null);

                        if (!task.Debug && downloadInput)
                        {
                            await DownloadFileFromCloud(environment, outputConfigPath, containerName);
                            uploadOutput = false;
                        }

                        retval = await (new TaskImportInitialConfiguration()).ImportConfigXml(environment, environment.CurrentTask.ConfigurationID, outputConfigPath);
                        break;
                    case "Export Product Database - PAC3D":
                        retval = await (new TaskExportProductDatabase()).GenerateASXI3DPACSqlFile(environment, environment.CurrentTask.ConfigurationID);
                        break;

                    case "Export Product Database - CESHTSE":
                        retval = await (new TaskExportProductDatabase()).GenerateCesHtseSqlFile(environment, environment.CurrentTask.ConfigurationID);
                        break;

                    case "Export Product Database - Thales":
                        retval = await (new TaskExportProductDatabase()).GenerateThalesSqlFile(environment, environment.CurrentTask.ConfigurationID);
                        break;
                    case "Import WGCities":
                        outputConfigPath = environment.GetTempPath(environment.CurrentTask.ID.ToString());
                        containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets", null);
                        if (!task.Debug && downloadInput)
                        {
                            await DownloadFileFromCloud(environment, outputConfigPath, containerName);
                            uploadOutput = false;
                        }
                        retval = await (new TaskCollinsAdminFeatures()).ImportWGCities(environment, environment.CurrentTask.ID, environment.CurrentTask.ConfigurationID, outputConfigPath, environment.CurrentTask.StartedByUserID);
                        break;
                    case "Import CityPopulation":
                        outputConfigPath = environment.GetTempPath(environment.CurrentTask.ID.ToString());
                        containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets", null);
                        if (!task.Debug && downloadInput)
                        {
                            await DownloadFileFromCloud(environment, outputConfigPath, containerName);
                            uploadOutput = false;
                        }
                        retval = await (new TaskCollinsAdminFeatures()).UpdateCityPopulation(environment, environment.CurrentTask.ID, environment.CurrentTask.ConfigurationID, outputConfigPath, environment.CurrentTask.StartedByUserID);
                        break;
                    case "Import NewAirportFromNavDB":
                        outputConfigPath = environment.GetTempPath(environment.CurrentTask.ID.ToString());
                        containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets", null);
                        if (!task.Debug && downloadInput)
                        {
                            await DownloadFileFromCloud(environment, outputConfigPath, containerName);
                            uploadOutput = false;
                        }
                        retval = await (new TaskCollinsAdminFeatures()).AddNewAirpots(environment, environment.CurrentTask.ID, environment.CurrentTask.ConfigurationID, outputConfigPath, environment.CurrentTask.StartedByUserID);
                        break;
                    case "MergCofiguration":
                        retval = await (new TaskCollinsAdminFeatures()).MergAndLockCofiguration(environment, environment.CurrentTask);
                        uploadOutput = false;
                        break;
                    case "Import NewPlaceNames":
                        outputConfigPath = environment.GetTempPath(environment.CurrentTask.ID.ToString());
                        containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets", null);
                        if (!task.Debug && downloadInput)
                        {
                            await DownloadFileFromCloud(environment, outputConfigPath, containerName);
                            uploadOutput = false;
                        }
                        retval = await (new TaskCollinsAdminFeatures()).AddNewPlaceNames(environment, environment.CurrentTask.ID, environment.CurrentTask.ConfigurationID, outputConfigPath, environment.CurrentTask.StartedByUserID);
                        uploadOutput = false;
                        break;

                    case "Venue Next":
                        retval = await (new TaskCollinsAdminFeatures()).BuildVenueNext(environment, environment.CurrentTask);
                        uploadOutput = true;
                        break;
                    case "Venue Hybrid":
                        retval = await (new TaskCollinsAdminFeatures()).BuildVenueHybrid(environment, environment.CurrentTask);
                        uploadOutput = true;
                        break;
                    case "Build Modlist Json":
                        retval = await (new TaskCollinsAdminFeatures()).BuildModListJSON(environment);
                        uploadOutput = false;
                        break;
                    case "PerformDataMerge":
                        retval = await (new TaskCollinsAdminFeatures()).PerformDataMerge(environment);
                        uploadOutput = false;
                        break;
                    case "UI Merge Configuration":
                        retval = await (new TaskCollinsAdminFeatures()).PopulateMergeDetails(environment);
                        uploadOutput = false;
                        break;
                    case "Save Products":
                        retval = await (new TaskCollinsAdminFeatures()).SaveProducts(environment);
                        uploadOutput = false;
                        break;
                    case "Save Product Configuration":
                        retval = await (new TaskCollinsAdminFeatures()).SaveProductConfigurationData(environment);
                        uploadOutput = false;
                        break;
                    case "Save Aircraft Configuration":
                        retval = await (new TaskCollinsAdminFeatures()).SaveAircraftConfigurationData(environment);
                        uploadOutput = false;
                        break;
						
                    case "Import Infospelling":
                        outputConfigPath = environment.GetTempPath(environment.CurrentTask.ID.ToString());
                        containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets", null);
                        if (!task.Debug && downloadInput)
                        {
                            await DownloadFileFromCloud(environment, outputConfigPath, containerName);
                            uploadOutput = false;
                        }
                        retval = await (new TaskCollinsAdminFeatures()).UpdateInfoSpelling(environment, environment.CurrentTask.ID, environment.CurrentTask.ConfigurationID, outputConfigPath, environment.CurrentTask.StartedByUserID);
                        break;

                    case "Import Fonts":
                        outputConfigPath = environment.GetTempPath(environment.CurrentTask.ID.ToString());
                        containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets", null);
                        if (!task.Debug && downloadInput)
                        {
                            await DownloadFileFromCloud(environment, outputConfigPath, containerName);
                            uploadOutput = false;
                        }
                        retval = await (new TaskCollinsAdminFeatures()).InsertUpdateFonts(environment, environment.CurrentTask.ID, environment.CurrentTask.ConfigurationID, outputConfigPath, environment.CurrentTask.StartedByUserID);
                        break;
                    case "Import Initial Config - custom.xml":
                        outputConfigPath = environment.GetTempPath(environment.CurrentTask.ID.ToString());
                        containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets", null);
                        if (!task.Debug)
                        {
                            await DownloadFileFromCloud(environment, outputConfigPath, containerName);
                            uploadOutput = false;
                        }
                        retval = await (new TaskCollinsAdminFeatures()).InsertCustomXMLData(environment, outputConfigPath);
                        break;


                    default:
                        environment.Logger.LogError("unknown task type " + name + ", skipping build");
                        return;
                }


                ///
                /// upload the output directory if we didn't have an error and there is a task defined
                /// 
                if (!task.Debug && uploadOutput)
                {
                    await UploadOutput(environment);
                }
                else
                {
                    if (uploadOutput)
                    {
                        string outputPath = environment.GetOutputPath();
                        string zipFile = environment.GetTempPath("output.zip");
                        System.IO.Compression.ZipFile.CreateFromDirectory(outputPath, zipFile);
                    }
                    environment.Logger.LogWarn("!! debug is enabled, skipping upload of output");
                }

                ///
                /// upload the logs
                ///
                if (!task.Debug)
                {
                    await UploadLogs(environment);
                }
                else
                {
                    environment.Logger.LogWarn("!! debug is enabled, skipping upload of logs");
                }

                // delete the temp storage directory
                //if (!task.Debug)
                //{
                //    environment.Logger.LogInfo("cleaning up the task temp storage: " + environment.TempStoragePath);
                //    System.IO.Directory.Delete(environment.TempStoragePath, true);
                //}
                //else
                //{
                //    environment.Logger.LogWarn("!! debug is enabled, the temp storage directory will not be deleted");
                //}

                if (retval == 0)
                {
                    bool isCancelled = await isCancelledTask(environment, task.Config.ID);
                    if (isCancelled)
                    {
                        await environment.Fail("Failed due to cancellation");
                        return;
                    }
                    await environment.Success();
                }
                else
                {
                    await environment.Fail("Failed");
                }
            }
            catch (Exception ex)
            {
                environment.Logger.LogError("export task " + name + " failed:");
                environment.Logger.LogError("exception:");
                environment.Logger.LogError("" + ex);

                await environment.Fail("Failed");
                uploadOutput = false;
            }
        }

        /**
         * Helper routine that uploads anything in the "output" directory to the configured azure blob storage container 
         **/
        private static async System.Threading.Tasks.Task UploadOutput(TaskEnvironment environment)
        {
            if (!environment.CurrentTask.ID.Equals(Guid.Empty))
            {
                string outputPath = environment.GetOutputPath();
                string zipFile = environment.GetTempPath("output.zip");
                System.IO.Compression.ZipFile.CreateFromDirectory(outputPath, zipFile);

                if (System.IO.File.Exists(zipFile))
                {
                    string connectionString = Program.Configuration.GetValue<string>("AzureBlobStorage", null);
                    string containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainer", null);

                    if (connectionString == null || containerName == null)
                    {
                        environment.Logger.LogInfo("invalid azure configuration, skipping upload");
                    }
                    else
                    {
                        string blobName = environment.CurrentTask.ID.ToString() + ".zip";
                        environment.Logger.LogInfo("uploading to " + blobName);
                        await AzureFileHelper.UploadBlob(connectionString, containerName, blobName, zipFile);
                    }
                }
                else
                {
                    environment.Logger.LogError("failed to generate zip file");
                }
            }
            else
            {
                environment.Logger.LogWarn("no task id provided, skipping upload of results");
            }
        }

        /**
         * Helper routine that uploads anything in the "logs" directory to the configured azure blob storage container 
         **/
        private static async System.Threading.Tasks.Task UploadLogs(TaskEnvironment environment)
        {
            if (!environment.CurrentTask.ID.Equals(Guid.Empty))
            {
                string logsPath = System.IO.Path.Join(environment.TempStoragePath, "logs");
                string zipFile = environment.GetTempPath("logs.zip");
                System.IO.Compression.ZipFile.CreateFromDirectory(logsPath, zipFile);

                if (System.IO.File.Exists(zipFile))
                {
                    string connectionString = Program.Configuration.GetValue<string>("AzureBlobStorage", null);
                    string containerName = Program.Configuration.GetValue<string>("AzureBlobStorageContainer", null);

                    if (connectionString == null || containerName == null)
                    {
                        environment.Logger.LogInfo("invalid azure configuration, skipping upload");
                    }
                    else
                    {
                        string blobName = environment.CurrentTask.ID.ToString() + "-logs.zip";
                        environment.Logger.LogInfo("uploading to " + blobName);
                        await AzureFileHelper.UploadBlob(connectionString, containerName, blobName, zipFile);
                    }
                }
                else
                {
                    environment.Logger.LogError("failed to generate logs zip file");
                }
            }
        }

        private static async System.Threading.Tasks.Task DownloadFileFromCloud(TaskEnvironment environment, string outputPath, string containerName)
        {
            if (!environment.CurrentTask.ID.Equals(Guid.Empty))
            {
                outputPath += ".zip";
                string connectionString = Program.Configuration.GetValue<string>("AzureBlobStorage", null);
                string blobName = environment.GetUploadedDataSourcesFromAzure(environment, environment.CurrentTask);
                //string blobName = PathWrapper($"{environment.CurrentTask.ConfigurationDefinitionID}+" //"+$"{environment.CurrentTask.ID}.zip";
                environment.Logger.LogInfo("Downloading From " + blobName);
                if (connectionString == null || containerName == null)
                {
                    environment.Logger.LogInfo("invalid azure configuration, skipping upload");
                }
                else
                {
                    await AzureFileHelper.DownloadFromBlob(connectionString, containerName, outputPath, blobName);
                    Console.WriteLine("Download completed Successfully!!!!");
                }
            }
            else
            {
                environment.Logger.LogWarn("no task id provided, skipping the Download");
            }
        }

        private static void ConfigureCygwin(TaskEnvironment environment)
        {
            environment.Logger.LogInfo("Before Cygwin Configure");
            var cygwinPath = environment.GetLocalAssetPath("bin\\cygwin");
            BuildPackageHelper helper = new BuildPackageHelper();
            if (!Directory.Exists(cygwinPath))
            {
                string cygInstallerZip = environment.GetLocalAssetPath("bin\\cygwin.zip");
                environment.Logger.LogInfo("Cygwin installer path : " + cygInstallerZip);
                string cygwinExtractPath = environment.GetLocalAssetPath("bin\\Cygwin");
                environment.Logger.LogInfo("Cygwin Extracted path : " + cygwinExtractPath);
                Directory.CreateDirectory(cygwinExtractPath);
                helper.zipFileExtractor(cygInstallerZip, cygwinExtractPath);
            }
        }
        private static void ExecuteCommand(TaskEnvironment environment, string path, string command, string cygwinPath)
        {
            try
            {
                var processInfo = new ProcessStartInfo("cmd.exe", "/c " + "cd " + path + " & " + command + "  " + cygwinPath);
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
                Thread.Sleep(120000);
                Console.WriteLine("ExitCode: {0}", process.ExitCode);
                process.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}