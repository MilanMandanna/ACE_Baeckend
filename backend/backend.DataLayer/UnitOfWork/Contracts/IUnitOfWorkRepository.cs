using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer;

namespace backend.DataLayer.UnitOfWork.Contracts
{
    public interface IUnitOfWorkRepository
    {
        IUserRepository UserRepository { get; }
        IProductRepository ProductRepository { get; }
        IAircraftRepository AircraftRepository { get; }
        IMsuConfigurationRepository MsuConfigurationRepository { get; }
        IOperatorRepository OperatorRepository { get; }
        IDownloadPreferenceRepository DownloadPreferences { get; }
        ISubscriptionRepository Subscriptions { get; }
        ISubscriptionFeatureRepository SubscriptionFeatures { get; }
        ISubscriptionFeatureAssignmentRepository SubscriptionFeatureAssignments { get; }
        IUserRolesRepository UserRolesRepository { get; }
        IUserClaimsRepository UserClaimsRepository { get; }
        IUserRoleClaimsRepository UserRoleClaimsRepository { get; }
        IUserRoleAssignmentsRepository UserRoleAssignmentsRepository { get; }
        IPlatformRepository Platforms { get; }
        IAircraftConfigurationMappingRepository AircraftConfigurationMappings { get; }
        IConfigurationDefinitionRepository ConfigurationDefinitions { get; }
        IPlatformConfigurationMappingRepository PlatformConfigurationMappings { get; }
        ICountrySpellingRepository CountrySpellings { get; }
        ITaskRepository TaskRepository { get; }
        IConfigurationRepository ConfigurationRepository { get; }
        IFontConfigurationMappingRepository FontConfigurationMappingRepository { get; }
        ITriggerConfigurationRepository TriggerConfigurationRepository { get; }
        ITriggerConfigurationMappingRepository TriggerConfigurationMappingRepository { get; }
        IGlobalConfigurationRepository GlobalConfigurationRepository { get; }
        IMapsConfigurationRepository MapsConfigurationRepository { get; }
        IModesConfigurationRepository ModesConfigurationRepository { get; }
        IModeConfigurationMappingRepository ModeConfigurationMappingRepository { get; }
        IConfigurationComponentMappingRepository ConfigurationComponentMappingRepository { get; }
        IConfigurationComponentsRepository ConfigurationComponentsRepository { get; }
        IASXiInsetRepository ASXiInsetRepository { get; }

        ITickerConfigurationRepository TickerConfigurationRepository { get; }
        IGeoRefRepository GeoRefs { get; }
        IAirportInfoRepository AirportInfo { get; }
        IAppearanceRepository Appearance { get; }
        ICoverageSegmentRepository CoverageSegment { get; }
        ISpellingRepository Spelling { get; }
        IRegionSpellingRepository RegionSpellings { get; }
        IWorldGuideRepository WorldGuide { get; }
        IScreenSizeRepository ScreenSize { get; }

        IFontRepository FontRepository { get; }
        IBuildTaskRepository BuildTaskRepository { get; }
        IInfoSpellingRepository InfoSpellings { get; }
        SimpleRepository<T> Simple<T>() where T : class;
        IViewConfigurationReposiory ViewsConfigurationRepository { get; }

        IScriptConfigurationRepository ScriptConfigurationRepository { get; }

        ICustomContentRepository CustomContentRepository { get; }
        ICountryRepository CountryRepository { get; }
        IRegionRepository RegionRepository { get; }
        IMergeConfigurationRepository MergeConfigurationRepository { get; }

        IMenuRepository MenuRepository { get; }
        //T Custom<T>();
    }
}
