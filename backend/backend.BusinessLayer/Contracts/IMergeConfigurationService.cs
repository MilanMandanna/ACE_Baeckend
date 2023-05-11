using backend.DataLayer.Models.MergeConfiguration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IMergeConfigurationService
    {
        Task<MergeConfigurationAvailable> CheckUpdatesAvailable(int definitionId, int configurationId);
        Task<List<MergeConfigurationUpdateDetails>> GetMergeConfigurationUpdateDetails(int configurationDefinitionID);
        Task<DataCreationResultDTO> UpdateMergeTaskDetails(int childConfigurationId, string parentConfigurationIds, UserListDTO user);
        Task<ActionResult> DownloadVersionUpdatesReport(int configurationId, List<string> configurationIds);
        Task<List<MergeTaskInfo>> GetMergeConfigurationTaskData(int configurationId);
		Task<List<MergeConflictData>> GetMergeConflictData(int configurationId, Guid taskId, UserListDTO user);
        Task<DataCreationResultDTO> UpdateMergeConflictSelection(int configurationId, Guid taskId, string conflictIds, MergeBuildType buildSelection, UserListDTO user);
        Task<DataCreationResultDTO> ResolveConflicts(int configurationId, Guid taskId, List<MergeConflictData> mergData, UserListDTO user);
    }
}