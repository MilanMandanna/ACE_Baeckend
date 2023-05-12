using AutoMapper;
using backend.DataLayer.Models.Build;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.DataLayer.UnitOfWork.SqlServer;
using backend.Logging.Contracts;
using Microsoft.Extensions.Configuration;
using System;
using System.IO;
using System.Threading.Tasks;

namespace backend.Worker.Data
{
    public class TaskEnvironment
    {
        // the temporary storage path that the application was started with
        public string TempStoragePath { get; set; }

        // the task being worked (unique id in the database)
        public Guid TaskId { get; set; }

        // application configuration information
        public IConfiguration AppConfiguration { get; }

        // mapper instance
        public IMapper Mapper { get; set; }

        // logging service
        //public LoggingService Logging { get; set; }

        // exposes the logger in the logging service in a shorter way
        //public ILogger Logger { get; set; }
        public ILoggerManager Logger { get; set; }

        // gets the current task being worked
        public BuildTask CurrentTask { get; set; }

        private BuildTask _buildTask;
        private IUnitOfWork _unitOfWork;

        public TaskEnvironment(IConfiguration configuration)
        {
            AppConfiguration = configuration;
            _unitOfWork = NewUnitOfWork();
        }

        public async Task<bool> LoadTaskInformation(Guid taskId)
        {
            var uow = NewUnitOfWork();
            var context = uow.Create;

            _buildTask = await context.Repositories.Simple<BuildTask>().FirstAsync("ID", taskId);
            return (_buildTask != null);
        }

        /**
         * creates a new unit of work based on the application configuration
         */
        public IUnitOfWork NewUnitOfWork()
        {
            return new UnitOfWorkSqlServer(AppConfiguration.GetSection("Configuration").Get<backend.Helpers.Configuration>());
        }

        /**
         * Helper function that adjusts path separators to work in a consistent manner
         */
        public string PathWrapper(string originalPath)
        {
            var value = originalPath.Replace("\\\\", "\\");
            value = value.Replace("\\", "/");
            return value;
        }

        /**
         * Gets the local asset path as configured for the application. This is a place where
         * assets that are stored with the worker can be placed
         */
        public string GetLocalAssetPath()
        {
            IConfiguration section = AppConfiguration.GetSection("Configuration");
            return PathWrapper(section.GetValue<string>("LocalAssetPath"));
        }

        /**
         * Gets the path of a file within the asset path
         */
        public string GetLocalAssetPath(string filename)
        {
            var assetPath = GetLocalAssetPath();
            return PathWrapper(Path.Join(assetPath, filename));
        }

        public string GetOutputPath()
        {
            return Path.Join(TempStoragePath, "output");
        }

        /**
         * Generates the path of a file under the output directory
         */
        public string GetOutputPath(string filename)
        {
            string outputPath = Path.Join(TempStoragePath, "output");
            if (!Directory.Exists(outputPath))
            {
                Directory.CreateDirectory(outputPath);
            }

            return PathWrapper(Path.Join(outputPath, filename));
        }

        /**
         * Helper function to copy a file, if a file in the destination exists it is deleted 
         */
        public void CopyFile(string source, string destination)
        {
            if (File.Exists(destination)) File.Delete(destination);
            File.Copy(source, destination);
        }

        /**
         * Gets the path for a file stored with a temp directory
         */
        public string GetTempPath(string filename)
        {
            string outputPath = Path.Join(TempStoragePath, "temp");
            if (!Directory.Exists(outputPath))
            {
                Directory.CreateDirectory(outputPath);
            }

            return PathWrapper(Path.Join(outputPath, filename));
        }

        /**
         * Opens a stream writer for the specified filename, clears the file if it is there
         */
        public StreamWriter OpenWriter(string filename)
        {
            return OpenWriter(filename, false);
        }

        public StreamWriter OpenWriter(string filename, System.Text.Encoding encoding)
        {
            return OpenWriter(filename, false, encoding);
        }

