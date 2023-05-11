using backend.DataLayer.Repository.Contracts;
using System.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using backend.DataLayer.Models.Task;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Repository.SqlServer.Queries;
using backend.DataLayer.Helpers;

namespace backend.DataLayer.Repository.SqlServer
{
    public class TaskRepository : Repository , ITaskRepository
    {
        public TaskRepository(SqlConnection context, SqlTransaction transaction) 
        {
            _context = context;
            _transaction = transaction;
        }

        public TaskRepository()
        {
        }

        public  virtual async System.Threading.Tasks.Task<Task> createTask(Guid taskTypeID, Guid userID, Guid taskStatusID, 
                                                float percentageComplete, string detailedStatus, int azureBuildID)
        {
            var command = CreateCommand("SP_CreateTask");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@TaskTypeID", taskTypeID));
            command.Parameters.Add(new SqlParameter("@UserId", userID));
            command.Parameters.Add(new SqlParameter("@TaskStatusId", taskStatusID));
            command.Parameters.Add(new SqlParameter("@DetailedStatus", detailedStatus));
            command.Parameters.Add(new SqlParameter("@AzureBuildId", azureBuildID));          

            using var reader = await command.ExecuteReaderAsync();            
            return  ((List<Task>)await DatabaseMapper.Instance.FromReaderAsync<Task>(reader))[0];           
           
        }

        

        public virtual async System.Threading.Tasks.Task<IEnumerable<Task>> getPendingTasks(string type, Guid ID)
        {
            var command = CreateCommand("SP_GetPendingTasks");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@ID", ID));
            command.Parameters.Add(new SqlParameter("@IDType", type));            

            using var reader = await command.ExecuteReaderAsync();
            // return list of pending tasks
            return await DatabaseMapper.Instance.FromReaderAsync<Task>(reader);
        }

        public  virtual async System.Threading.Tasks.Task<Task> updateTask(Guid taskID, Guid taskStatusID, float percentageComplete, string detailedStatus)
        {
            var command = CreateCommand("SP_UpdateTask");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@TaskId", taskID));
            command.Parameters.Add(new SqlParameter("@TaskStatusId", taskStatusID));
            command.Parameters.Add(new SqlParameter("@DetailedStatus", detailedStatus));
            command.Parameters.Add(new SqlParameter("@PercentageComplete", percentageComplete));           

            using var reader = await command.ExecuteReaderAsync();
            // Updated task
            return ((List<Task>)await DatabaseMapper.Instance.FromReaderAsync<Task>(reader))[0];
        }

        public virtual async System.Threading.Tasks.Task<int> CancelBuild(Guid taskId)
        {
            var command = CreateCommand("[dbo].[SP_Build_Cancel]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@taskId", taskId);
            int result = await command.ExecuteNonQueryAsync();
            return result > 0 ? 1 : 0;
        }

        public virtual async System.Threading.Tasks.Task<int> DeleteBuild(Guid taskId)
        {
            var command = CreateCommand("[dbo].[SP_Build_Delete]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@taskId", taskId);
            int result = await command.ExecuteNonQueryAsync();
            return result > 0 ? 1 : 0;
        }

        public virtual async System.Threading.Tasks.Task<IEnumerable<BuildProgress>> GetBuildProgress(string[] taskIds)
        {
                // Convert guids to comma seperated string enclosed in single quotes
                var ids = String.Join(",", taskIds);
                var command = CreateCommand("[dbo].[SP_Build_GetProgress]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@taskIds", ids));
                using (var reader = await command.ExecuteReaderAsync())
                    return await DatabaseMapper.Instance.FromReaderAsync<BuildProgress>(reader);

        }

        public virtual async System.Threading.Tasks.Task<IEnumerable<BuildEntry>> GetBuildTasksForUser(Guid userId, bool currentBuild)
        {
            var command = CreateCommand("SP_Build_Get");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@userId", userId));

            if (currentBuild)
            {
                command.Parameters.Add(new SqlParameter("@type", "in progress"));

            }
            else
            {
                command.Parameters.Add(new SqlParameter("@type", "all"));
            }
            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<BuildEntry>(reader);
        }

        public void createTask()
        {
            throw new NotImplementedException();
        }

        public virtual async System.Threading.Tasks.Task<string> GetErrorLog(Guid taskId)
        {
            string errorLog = string.Empty;
            try
            {
                var command = CreateCommand("SP_Build_GetErrorLog");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@taskId", taskId));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    errorLog = DbHelper.StringFromDb(reader.GetString(0));
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return errorLog;

        }

        public virtual async System.Threading.Tasks.Task<BuildProgress> GetActiveImportStatus(string pageName, string configurationId)
        {
            BuildProgress buildProgress = new BuildProgress();
            try
            {
                var command = CreateCommand("[dbo].[SP_Build_GetActiveImportStatus]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@pageName", pageName));
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    buildProgress.DetailedStatus = DbHelper.StringFromDb(reader["DetailedStatus"]);
                    buildProgress.ID = DbHelper.GuidFromDb(reader["ID"]);
                    buildProgress.PercentageComplete = (double)DbHelper.DoubleFromDB(reader["PercentageComplete"]);
                    buildProgress.DateStarted = DbHelper.StringFromDb(reader["DateStarted"]);
                    buildProgress.Version = DbHelper.IntFromDb(reader["Version"]).ToString();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return buildProgress;
        }
    }
}
