using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using static backend.DataLayer.Models.Configuration.ModListJsonData;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ConfigurationRepository :
            SimpleRepository<Configuration>,
        IConfigurationRepository
    {
        public ConfigurationRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }

        public ConfigurationRepository() { }

        public virtual async Task<IEnumerable<ConfigurationFeature>> GetFeatures(int configurationId)
        {
            IEnumerable<ConfigurationFeature> features;
            var command = CreateCommand("[dbo].[SP_Feature_GetFeatures]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@featureName", "all"));
            using (var reader = await command.ExecuteReaderAsync())
            {
                features = await DatabaseMapper.Instance.FromReaderAsync<ConfigurationFeature>(reader);
            }

            return features;
        }


        public virtual async Task<ConfigurationFeature> GetFeature(int configurationId, string featurName)
        {
            IEnumerable<ConfigurationFeature> features;
            var command = CreateCommand("[dbo].[SP_Feature_GetFeatures]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@featureName", featurName));
            using (var reader = await command.ExecuteReaderAsync())
            {
                features = await DatabaseMapper.Instance.FromReaderAsync<ConfigurationFeature>(reader);
            }
            if (features.Count() > 0)
            {
                return features.First();
            }
            return null;
        }

        public virtual async Task<List<ConfigurationName>> GetDefinitionVersions(int configurationDefinitionID)
        {
            // var listConfigurationName =new List<ConfigurationName>();
            List<ConfigurationName> listConfigurationName = new List<ConfigurationName>();
            var command = CreateCommand("[dbo].[SP_Configuration_GetVersions]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@type", "all"));
            command.Parameters.AddWithValue("@configurationDefinitionID", configurationDefinitionID);
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    ConfigurationName configurationName = new ConfigurationName();

                    configurationName.ConfigurationId = DbHelper.DBValueToInt(reader["ConfigurationID"]);
                    configurationName.ConfigurationDefinitionId = DbHelper.DBValueToInt(reader["ConfigurationDefinitionID"]);
                    configurationName.Version = DbHelper.DBValueToInt(reader["Version"]);
                    configurationName.Locked = DbHelper.BoolFromDb(reader["Locked"]);
                    configurationName.Description = DbHelper.DBValueToString(reader["Description"]);
                    configurationName.LockComment = DbHelper.DBValueToString(reader["LockComment"]);
                    configurationName.LockDate = DbHelper.DateFromDb(reader["LockDate"]);
                    configurationName.ProductName = DbHelper.DBValueToString(reader["ProductName"]);
                    configurationName.PlatFormName = DbHelper.DBValueToString(reader["PlatFormName"]);
                    configurationName.TailNumber = DbHelper.DBValueToString(reader["TailNumber"]);
                    listConfigurationName.Add(configurationName);


                }
            }

            return listConfigurationName;

        }

        public virtual async Task<List<ConfigurationName>> GetLockDefinitionVersions(int configurationDefinitionID)
        {
            List<ConfigurationName> listConfigurationName = new List<ConfigurationName>();
            var command = CreateCommand("[dbo].[SP_Configuration_GetVersions]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@type", "locked"));
            command.Parameters.AddWithValue("@configurationDefinitionID", configurationDefinitionID);
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    ConfigurationName configurationName = new ConfigurationName();

                    configurationName.ConfigurationId = DbHelper.DBValueToInt(reader["ConfigurationID"]);
                    configurationName.ConfigurationDefinitionId = DbHelper.DBValueToInt(reader["ConfigurationDefinitionID"]);

                    configurationName.Version = DbHelper.DBValueToInt(reader["Version"]);
                    configurationName.Locked = DbHelper.BoolFromDb(reader["Locked"]);
                    configurationName.Description = DbHelper.DBValueToString(reader["Description"]);
                    configurationName.LockComment = DbHelper.DBValueToString(reader["LockComment"]);
                    configurationName.LockDate = DbHelper.DateFromDb(reader["LockDate"]);
                    configurationName.PlatFormName = DbHelper.DBValueToString(reader["PlatFormName"]);
                    configurationName.ProductName = DbHelper.DBValueToString(reader["ProductName"]);
                    configurationName.TailNumber = DbHelper.DBValueToString(reader["TailNumber"]);
                    listConfigurationName.Add(configurationName);


                }
            }

            return listConfigurationName;
        }

        public async Task<bool> isConfigurationExist(int configurationDefinitionID)
        {
            var command = CreateCommand("[dbo].[SP_Configuration_GetIfExist]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationDefinitionID", configurationDefinitionID);
            return await command.ExecuteScalarAsync() == null ? false : true;
        }

        public async Task<int> MaxConfigurationID()
        {
            var command = CreateCommand("[dbo].[SP_Configuration_Utility]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@type", "configuration"));
            return (int)await command.ExecuteScalarAsync();
        }

        public virtual async Task<int> CreateInsetConfigurationMapping(int configurationId)
        {
            var command = CreateCommand("[dbo].[SP_Inset_InsertInsetsIntoASXiInsetMap]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            var result = await command.ExecuteNonQueryAsync();
            return result;
        }

        #region Config definition lock and deploy
        public virtual async Task<int> UpdateConfigurationDefinitionSettings(int configurationId, List<ConfigurationSettings> configurationDefinitionSettings)
        {
            bool autoDeployValue = false;
            bool autoLockValue = false;
            bool autoMergeValue = false;

            configurationDefinitionSettings.ForEach(setting =>
            {
                if (setting.Name.ToLower() == "auto lock")
                    autoLockValue = setting.Value;
                else if (setting.Name.ToLower() == "auto deploy")
                    autoDeployValue = setting.Value;
                else if (setting.Name.ToLower() == "auto merge")
                    autoMergeValue = setting.Value;
            });
            int result;
            try
            {
                var command = CreateCommand("[dbo].[SP_Config_UpdateAutoLockorAutoDeploy]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationDefinitionId", configurationId));
                command.Parameters.Add(new SqlParameter("@autoLock", autoLockValue));
                command.Parameters.Add(new SqlParameter("@autoDeploy", autoDeployValue));
                command.Parameters.Add(new SqlParameter("@autoMerge", autoMergeValue));
                result = await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;

        }
        #endregion

        public virtual async Task<IEnumerable<string>> GetDefaultLockingComments(int configurationId)
        {
            var command = CreateCommand("[dbo].[SP_Configuration_GetDefaultLockingComments]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            var result = new List<String>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(reader.GetString(0));
                }
            }
            return result;
        }

        public async Task<int> LockCurrentConfiguration(int configurationId, string lockComments, string userId, string taskId)
        {
            var command = CreateCommand("[dbo].[SP_Configuration_LockCurrentConfiguration]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.AddWithValue("@lockMessage", lockComments);
            command.Parameters.Add(new SqlParameter("@userId", userId));
            command.Parameters.Add(new SqlParameter("@taskId", taskId));
            command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
            var result = await command.ExecuteNonQueryAsync();
            return result;
        }

        public async Task<List<int>> LockChildConfiguration(int configurationId, string lockComments, string userId, string taskId)
        {
            var childConfigIds = new List<Int32>();
            var command = CreateCommand("[dbo].[SP_Configuration_LockChildConfigurations]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@lockMessage", lockComments);
            command.Parameters.Add(new SqlParameter("@userId", userId));
            command.Parameters.Add(new SqlParameter("@taskId", taskId));
            command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var returnValue = reader.GetInt32(0);
                childConfigIds.Add(returnValue);
            }
            return childConfigIds;
        }


        public async Task<int> MergeCurrentConfiguration(int configurationId,int childConfigId, string userId, string taskId)
        {
            var command = CreateCommand("[dbo].[SP_ConfigManagement_MergeConfig]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configId", configurationId));
            command.Parameters.Add(new SqlParameter("@childConfigId", childConfigId));
            command.Parameters.Add(new SqlParameter("@userId", userId));
            command.Parameters.Add(new SqlParameter("@taskId", taskId));
            command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
            var result = await command.ExecuteNonQueryAsync();

            return result;
        }


        public async Task<int> BranchConfiguration(int configurationId, Guid currentUser)
        {
            var command = CreateCommand("[dbo].[SP_Configuration_BranchConfiguration]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@LastModifiedBy", currentUser));
            command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
            var result = await command.ExecuteNonQueryAsync();
            return result;
        }

        public virtual async Task<int> UpdateReleaseNotes(int configurationId, string version, string releaseNotes)
        {
            int result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_Configuration_UpdateReleaseNotes]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@version", version);
                command.Parameters.AddWithValue("@releaseNotes", releaseNotes);
                result = await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;

        }
        public async Task<int> UpdateCityPopulation(Guid CurrentTaskID, int configurationId, Guid CurrentUserID)
        {
            var command = CreateCommand("[dbo].[SP_CityPopulation_Import]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configid", configurationId));
            command.Parameters.Add(new SqlParameter("@LastModifiedBy", CurrentUserID));
            command.Parameters.Add(new SqlParameter("@CurrentTaskID", CurrentTaskID));
            command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
            var result = await command.ExecuteNonQueryAsync();
            return result;
        }
        public async Task<int> InsertUpdateFonts(int configurationId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_InfoImportFonts]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configid", configurationId));
                command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
                var result = await command.ExecuteNonQueryAsync();
                return result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<int> UpdateInfoSpelling( int configurationId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_InfoSpelling_Import]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configid", configurationId));
                command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
                var result = await command.ExecuteNonQueryAsync();
                return result;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

   

        public async Task<int> AddNewAirportfromNavDB(Guid CurrentTaskID, int configurationId, Guid CurrentUserID)
        {
            int result = 0;

            try
            {
                var command = CreateCommand("[dbo].[SP_NewNavDBAirports_Import]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configid", configurationId));
                command.Parameters.Add(new SqlParameter("@LastModifiedBy", CurrentUserID));
                command.Parameters.Add(new SqlParameter("@CurrentTaskID", CurrentTaskID));
                command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
                result = await command.ExecuteNonQueryAsync();

            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. Method to get the details of the admin items.
        /// 2. It will return a list of string.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<string> GetCollinsAdminItems(int configurationId)
        {
            string collinsAdminItems = string.Empty;
            try
            {
                var command = CreateCommand("[dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "adminitem"));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    collinsAdminItems = reader.GetString(0);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return collinsAdminItems;
        }

        /// <summary>
        /// 1. Get the download details of the selected page.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        public virtual async Task<List<AdminOnlyDownloadDetails>> GetDownloadDetails(int configurationId, string pageName)
        {
            List<AdminOnlyDownloadDetails> downloadDetails = new List<AdminOnlyDownloadDetails>();

            try
            {
                var command = CreateCommand("[dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "page"));
                command.Parameters.Add(new SqlParameter("@pageName", pageName));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    AdminOnlyDownloadDetails adminOnlyDownloadDetails = new AdminOnlyDownloadDetails();
                    adminOnlyDownloadDetails.Author = DbHelper.StringFromDb(reader["userName"].ToString());
                    adminOnlyDownloadDetails.Date = DbHelper.DateTimeFromDb((reader["dateUploaded"]));
                    adminOnlyDownloadDetails.Revision = DbHelper.IntFromDb(reader["revision"]).Value;
                    adminOnlyDownloadDetails.TaskId = DbHelper.StringFromDb(reader["taskId"].ToString());
                    adminOnlyDownloadDetails.ConfigurationId = DbHelper.IntFromDb(reader["configurationId"]).Value;
                    adminOnlyDownloadDetails.ConfigurationDefinitionId = DbHelper.IntFromDb(reader["ConfigurationDefinitionID"]).Value;
                    downloadDetails.Add(adminOnlyDownloadDetails);
                  
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return downloadDetails;
        }
        public async Task<int> AddNewWGCities(Guid CurrentTaskID, int configurationId, Guid CurrentUserID)
        {
            int result = 0;

            try
            {
                var command = CreateCommand("[dbo].[SP_NewWGCities_Import]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@CurrentTaskID", CurrentUserID));
                command.Parameters.Add(new SqlParameter("@configid", configurationId));
                command.Parameters.Add(new SqlParameter("@LastModifiedBy", CurrentUserID));
                command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
                result = await command.ExecuteNonQueryAsync();

            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. Method to get error logs for upload.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        public async Task<string> GetErrorLog(int configurationId, string pageName)
        {
            string errorLog = string.Empty;

            try
            {
                var command = CreateCommand("[dbo].[SP_GetFileUploadErrorLogs]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@pageName", pageName));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    errorLog = DbHelper.StringFromDb(reader["errorlog"]);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return errorLog;
        }

        public async Task<Configuration> GetConfiguration(int configurationId)
        {
            try
            {
                var command = CreateCommand("select * from dbo.tblconfigurations where configurationid = @configurationId");
                command.Parameters.AddWithValue("@configurationId", configurationId);
                
                using (var reader = await command.ExecuteReaderAsync())
                {
                    return (await DatabaseMapper.Instance.FromReaderAsync<Configuration>(reader)).FirstOrDefault();
                }

            } catch (Exception ex) { throw ex; }
        }		

        /// <summary>
        /// 1. Method to update file URL or upload errors to database.
        /// </summary>
        /// <param name="url"></param>
        /// <param name="configurationId"></param>
        /// <param name="fileName"></param>
        /// <param name="userId"></param>
        /// <param name="pageName"></param>
        /// <param name="errorMessage"></param>
        /// <returns></returns>
        public async Task<int> UpdateFilePath(string url, int configurationId, string fileName, Guid userId, string pageName, string errorMessage)
        {
            int result;
            try
            {
                var command = CreateCommand("[dbo].[SP_UpdateFileUploadDetails]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@url", url));
                command.Parameters.Add(new SqlParameter("@fileName", fileName));
                command.Parameters.Add(new SqlParameter("@userId", userId.ToString()));
                command.Parameters.Add(new SqlParameter("@pageName", pageName));
                command.Parameters.Add(new SqlParameter("@errorMessage", errorMessage));
                result = await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        public async Task<string> GetDownloadURL(int configurationId, string taskId)
        {
            string downloadURL = string.Empty;
            try
            {
                var command = CreateCommand("[dbo].[SP_GetDownloadURL]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@taskId", taskId));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    downloadURL = DbHelper.StringFromDb(reader.GetString(0));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return downloadURL;
        }

        public async Task<int> AddNewPlaceNames(Guid CurrentTaskID, int configurationId, Guid CurrentUserID, bool isUSPlacenamesSource)
        {
            int result = 0;

            try
            {
                var command = CreateCommand("[dbo].[SP_NewPlaceNames_Import]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configid", configurationId));
                command.Parameters.Add(new SqlParameter("@LastModifiedBy", CurrentUserID));
                command.Parameters.Add(new SqlParameter("@CurrentTaskID", CurrentTaskID));
                command.Parameters.Add(new SqlParameter("@isUSPlacename", isUSPlacenamesSource));
                command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
                result = await command.ExecuteNonQueryAsync();

            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. Method to get fileID from database
        /// 2. Based on taskId and configurationId fileId will be picked from tasks table
        /// 3. This method is used for Airports, populations and World Guide cities import
        /// </summary>
        /// <param name="taskId"></param>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<Guid> GetTaskIDDetails(Guid taskId, int configurationId)
        {
            Guid fileId = Guid.Empty;
            try
            {
                var command = CreateCommand("[dbo].[SP_GetFileIDFromTaskID]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@taskId", taskId));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    fileId = DbHelper.GuidFromDb(reader.GetGuid(0));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return fileId;
        }

        public async Task<List<int>> GetChildConfigIds(int configurationId)
        {
            List<int> lstConfigId = new List<int>();
            try
            {
                var command = CreateCommand("[dbo].[SP_Configuration_GetAllChlildConfigs]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configId", configurationId));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    lstConfigId.Add(DbHelper.DBValueToInt(reader[0]));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return lstConfigId;
        }

        public async Task<List<BuildQueue>> GetConfigurationsToBeLocked(Guid taskTypeId, int time)
        {
            var result = new List<BuildQueue>();

            try
            {
                var command = CreateCommand("[dbo].[SP_getConfigIdsToBeLocked]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@timeInterval", time));
                command.Parameters.Add(new SqlParameter("@taskTypeId", taskTypeId));
                using var reader = await command.ExecuteReaderAsync();
                BuildQueue buildQueue;
                while (await reader.ReadAsync())
                {
                    buildQueue = new BuildQueue();
                    buildQueue.ConfigurationDefinitionID = DbHelper.DBValueToInt(reader["ConfigurationDefinitionID"]);
                    buildQueue.ConfigurationId = DbHelper.DBValueToInt(reader["ConfigurationID"]);
                    buildQueue.LockComments = DbHelper.DBValueToString(reader["TaskDataJSON"]);
                    buildQueue.StartedByUserId = DbHelper.GuidFromDb(reader["StartedByUserID"]);
                    buildQueue.TaskId = DbHelper.GuidFromDb(reader["ID"]);
                    result.Add(buildQueue);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public async Task<int> UpdateTaskStatus(BuildTask buildTask)
        {
            var result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_updateTaskStatus]", CommandType.StoredProcedure);
                command.Parameters.Add(new SqlParameter("@taskId", buildTask.ID));
                command.Parameters.Add(new SqlParameter("@percentage", buildTask.PercentageComplete));
                command.Parameters.Add(new SqlParameter("@taskStatus", buildTask.TaskStatusID));
                result= await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        public async Task<int> UpdateConfigModifiedDateTime(int configurationId)
        {
            var result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_ConfigManagement_SetLastUpdateDateTime]", CommandType.StoredProcedure);
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                result = await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        public async Task<int> ImportAsxiInfo(int configurationId)
        {
            var result = 0;
            try
            {
            var command = CreateCommand("[dbo].[SP_AsxiInfoImport]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configid", configurationId));
            command.CommandTimeout = 0;//A value of 0 indicates no limit (an attempt to execute a command will wait indefinitely).
                result = await command.ExecuteNonQueryAsync();
            }            
            catch (Exception ex)
            {
                Console.WriteLine("Exception ex!"+ex.ToString());
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// Method to get data from Modlist table
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="isDirty"></param>
        /// <returns></returns>
        public async Task<List<ModListData>> GetModlistData(int configurationId, bool isDirty)
        {
            try
            {
                List<ModListData> listModListData = new List<ModListData>();
                var command = CreateCommand("[dbo].[SP_GetModlistData]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@isDirty", Convert.ToByte(isDirty)));
                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        ModListData modListData = new ModListData();
                        modListData.ModlistID = (int)DbHelper.IntFromDb(reader["ModlistID"]);
                        modListData.FileJSON = DbHelper.StringFromDb(reader["FileJSON"]);
                        modListData.Row = (double)DbHelper.IntFromDb(reader["Row"]);
                        modListData.Col = (double)DbHelper.IntFromDb(reader["Col"]);
                        modListData.Resolution = (int)DbHelper.IntFromDb(reader["Resolution"]);
                        modListData.isDirty = DbHelper.BoolFromDb(reader["isDirty"]);
                        listModListData.Add(modListData);
                    }
                }
                return listModListData;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Method to get data to prepare JSON files for Modlist table
        /// </summary>
        /// <param name="listGeoRefId"></param>
        /// <param name="configurationId"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public async Task<List<ModListJSON>> GetDataForModListJson(string listGeoRefId, int configurationId, string type)
        {
            try
            {
                List<ModListJSON> listModlistJson = new List<ModListJSON>();
                var command = CreateCommand("[dbo].[SP_GetDataForModListJson]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@geoRefId", listGeoRefId));
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", type));
                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        ModListJSON modlist = new ModListJSON();
                        modlist.Id = (int)DbHelper.IntFromDb(reader["GeoRefId"]);
                        modlist.Lat = DbHelper.FloatFromDB(reader["Lat1"]);
                        modlist.Lon = DbHelper.FloatFromDB(reader["Lon1"]);
                        modlist.Pri = (int)DbHelper.IntFromDb(reader["AsxiPriority"]);
                        modlist.IPOI = (int)DbHelper.IntFromDb(reader["isInteractivePoi"]);
                        modlist.Cat = (int)DbHelper.IntFromDb(reader["AsxiCatTypeId"]);
                        modlist.Name = DbHelper.StringFromDb(reader["Description"]);
                        listModlistJson.Add(modlist);
                    }
                }
                return listModlistJson;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Method to get landsat value for the diven configuration ID
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<string> GetLandSatValue(int configurationId)
        {
            try
            {
                string landSat = string.Empty;
                var command = CreateCommand("[dbo].[sp_GetLandSatValue]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        landSat = DbHelper.StringFromDb(reader["LandSat"]);
                    }
                }
                return landSat;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Method to update all the JSON data to the modlist table
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="modListDataTable"></param>
        /// <returns></returns>
        public int UpdateModListData(int configurationId, DataTable modListDataTable)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_UpdateModlistData]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add("@modlistData", SqlDbType.Structured).Value = modListDataTable;
                return command.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<DataSet> GetVersionUpdates(int configurationId)
        {
            DataSet ds = new DataSet();
            try
            {
                var command = CreateCommand("[dbo].[SP_GetVersionUpdates]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.CommandTimeout = 0;
                SqlDataAdapter adapter = new SqlDataAdapter(command);
                adapter.Fill(ds);
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return ds;
        }


        public Task<int> BranchConfigFromParent(int childConfigDefId, int parentConfigId,Guid userId,string description)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_CreateBranch]");
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 0;
                command.Parameters.Add(new SqlParameter("@FromConfigurationID", parentConfigId));
                command.Parameters.Add(new SqlParameter("@IntoConfigurationDefinitionID", childConfigDefId));
                command.Parameters.Add(new SqlParameter("@LastModifiedBy", userId.ToString()));
                command.Parameters.Add(new SqlParameter("@Description", description));
                return command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public Task<int> UpdatePartNumberFromTemp (Guid aircraftId)
        {
            try
            {
                var command = CreateCommand("[dbo].[sp_update_partnumer_from_temp]");
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 0;
                command.Parameters.Add(new SqlParameter("@aircraftId", aircraftId.ToString()));
                return command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<List<ScriptForcedLanguage>> GetLanguageCode(List<String> Items)
        {
         
            try
            {
                string combindedString = string.Join(",", Items.ToArray());
                var commandSelect = CreateCommand("[dbo].[SP_Language_GetTwoLetterCode]");
                commandSelect.CommandType = CommandType.StoredProcedure;
                commandSelect.Parameters.AddWithValue("@combindedString", combindedString.ToLower());
                Dictionary<string, string> lstLangs = new Dictionary<string, string>();
                List<ScriptForcedLanguage> scriptForcedLanguages = new List<ScriptForcedLanguage>();
                ScriptForcedLanguage forcedLanguage = null;
                using (var reader = await commandSelect.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        forcedLanguage = new ScriptForcedLanguage();
                        forcedLanguage.LanguageName = DbHelper.StringFromDb(reader["LanguageName"]);
                        forcedLanguage.LanguageCode = DbHelper.StringFromDb(reader["TwoletterID"]);
                        scriptForcedLanguages.Add(forcedLanguage);
                    }
                }
                return scriptForcedLanguages;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            
        }
    }
}