        /**
         * Allows opening a stream writer for a file in truncate or append
         */
        public StreamWriter OpenWriter(string filename, bool forAppend)
        {
            return OpenWriter(filename, forAppend, System.Text.Encoding.Unicode);
        }

        public StreamWriter OpenWriter(string filename, bool forAppend, System.Text.Encoding encoding)
        {
            if (!forAppend && File.Exists(filename))
            {
                File.Delete(filename);
            }


            if (forAppend)
            {
                FileStream fileStream = File.OpenWrite(filename);
                fileStream.Seek(0, SeekOrigin.End);
                return new StreamWriter(fileStream, encoding);
            }

            return new StreamWriter(File.OpenWrite(filename), encoding);
        }

        /**
         * Updates the summary status for the task in the database
         */
        public void UpdateStatus(string status)
        {
            //Logger.LogInfo(status);
            // todo: push the status to the database
        }

        /**
         * Updates the detailed status for the task in the database
         */
        public async Task UpdateDetailedStatus(string status)
        {
            Logger.LogInfo(status);

            if (CurrentTask == null || CurrentTask.ID.Equals(Guid.Empty)) return;

            using var context = _unitOfWork.Create;

            var record = await context.Repositories.Simple<BuildTask>().FirstAsync("ID", CurrentTask.ID);
            if (record != null)
            {
                record.DetailedStatus = status;
                record.DateLastUpdated = DateTime.Now;
                await context.Repositories.Simple<BuildTask>().UpdateAsync(record);
                await context.SaveChanges();
            }
            else
            {
                Logger.LogError($"failed to update detailed status {CurrentTask.ID.ToString()} to {status}");
            }
        }

        /**
         * Updates the percentage complete for the task in the database
         */
        public async Task UpdatePercentageComplete(float percent)
        {
            if (CurrentTask == null || CurrentTask.ID.Equals(Guid.Empty)) return;
            if (percent < 0f) percent = 0f;
            if (percent > 1f) percent = 1f;

            using var context = _unitOfWork.Create;
            var record = await context.Repositories.Simple<BuildTask>().FirstAsync("ID", CurrentTask.ID);
            if (record != null)
            {
                record.PercentageComplete = percent;
                record.DateLastUpdated = DateTime.Now;
                await context.Repositories.Simple<BuildTask>().UpdateAsync(record);
                await context.SaveChanges();
            }
            else
            {
                Logger.LogError($"failed to update percentage {CurrentTask.ID.ToString()} to {percent.ToString()}");
            }
        }

        /**
         * Fails the current task in the database
         */
        public async Task Fail(string status)
        {
            if (CurrentTask == null || CurrentTask.ID.Equals(Guid.Empty)) return;

            using var context = _unitOfWork.Create;
            var record = await context.Repositories.Simple<BuildTask>().FirstAsync("ID", CurrentTask.ID);
            if (record != null)
            {
                record.DetailedStatus = status;
                record.PercentageComplete = 0f;
                record.DateLastUpdated = DateTime.Now;
                record.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.Failed;
                record.ErrorLog = CurrentTask.ErrorLog;
                await context.Repositories.Simple<BuildTask>().UpdateAsync(record);
                await context.SaveChanges();
            }
            else
            {
                Logger.LogError($"failed to mark task {CurrentTask.ID.ToString()} as failed");
            }
        }

        /**
         * Flags the current task as success in the database
         */
        public async Task Success()
        {
            if (CurrentTask == null || CurrentTask.ID.Equals(Guid.Empty)) return;

            using var context = _unitOfWork.Create;
            var record = await context.Repositories.Simple<BuildTask>().FirstAsync("ID", CurrentTask.ID);
            if (record != null)
            {
                record.DetailedStatus = "Success";
                record.PercentageComplete = 100f;
                record.DateLastUpdated = DateTime.Now;
                record.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.Succeeded;
                record.ErrorLog = CurrentTask.ErrorLog;
                await context.Repositories.Simple<BuildTask>().UpdateAsync(record);
                await context.SaveChanges();
            }
            else
            {
                Logger.LogError($"failed to mark task {CurrentTask.ID.ToString()} as succeeded");
            }
        }

