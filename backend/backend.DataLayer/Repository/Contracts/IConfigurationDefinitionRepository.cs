using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IConfigurationDefinitionRepository :
        IInsertAsync<ConfigurationDefinition>,
        IUpdateAsync<ConfigurationDefinition>,
        IDeleteAsync<ConfigurationDefinition>,
        IFilterAsync<ConfigurationDefinition>
    {

        Task<IEnumerable<ConfigurationDefinition>> GetProductConfigurationDefinitions();

        Task<IEnumerable<ConfigurationDefinition>> GetPlatformConfigurationDefinitions();

        Task<IEnumerable<ConfigurationDefinition>> GetGlobalConfigurationDefinitions();

        Task<Product> GetProduct(int configurationDefinitionId);

        Task<Platform> GetPlatform(int configurationDefinitionId);

        Task<Global> GetGlobal(int configurationDefinitionId);

        Task<int> MaxConfigurationDefinitionID();

        Task<IEnumerable<UserConfigurationDefinition>> GetConfigurationDefinitionsForUser(Guid userId);
        Task<IEnumerable<Operator>> GetOperatorsWithConfigurationDefinitionForUser(Guid userId, int configurationDefinitionId, string operatorType);
        Task<IEnumerable<AircraftConfiguration>> GetAircraftsWithConfigurationDefinitionForOperator(Guid operatorId, Guid userId);
        Task<IEnumerable<ConfigurationDefinitionDetails>> GetConfigurationInfoByConfigurationId(int configurationId);
        Task<IEnumerable<Platform>> GetPlatforms(int configurationDefinitionId);
        Task<int> UpdatePlatformData(Platform platformData, Guid userId);
        Task<int> SaveProductConfigurationData(ProductConfigurationData productConfigurationData, Guid userId, DataTable platformDataTable);
        Task<IEnumerable<InstallationTypes>> GetInstallationTypes();
        Task<IEnumerable<OutputTypes>> GetOutputTypes();
        Task<int> SaveProducts(ProductConfigurationData productConfigurationData, Guid userId);
        Task<AllFeatureSetData> GetAllFeatureSet(int configurationDefinitionId);
        Task<FeatureSetDataList> FeatureSetDataList(int configurationDefinitionId);
        Task<int> SaveFeatureSet(SaveFeatureSetData saveFeatureSetData);
        Task<Configuration> GetLatestConfiguration(int configurationDefinitionId);
        Task<int> GetPartNumberCollection(int outputTypeID);
        Task<TopLevelPartNumber> GetTopLevelPartNumber(int configurationdefinitionID);
        Task<BuildTask> GetProductPlatformAircraftStatus(string name, Guid userId);

    }
}
