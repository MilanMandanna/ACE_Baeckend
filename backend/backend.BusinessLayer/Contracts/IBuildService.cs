using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Build;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Contracts
{
    public interface IBuildService
    {
        Task<string> GetErrorLog(string taskId);
        Task<DataCreationResultDTO> CancelBuild(string taskId);
        Task<DataCreationResultDTO> DeleteBuild(string taskId);
        Task<IEnumerable<BuildProgress>> BuildProgress(string[] taskIds);
        Task<BuildProgress> GetActiveImportStatus(string pageName, string configurationId);
    }
}
