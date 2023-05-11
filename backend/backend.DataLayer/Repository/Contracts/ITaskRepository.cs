using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using backend.DataLayer.Models.Build;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ITaskRepository
    {
        Task<Models.Task.Task> createTask(Guid taskTypeID, Guid userID, Guid taskStatusID, float percentageComplete, string detailedStatus, int azureBuildID);
        Task<Models.Task.Task> updateTask(Guid taskID, Guid taskStatusID, float percentageComplete, string detailedStatus);
        Task<IEnumerable<Models.Task.Task>> getPendingTasks(string type, Guid iD);
        Task<IEnumerable<Models.Build.BuildEntry>> GetBuildTasksForUser(Guid userId, bool currentBuild);
        Task<string> GetErrorLog(Guid taskId);
        Task<int> CancelBuild(Guid taskId);
        Task<int> DeleteBuild(Guid taskId);
        Task<IEnumerable<BuildProgress>> GetBuildProgress(string[] taskIds);
        Task<BuildProgress> GetActiveImportStatus(string pageName, string configurationId);

    }
}
