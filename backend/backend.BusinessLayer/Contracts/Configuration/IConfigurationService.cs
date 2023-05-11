using backend.DataLayer.Models;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Subscription;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts.Configuration
{
    /**
     * Interface for retrieving high level information about an airshow configuration
     **/
    public interface IConfigurationService
    {
        Task<List<ConfigurationDefinitionDTO>> GetAllDefinitions();

        Task<ConfigurationDefinitionDTO> GetAircraftConfigurationType(string tailNumber);

        Task<bool> SetAircraftConfigurationType(string tailNumber, int configurationDefinitionID, UserListDTO user,IFormFile file);

        Task<ConfigurationAccessHintDTO> GetAccessHint(UserListDTO currentUser);
        Task<IEnumerable<UserConfigurationDefinitionDTO>> GetConfigurationsByUserId(UserListDTO currentUser);
        Task<IEnumerable<OperatorListDTO>> GetOperators(UserListDTO currentUser, int configurationDefinitionId, string operatorType);
        Task<IEnumerable<AircraftConfigurationDTO>> GetAircrafts(Guid operatorId, Guid userId);
        Task<IEnumerable<ConfigurationDefinitionVersionDTO>> GetDefinitionVersions(int definitionId);
        Task<IEnumerable<ConfigurationDefinitionVersionDTO>> GetLockDefinitionVersions(int definitionId);
        Task<ConfigurationUpdatesDTO> GetConfigurationUpdates(int configurationId);
        Task<IEnumerable<ConfigurationFeature>> GetConfigurationFeatures(int configurationId);
        Task<ConfigurationFeature> GetConfigurationFeature(int configurationId, string featureName);
        Task<ConfigurationDefinitionDetails> GetConfigurationInfoByConfigurationId(int configurationId);
        Task<DataCreationResultDTO> CreateInsetConfigurationMapping(int configurationId);

        #region Config definition lock and deploy
        Task<DataCreationResultDTO> UpdateConfigurationDefinitionSettings(int configurationId, List<ConfigurationSettings> configurationDefinitionSettings);
        #endregion

        Task<IEnumerable<string>> GetDefaultLockingComments(int configurationId);
        Task<DataCreationResultDTO> LockConfiguration(int configurationId, string lockComments, Guid currentUser);
        Task<DataCreationResultDTO> UpdateReleaseNotes(int configurationId, string version, string releaseNotes);
        Task<int> CheckConfigUpdates();
        Task<DataCreationResultDTO> UpdateConfigModifiedDateTime(int configurationId);
        Task<PlatformConfigurationData> GetPlatformConfigurationData(int configurationDefinitionId);
        Task<DataCreationResultDTO> UpdatePlatformData(Platform platformData, Guid userId);
        Task<DataDownloadResultDTO> SaveProductConfigurationData(ProductConfigurationData productConfigurationData, Guid userId);
        Task<IEnumerable<OutputTypes>> GetOutputTypes();
        Task<DataDownloadResultDTO> SaveProducts(ProductConfigurationData productConfigurationData, Guid userId);
        Task<AllFeatureSetData> GetAllFeatureSet(int configurationDefinitionId);
        Task<FeatureSetDataList> FeatureSetDataList(int configurationDefinitionId);
        Task<DataCreationResultDTO> SaveFeatureSet(SaveFeatureSetData saveFeatureSetData);
        Task<BuildTask> GetProductPlatformAircraftStatus(string name, Guid userId);
    }

}
