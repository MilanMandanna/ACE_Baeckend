using backend.DataLayer.Repository;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Reflection;

namespace backend.DataLayer.UnitOfWork.SqlServer
{
    public class UnitOfWorkSqlServerRepositories : IUnitOfWorkRepository
    {
        public IUserRepository UserRepository { get; }
        public IProductRepository ProductRepository { get; }
        public IAircraftRepository AircraftRepository { get; }
        public IOperatorRepository OperatorRepository { get; }
        public IDownloadPreferenceRepository DownloadPreferences { get; }
        public ICountrySpellingRepository CountrySpellings { get; }
        public IGeoRefRepository GeoRefs { get; }
        public IAirportInfoRepository AirportInfo { get; }
        public IAppearanceRepository Appearance { get; }
        public IRegionSpellingRepository RegionSpellings { get; }
        public IInfoSpellingRepository InfoSpellings { get; }
        public ICoverageSegmentRepository CoverageSegment { get; }
        public ISpellingRepository Spelling { get; }
        public IFontRepository FontRepository { get; }
        public IBuildTaskRepository BuildTaskRepository { get; }

        #region Subscriptions
        public ISubscriptionRepository Subscriptions { get; }
        public ISubscriptionFeatureRepository SubscriptionFeatures { get; }
        public ISubscriptionFeatureAssignmentRepository SubscriptionFeatureAssignments { get; }

        public IMsuConfigurationRepository MsuConfigurationRepository { get; }
        #endregion

        #region Roles_Claims
        public IUserRolesRepository UserRolesRepository { get; }
        public IUserClaimsRepository UserClaimsRepository { get; }
        public IUserRoleClaimsRepository UserRoleClaimsRepository { get; }
        public IUserRoleAssignmentsRepository UserRoleAssignmentsRepository { get; }
        #endregion

        #region Products / Platforms

        public IPlatformRepository Platforms { get; }
        public IPlatformConfigurationMappingRepository PlatformConfigurationMappings { get; }
        public IConfigurationDefinitionRepository ConfigurationDefinitions { get; }

        public ITaskRepository TaskRepository { get; }
        #endregion

        #region Aircraft Configurations

        public IAircraftConfigurationMappingRepository AircraftConfigurationMappings { get; }

        public IConfigurationRepository ConfigurationRepository { get; }
        public IScriptConfigurationRepository ScriptConfigurationRepository { get; }

        public IFontConfigurationMappingRepository FontConfigurationMappingRepository { get; }

        public ITriggerConfigurationRepository TriggerConfigurationRepository { get; }
        public ITriggerConfigurationMappingRepository TriggerConfigurationMappingRepository { get; }
        public IGlobalConfigurationRepository GlobalConfigurationRepository { get; }
        public IMapsConfigurationRepository MapsConfigurationRepository { get; }
        public IModesConfigurationRepository ModesConfigurationRepository { get; }
        public IModeConfigurationMappingRepository ModeConfigurationMappingRepository { get; }

        public ITickerConfigurationRepository TickerConfigurationRepository { get; }
        public IConfigurationComponentsRepository ConfigurationComponentsRepository { get; }
        public IASXiInsetRepository ASXiInsetRepository { get; }
        public IConfigurationComponentMappingRepository ConfigurationComponentMappingRepository { get; }

        #endregion

        public ICustomContentRepository CustomContentRepository { get; }

        #region Views Configuration
        public IViewConfigurationReposiory ViewsConfigurationRepository { get; }

        #endregion

        #region Custom Content
        public ICountryRepository CountryRepository { get; }
        public IRegionRepository RegionRepository { get; }
        #endregion

        public IMergeConfigurationRepository MergeConfigurationRepository { get; }

        public IWorldGuideRepository WorldGuide { get; }
        public IScreenSizeRepository ScreenSize { get; }

        public IMenuRepository MenuRepository { get; }

        // cache of simple repositories that have been created indexed by their type
        private Dictionary<Type, ISimpleRepositoryBase> _repositoryCache = new Dictionary<Type, ISimpleRepositoryBase>();

