using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using static backend.DataLayer.Models.Configuration.ModListJsonData;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IConfigurationRepository :
        IInsertAsync<Configuration>,
        IUpdateAsync<Configuration>,
        IDeleteAsync<Configuration>,
        IFilterAsync<Configuration>
    {
        Task<List<ConfigurationName>> GetDefinitionVersions(int definitionId);
        Task<List<ConfigurationName>> GetLockDefinitionVersions(int definitionId);
        Task<int> MaxConfigurationID();
        Task<bool> isConfigurationExist(int configurationDefinitionId);
        Task<IEnumerable<ConfigurationFeature>> GetFeatures(int configurationId);
        Task<ConfigurationFeature> GetFeature(int configurationId,string featurName);
        Task<int> CreateInsetConfigurationMapping(int configurationId);
        Task<IEnumerable<string>> GetDefaultLockingComments(int configurationId);
        Task<int> LockCurrentConfiguration(int configurationId, string lockComments, string userId, string taskId);
        Task<int> MergeCurrentConfiguration(int configurationId,int childConfigId, string userId, string taskId);
        Task<int> BranchConfiguration(int configurationId, Guid currentUser);
        Task<List<int>> LockChildConfiguration(int configurationId, string lockComments, string userId, string taskId);
        Task<int> UpdateReleaseNotes(int configurationId, string version, string releaseNotes);
        #region Config definition lock and deploy
        Task<int> UpdateConfigurationDefinitionSettings(int configurationId, List<ConfigurationSettings> configurationDefinitionSettings);
        #endregion
        Task<int> UpdateCityPopulation(Guid CurrentTaskID, int configurationId, Guid CurrentUserI);
        Task<int> AddNewAirportfromNavDB(Guid CurrentTaskID,int configurationId, Guid CurrentUserID);
        Task<int> AddNewWGCities(Guid CurrentTaskID,int configurationId,Guid CurrentUserID);
        Task<string> GetCollinsAdminItems(int configurationId);
        Task<List<AdminOnlyDownloadDetails>> GetDownloadDetails(int configurationId, string pageName);
        Task<string> GetErrorLog(int configurationId, string pageName);
        Task<int> UpdateFilePath(string url, int configurationId, string fileName, Guid userId, string pageName, string errorMessage);
        Task<string> GetDownloadURL(int configurationId, string taskId);
        Task<int> AddNewPlaceNames(Guid CurrentTaskID, int configurationId, Guid CurrentUserID, bool isUSPlacenamesSource);
        Task<Guid> GetTaskIDDetails(Guid taskId, int configurationId);
        Task<List<int>> GetChildConfigIds(int configurationId);
        Task<List<BuildQueue>> GetConfigurationsToBeLocked(Guid taskTypeId, int time);
        Task<int> UpdateTaskStatus(BuildTask buildTask);
        Task<int> UpdateConfigModifiedDateTime(int configurationId);
		Task<Configuration> GetConfiguration(int configurationId);
		Task<int> ImportAsxiInfo(int configurationId);
        Task<List<ModListData>> GetModlistData(int configurationId, bool isDirty);
        Task<List<ModListJSON>> GetDataForModListJson(string listGeoRefId, int configurationId, string type);
        Task<string> GetLandSatValue(int configurationId);
        int UpdateModListData(int configurationId, DataTable modListDataTable);
		Task<DataSet> GetVersionUpdates(int configurationIds);
        Task<int> BranchConfigFromParent(int childConfigDefId, int parentConfigId,Guid userId,string description);
        Task<int> UpdatePartNumberFromTemp(Guid aircraftId);
        Task<int> InsertUpdateFonts(int configurationId);

        Task<int> UpdateInfoSpelling(int configurationId);
        Task<List<ScriptForcedLanguage>> GetLanguageCode(List<String> Items);

    }
}
