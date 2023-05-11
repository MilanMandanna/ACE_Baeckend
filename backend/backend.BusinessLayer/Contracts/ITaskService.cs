using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface ITaskService
    {
        Task<backend.DataLayer.Models.Task.Task> createTask(Guid taskTypeID, Guid userID, Guid taskStatusID, float percentageComplete, string detailedStatus, int azureBuildID);
        Task<backend.DataLayer.Models.Task.Task> updateTask(Guid taskID, Guid taskStatusID, float percentageComplete, string detailedStatus);
        Task<IEnumerable<backend.DataLayer.Models.Task.Task>> getPendingTasks(string type, Guid ID);        
    }
}
