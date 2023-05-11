using backend.DataLayer.Models.MergeConfiguration;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IMergeConfigurationRepository
    {
        Task<List<MergeConfigurationUpdateDetails>> GetMergeConfigurationUpdateDetails(int configurationDefinitionID);
        Task<MergeConfigurationAvailable> CheckUpdatesAvailable(int configurationDefinitionId, int configurationId);

        Task<int> PopulateMergeDetails(int configurationId, int parentConfigurationId, string taskId);
        Task<List<MergeTaskInfo>> GetMergeConfigurationTaskData(int configurationId);
		Task<List<MergeConflictDetails>> GetMergeConflictData(Guid taskId);
        Task<int> UpdateMergeConflictSelection(Guid taskId, string collinsContentIds, string childContentIds, int mergeChoice);

        Task<int> PerformMergeChoiceMoveToMapTable(int configurationId, string taskId);

        Task<int> SetConfigUpdatedVersion(int parentConfigId, int ChildConfigDefId);
        Task<int> GetMergeConflictCount(string taskId);
    }
}