        /**
         * Creates an instance of a simple repository and returns it. If an instance for the specified type has already been created
         * then it is returned
         **/
        public SimpleRepository<T> Simple<T>() where T : class
        {
            if (_repositoryCache.ContainsKey(typeof(T)))
            {
                return (SimpleRepository<T>)_repositoryCache[typeof(T)];
            }

            SimpleRepository<T> repo = new SimpleRepository<T>(_context, _transaction);
            _repositoryCache.Add(typeof(T), repo);
            return repo;

        }



        private SqlConnection _context;
        private SqlTransaction _transaction;

        public UnitOfWorkSqlServerRepositories(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;

            UserRepository = new UserRepository(context, transaction);
            ProductRepository = new ProductRepository(context, transaction);
            AircraftRepository = new AircraftRepository(context, transaction);
            MsuConfigurationRepository = new MsuConfiguratonRepository(context, transaction);
            OperatorRepository = new OperatorRepository(context, transaction);
            DownloadPreferences = new DownloadPreferenceRepository(context, transaction);
            Subscriptions = new SubscriptionRepository(context, transaction);
            SubscriptionFeatures = new SubscriptionFeatureRepository(context, transaction);
            SubscriptionFeatureAssignments = new SubscriptionFeatureAssignmentRepository(context, transaction);
            UserRolesRepository = new UserRolesRepository(context, transaction);
            UserClaimsRepository = new UserClaimsRepository(context, transaction);
            UserRoleClaimsRepository = new UserRoleClaimsRepository(context, transaction);
            UserRoleAssignmentsRepository = new UserRoleAssignmentsRepository(context, transaction);
            Platforms = new PlatformRepository(context, transaction);
            ConfigurationRepository = new ConfigurationRepository(context, transaction);
            AircraftConfigurationMappings = new AircraftConfigurationMappingRepository(context, transaction);
            ConfigurationDefinitions = new ConfigurationDefinitionRepository(context, transaction);
            PlatformConfigurationMappings = new PlatformConfigurationMappingRepository(context, transaction);
            CountrySpellings = new CountrySpellingRepository(context, transaction);
            TaskRepository = new TaskRepository(context, transaction);
            GeoRefs = new GeoRefRepository(context, transaction);
            AirportInfo = new AirportInfoRepository(context, transaction);
            Appearance = new AppearanceRepository(context, transaction);
            CoverageSegment = new CoverageSegmentRepository(context, transaction);
            RegionSpellings = new RegionSpellingRepository(context, transaction);
            WorldGuide = new WorldGuideRepository(context, transaction);
            ScreenSize = new ScreenSizeRepository(context, transaction);
            FontRepository = new FontRepository(context, transaction);
            InfoSpellings = new InfoSpellingRepository(context, transaction);
            Spelling = new SpellingRepository(context, transaction);
            BuildTaskRepository = new BuildTaskRepository(context, transaction);
            TriggerConfigurationRepository = new TriggerConfigurationRepository(context, transaction);
            TriggerConfigurationMappingRepository = new TriggerConfigurationMappingRepository(context, transaction);
            GlobalConfigurationRepository = new GlobalConfigurationRepository(context, transaction);
            MapsConfigurationRepository = new MapsConfigurationRepository(context, transaction);
            ModesConfigurationRepository = new ModesConfigurationRepository(context, transaction);
            ModeConfigurationMappingRepository = new ModeConfigurationMappingRepository(context, transaction);
            TickerConfigurationRepository = new TickerConfigurationRepository(context, transaction);

			ViewsConfigurationRepository = new ViewsConfigurationRepository(context, transaction);
			ScriptConfigurationRepository = new ScriptConfigurationRepository(context, transaction);
            ASXiInsetRepository = new ASXiInsetRepository(context, transaction);
            ConfigurationComponentsRepository = new ConfigurationComponentsRepository(context, transaction);
            ConfigurationComponentMappingRepository = new ConfigurationComponentMappingRepository(context, transaction);
            FontConfigurationMappingRepository = new FontConfigurationMappingRepository(context, transaction);

            CustomContentRepository = new CustomContentRepository(context, transaction);
            CountryRepository = new CountryRepository(context, transaction);
            RegionRepository = new RegionRepository(context, transaction);
            MergeConfigurationRepository = new MergeConfigurationRepository(context, transaction);
            MenuRepository = new MenuRepository(context, transaction);
        }
    }

}
