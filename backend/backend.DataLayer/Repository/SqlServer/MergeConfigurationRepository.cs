using backend.DataLayer.Helpers;
using backend.DataLayer.Models.MergeConfiguration;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Linq;

namespace backend.DataLayer.Repository.SqlServer
{
    public class MergeConfigurationRepository: SimpleRepository<Configuration>, IMergeConfigurationRepository
    {
        public MergeConfigurationRepository()
        { }

        public MergeConfigurationRepository(SqlConnection context, SqlTransaction transaction) :
           base(context, transaction)
        { }

        /// <summary>
        /// Method to get all the versions which are available for update.
        /// </summary>
        /// <param name="configurationDefinitionID"></param>
        /// <returns></returns>
        public async Task<List<MergeConfigurationUpdateDetails>> GetMergeConfigurationUpdateDetails(int configurationDefinitionID)
        {
            List<MergeConfigurationUpdateDetails> mergeConfigurationUpdateDetails = new List<MergeConfigurationUpdateDetails>();
            try
            {
                var command = CreateCommand("[dbo].[SP_MergeConfig_GetUpdatesDetails]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationDefinitionID", configurationDefinitionID));

                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        MergeConfigurationUpdateDetails updateDetails = new MergeConfigurationUpdateDetails();

                        updateDetails.ConfigurationId = DbHelper.DBValueToInt(reader["configurationId"]);
                        updateDetails.ReleaseNotes = DbHelper.StringFromDb(reader["LockComment"]);
                        updateDetails.VersionDate = DbHelper.DateFromDb(reader["LockDate"]).DateTime.ToString("MM/dd/yyyy");
                        updateDetails.VersionNumber = DbHelper.DBValueToInt(reader["Version"]);
                        mergeConfigurationUpdateDetails.Add(updateDetails);
                    }
                }
                return mergeConfigurationUpdateDetails;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<MergeConfigurationAvailable> CheckUpdatesAvailable(int configurationDefinitionID, int configurationId)
        {
            try
            {
                MergeConfigurationAvailable updatesAvailable = new MergeConfigurationAvailable();
                var command = CreateCommand("[dbo].[SP_GetUpdatesAvailable]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationDefinitionID", configurationDefinitionID);
                command.Parameters.AddWithValue("@configurationId", configurationId);
                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (reader.HasRows)
                    {
                        while (await reader.ReadAsync())
                        {

                            updatesAvailable.IsUpdatesAvailable = DbHelper.BoolFromDb(reader["updatesavailable"]);
                            updatesAvailable.UpdateType = DbHelper.StringFromDb(reader["updateType"]);

                        }
                    }
                }
                return updatesAvailable;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Method to populate merge details table based on parent config id and 
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="parentConfigurationId"></param>
        /// <param name="taskId"></param>
        /// <returns></returns>
        public async Task<int> PopulateMergeDetails(int configurationId, int parentConfigurationId, string taskId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_MergeConfiguration_PopulateMergeDetails]");
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 0;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@parentConfigurationId", parentConfigurationId);
                command.Parameters.AddWithValue("@taskId", taskId);
                return await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public  virtual async Task<List<MergeTaskInfo>> GetMergeConfigurationTaskData(int configurationId)
        {
            try
            {
                List<MergeTaskInfo> mergeTasks = new List<MergeTaskInfo>();
                var command = CreateCommand("[dbo].[SP_GetMergeConfigurationTaskData]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (reader.HasRows)
                    {
                        MergeTaskInfo mergeTaskInfo;
                        while (await reader.ReadAsync())
                        {
                            mergeTaskInfo = new MergeTaskInfo();
                            mergeTaskInfo.TaskId = DbHelper.GuidFromDb(reader["ID"]);
                            mergeTaskInfo.TasKName = DbHelper.StringFromDb(reader["Name"]).ToString();
                            mergeTaskInfo.TaskStatus = DbHelper.DBValueToInt(reader["TaskStatusID"]);
                            var merge = mergeTasks.Where(x => x.TasKName == mergeTaskInfo.TasKName).ToList();
                            if (merge.Count == 0)
                            {
                                mergeTasks.Add(mergeTaskInfo);
                            }
                        }
                    }
                }
                return mergeTasks;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
		
		public async Task<List<MergeConflictDetails>> GetMergeConflictData(Guid taskId)
        {
            List<MergeConflictDetails> conflictDetails = new List<MergeConflictDetails>();
            try
            {
                var command = CreateCommand("[dbo].[SP_MergeConflicts_GetConflictData]");
                //var command = CreateCommand("[dbo].[SP_getCountryConflicts]"); 
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 0;
                command.Parameters.Add(new SqlParameter("@taskID", taskId));

                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        MergeConflictDetails details = new MergeConflictDetails();
                        details.ID = DbHelper.DBValueToInt(reader["ID"]);
                        details.ContentID = DbHelper.DBValueToInt(reader["ContentID"]);
                        details.ContentType = DbHelper.StringFromDb(reader["ContentType"]);
                        details.Description = DbHelper.StringFromDb(reader["Description"]);
                        details.DisplayName = DbHelper.StringFromDb(reader["DisplayName"]);
                        details.ParentValue = DbHelper.StringFromDb(reader["ParentValue"]);
                        details.ChildValue = DbHelper.StringFromDb(reader["ChildValue"]);
                        details.SelectedValue = DbHelper.StringFromDb(reader["SelectedValue"]);
                        conflictDetails.Add(details);
                    }
                }
                return conflictDetails;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<int> UpdateMergeConflictSelection(Guid taskId, string collinsContentIds, string childContentIds, int mergeChoice)
        {
            int result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_MergeConflicts_UpdateSelection]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@taskId", taskId);
                if (collinsContentIds != "")
                    command.Parameters.AddWithValue("@collinsContentIds", collinsContentIds);
                if (childContentIds != "")
                    command.Parameters.AddWithValue("@childContentIds", childContentIds);
                command.Parameters.AddWithValue("@status", mergeChoice);
                result = await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public async Task<int> PerformMergeChoiceMoveToMapTable(int configurationId, string taskId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_MergeConflict_MoveDataToMapTable]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@taskId", taskId));
                return await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<int> SetConfigUpdatedVersion(int parentConfigId, int ChildConfigDefId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_MergeConflict_SetConfigUpdatedVersion]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@parentConfigId", parentConfigId));
                command.Parameters.Add(new SqlParameter("@childConfigDefId", ChildConfigDefId));
                return await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<int> GetMergeConflictCount(string taskId)
        {
            var result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_MergeConfiguration_MergeConflictCount]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@taskId", taskId);
                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    if (reader.Read())
                    {
                        result = DbHelper.DBValueToInt(reader["count"]);
                    }
                }
                return result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