        /**
      * Flags the current task as In Progress in the database
      */
        public async Task InProgress()
        {
            if (CurrentTask == null || CurrentTask.ID.Equals(Guid.Empty)) return;

            using var context = _unitOfWork.Create;
            var record = await context.Repositories.Simple<BuildTask>().FirstAsync("ID", CurrentTask.ID);
            if (record != null)
            {
                record.DetailedStatus = "In Progress";
                record.PercentageComplete = 0f;
                record.DateLastUpdated = DateTime.Now;
                record.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.InProgress;
                record.ErrorLog = CurrentTask.ErrorLog;
                record.StartedByUserID = CurrentTask.StartedByUserID;
                await context.Repositories.Simple<BuildTask>().UpdateAsync(record);
                await context.SaveChanges();
            }
            else
            {
                Logger.LogError($"failed to mark task {CurrentTask.ID.ToString()} as In Progress");
            }
        }
        /**
         * Gets WebJobsQueu name
         */
        public string GetAzureWebJobsQueue()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("WebjobQueueName"));
        }
        /**
         * Gets AzureWebJobsStorage
         */
        public string GetAzureWebJobsStorage()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureWebJobsStorage"));
        }
        /**
         * Gets AzureExportBlobStorageContainer
         */
        public string GetAzureExportBlobStorageContainer()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureExportBlobStorageContainer"));
        }
        /**
         * Gets AzureBlobStorageContainerforCollinsAdminAssets
         */
        public string GetAzureBlobStorageContainerforCollinsAdminAssets()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets"));
        }
        /**
         * Gets AzureConfigurationItem value based on the input key
         */
        public string GetAzureConfigurationItem(string ConfigurationKey)
        {
            return PathWrapper(AppConfiguration.GetValue<string>(ConfigurationKey));
        }
        public string GetAzureConnectionString()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorage"));
        }
        public string GetAzureBlobStorageContainerforadminassets()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorageContainerforCollinsAdminAssets"));
        }

        public string GetAzureConnectString()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorage"));
        }
        public string GetAzureBlobStorageContainerforConfigComponents()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorageContainerforCustomContents"));
        }
        /// <summary>
        /// Returns azure blob storage
        /// </summary>
        /// <returns></returns>
        public string GetAzureBlobUrl()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobUrl"));
        }
        public string GetAzureContainerForConfigurationComponents()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorageContainerforCustomContents"));
        }

        public string GetAzureContainerforHiFocusMapInsets()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorageContainerforHiFocusMapInsets"));
        }
        /// <summary>
        /// Returns the cygwin installed directory
        /// </summary>
        /// <returns></returns>
        public string GetCygwinPath()
        {
            return PathWrapper(GetLocalAssetPath() + "\\" + AppConfiguration.GetValue<string>("CygwinPath"));
        }

        /// <summary>
        /// Returns the DataSources path from Azure 
        /// </summary>
        /// <returns></returns>
        public string GetUploadedDataSourcesFromAzure(TaskEnvironment environment, BuildTask currentTask)
        {

            string OutputConfigPath = currentTask.ConfigurationDefinitionID + "\\" + currentTask.ConfigurationID + "\\" + currentTask.ID + ".zip";
            return environment.PathWrapper(OutputConfigPath);
        }
        public string GetAzureBlobStorageContainerforCustomContents()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorageContainerforCustomContents"));
        }
        public string GetAzureBlobStorageContainerforVersionUpdates()
        {
            return PathWrapper(AppConfiguration.GetValue<string>("AzureBlobStorageContainerforVersionUpdates"));
        }
    }
}
