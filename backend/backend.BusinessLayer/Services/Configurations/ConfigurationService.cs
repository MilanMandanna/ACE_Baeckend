using AutoMapper;
using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Models.Task;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers.Azure;
using backend.Helpers.Validator;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services.Configurations
{

    /**
     * Service that supplies high level information regarding a configuration. This module
     * is also where assignment of a baseline configuration to an aircraft takes place.
     **/
    public class ConfigurationService : IConfigurationService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private IImportService _importService;
        private ILoggerManager _logger;
        private Helpers.Configuration _configuration;
        private readonly string taskNameQueuedForLock = "QueuedForLockCofiguration";
        public ConfigurationService(IUnitOfWork unitOfWork, IMapper mapper, IImportService importService, ILoggerManager logger, Helpers.Configuration configuration)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _importService = importService;
            _logger = logger;
            _configuration = configuration;
        }
        /**
         * Returns a listing of all definitions in the system. this includes an indication
         * if that configuration is a global, product, or platform configuration. Configurations
         * for individual fleets or aircraft are not part of this list. each record includes the name as well
         * as linking to the parent configuration (in the case of the global, it is linked to itself)
         **/
        public async Task<List<ConfigurationDefinitionDTO>> GetAllDefinitions()
        {
            using var context = _unitOfWork.Create;
            var productDefinitions = await context.Repositories.ConfigurationDefinitions.GetProductConfigurationDefinitions();
            var platformDefinitions = await context.Repositories.ConfigurationDefinitions.GetPlatformConfigurationDefinitions();
            var globalDefinitions = await context.Repositories.ConfigurationDefinitions.GetGlobalConfigurationDefinitions();
            var results = new List<ConfigurationDefinitionDTO>();

            foreach (var definition in globalDefinitions)
            {
                var global = await context.Repositories.ConfigurationDefinitions.GetGlobal(definition.ConfigurationDefinitionID);
                if (global != null)
                {
                    results.Add(new ConfigurationDefinitionDTO
                    {
                        ConfigurationDefinitionID = definition.ConfigurationDefinitionID,
                        ParentConfigurationDefinitionID = definition.ConfigurationDefinitionParentID,
                        Name = global.Name,
                        ConfigurationDefinitionType = "global"
                    });
                }
            }

            foreach (var definition in productDefinitions)
            {
                var product = await context.Repositories.ConfigurationDefinitions.GetProduct(definition.ConfigurationDefinitionID);
                var TopLevelPartNumber = await context.Repositories.ConfigurationDefinitions.GetTopLevelPartNumber(definition.ConfigurationDefinitionID);
                var partNumberCollectionId = await context.Repositories.ConfigurationDefinitions.GetPartNumberCollection(definition.OutputTypeID);

                if (product != null)
                {
                    results.Add(new ConfigurationDefinitionDTO
                    {
                        ConfigurationDefinitionID = definition.ConfigurationDefinitionID,
                        ParentConfigurationDefinitionID = definition.ConfigurationDefinitionParentID,
                        Name = product.Name,
                        Description = product.Description,
                        OutputTypeId = definition.OutputTypeID,
                        TopLevelPartnumber = TopLevelPartNumber.TopLevelPartnumber,
                        PartNumberCollectionID = partNumberCollectionId,
                        ConfigurationDefinitionType = "product"

                    });
                }
            }

            foreach (var definition in platformDefinitions)
            {
                var platform = await context.Repositories.ConfigurationDefinitions.GetPlatform(definition.ConfigurationDefinitionID);
                if (platform != null)
                {
                    results.Add(new ConfigurationDefinitionDTO
                    {
                        ConfigurationDefinitionID = definition.ConfigurationDefinitionID,
                        ParentConfigurationDefinitionID = definition.ConfigurationDefinitionParentID,
                        Name = platform.Name,
                        Description = platform.Description,
                        ConfigurationDefinitionType = "platform"
                    });
                }
            }
            return results;
        }

        /**
         * Retrieves the configuration definition that an aircraft derives from. this may be a global, platform, or product
         * configuration and the type in the response indicates accordingly.
         **/
        public async Task<ConfigurationDefinitionDTO> GetAircraftConfigurationType(string tailNumber)
        {
            using var context = _unitOfWork.Create;
            var aircraft = context.Repositories.AircraftRepository.FindByTailNumber(tailNumber);
            if (aircraft == null) return null;

            var definition = (await context.Repositories.AircraftConfigurationMappings.FilterAsync<AircraftConfigurationMapping>("AircraftID", aircraft.Id)).DefaultIfEmpty(null).FirstOrDefault();
            if (definition == null) return null;

            var configuration = (await context.Repositories.ConfigurationDefinitions.FilterAsync<ConfigurationDefinition>("ConfigurationDefinitionID", definition.ConfigurationDefinitionID)).DefaultIfEmpty(null).FirstOrDefault();
            if (configuration == null) return null;

            var parent = (await context.Repositories.ConfigurationDefinitions.FilterAsync<ConfigurationDefinition>("ConfigurationDefinitionID", configuration.ConfigurationDefinitionParentID)).DefaultIfEmpty(null).FirstOrDefault();
            if (parent == null) return null;
            var partNumberCollectionId = await context.Repositories.AircraftRepository.GetPartNumberCollectionId(configuration.ConfigurationDefinitionID);
            var platform = await context.Repositories.ConfigurationDefinitions.GetPlatform(parent.ConfigurationDefinitionID);
            if (platform != null) return new ConfigurationDefinitionDTO
            {
                ConfigurationDefinitionID = parent.ConfigurationDefinitionID,
                ParentConfigurationDefinitionID = parent.ConfigurationDefinitionParentID,
                PartNumberCollectionID = partNumberCollectionId,
                ConfigurationDefinitionType = "platform",
                Name = platform.Name
            };

            var product = await context.Repositories.ConfigurationDefinitions.GetProduct(parent.ConfigurationDefinitionID);
            if (product != null) return new ConfigurationDefinitionDTO
            {
                ConfigurationDefinitionID = parent.ConfigurationDefinitionID,
                ParentConfigurationDefinitionID = parent.ConfigurationDefinitionParentID,
                ConfigurationDefinitionType = "product",
                Name = product.Name
            };

            var global = await context.Repositories.ConfigurationDefinitions.GetGlobal(parent.ConfigurationDefinitionID);
            if (global != null) return new ConfigurationDefinitionDTO
            {
                ConfigurationDefinitionID = parent.ConfigurationDefinitionID,
                ParentConfigurationDefinitionID = parent.ConfigurationDefinitionParentID,
                ConfigurationDefinitionType = "global",
                Name = global.Name
            };

            return null;
        }

        public async Task<string> UploadfiletoServer(IFormFile file)
        {

            string tempPathtoSave = "";
            try
            {
                tempPathtoSave = Path.Join(Path.GetTempFileName() + "InitialConfig");

                if (Directory.Exists(tempPathtoSave)) Directory.Delete(tempPathtoSave, true);
                Directory.CreateDirectory(tempPathtoSave);
                tempPathtoSave = Path.Combine(tempPathtoSave, file.FileName);
                using (var stream = new FileStream(tempPathtoSave, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                    
                }
                

            }
            catch (Exception ex)
            {
                _logger.LogError("Uploaded file is not successed: " + ex);
            }
            return tempPathtoSave;

        }


        private string GetDescriptionFromEnum(Enum value)
        {
            DescriptionAttribute attribute = value.GetType()
            .GetField(value.ToString())
            .GetCustomAttributes(typeof(DescriptionAttribute), false)
            .SingleOrDefault() as DescriptionAttribute;
            return attribute == null ? value.ToString() : attribute.Description;
        }


        /**
         * Updates the aircraft configuration definition record to point top the specified configuration definition as its baseline. a new
         * mapping record for the aircraft will be created. 
         * 
         * todo: extend this logic to somehow trigger the population of the various mapping tables for the configuration. ideally,
         * the new configuration definition for the aircraft should be generated and populated via a stored procedure.
         **/
        public async Task<bool> SetAircraftConfigurationType(string tailNumber, int configurationDefinitionID, UserListDTO user, IFormFile file)
        {
            try
            {
                using var context = _unitOfWork.Create;
                var fp = new FileUploadType();
                string buildPath = "";
                string copyFileName = "";
                string copystr = string.Empty;

                if (file != null)
                {
                    buildPath = await UploadfiletoServer(file);
                    copyFileName = file.FileName.Replace(".zip", "");
                    await context.Repositories.AircraftRepository.SetTopLevelPartnumber(copyFileName, configurationDefinitionID);
                    var filepath = new List<ZipArchiveEntry>();
                    string[] splitarray;
                    List<string> arraylist = new List<string>();
                    HashSet<DistinctHelper> distinctStrings = new HashSet<DistinctHelper>();
                    DistinctHelper distinct = new DistinctHelper();

                    // code to read contents of the zip file
                    using (var stream = file.OpenReadStream())
                    {
                        using (var archive = new ZipArchive(stream))
                        {
                            foreach (var entry in archive.Entries)
                            {
                                if (entry.FullName.EndsWith(".tgz", StringComparison.OrdinalIgnoreCase))
                                {
                                    filepath.Add(entry);
                                }
                                else if (entry.FullName.EndsWith(".cii", StringComparison.OrdinalIgnoreCase))
                                {
                                    filepath.Add(entry);
                                }
                            }
                        }
                    }
                    foreach (var data in filepath)
                    {
                        try
                        {
                            string[] partialFileName = data.FullName.Split('_', '.');
                            string joinObject = string.Empty;
                            string enumValue = string.Empty;

                            if (partialFileName.Length == 4)
                            {
                                if (partialFileName[3].ToLower() == "tgz")
                                {
                                    joinObject = partialFileName[0];
                                }
                                else if (partialFileName[3].ToLower() == "cii" && partialFileName[0].ToLower() =="hdbrfcfg" || partialFileName[0].ToLower() =="hdbrfcnt")
                                {
                                    joinObject = partialFileName[0] + partialFileName[3].ToUpper();
                                }
                            }
                            else if (partialFileName.Length == 3)
                            {
                                if (partialFileName[2].ToLower() == "tgz")
                                {
                                    joinObject = partialFileName[0];
                                }
                                else if (partialFileName[2].ToLower() == "cii" && partialFileName[0].ToLower() == "hdbrfcfg" || partialFileName[0].ToLower() == "hdbrfcnt")
                                {
                                    joinObject = partialFileName[0] + partialFileName[2].ToUpper();
                                }
                            }
                            else
                            {
                                if (partialFileName[4].ToLower() == "tgz")
                                {
                                    joinObject = partialFileName[0];
                                }
                                else if (partialFileName[4].ToLower() == "cii" && partialFileName[0].ToLower() == "hdbrfcfg" || partialFileName[0].ToLower() == "hdbrfcnt")
                                {
                                    joinObject = partialFileName[0] + partialFileName[4].ToUpper();
                                }
                            }

                            var partnumberCollectionId = await context.Repositories.AircraftRepository.GetPartNumberCollectionId(configurationDefinitionID);
                            if (partnumberCollectionId == 1)
                            {
                                Array values = System.Enum.GetNames(typeof(VenueNextPartNumberCollection));
                                foreach (string value in values)
                                {
                                    if (value == joinObject)
                                    {
                                        var enumdata = (int)Enum.Parse(typeof(VenueNextPartNumberCollection), value);
                                        enumValue = GetDescriptionFromEnum((VenueNextPartNumberCollection)enumdata);
                                    }
                                }
                            }
                            else if (partnumberCollectionId == 2)
                            {
                                Array values = System.Enum.GetNames(typeof(VenueHybridPartNumberCollection));
                                foreach (string value in values)
                                {
                                    if (value == joinObject)
                                    {
                                        var enumdata = (int)Enum.Parse(typeof(VenueHybridPartNumberCollection), value);
                                        enumValue = GetDescriptionFromEnum((VenueHybridPartNumberCollection)enumdata);
                                    }
                                }
                            }
                           
                            var partnumberId = await context.Repositories.AircraftRepository.GetPartnumberId(enumValue);
                            if (partnumberId != 0)
                            {
                                string fileNameWithoutExtension = Path.GetFileNameWithoutExtension(data.FullName);
                                string outputString = new string(fileNameWithoutExtension.Where(c => !char.IsLower(c)).ToArray());
                                splitarray = outputString.Split(new Char[] { '_', '.' });
                                int count = fileNameWithoutExtension.Count(f => f == '_');
                                if (count >= 3)
                                {
                                    copystr = splitarray[1] + '_' + splitarray[2];
                                }

                                else
                                {
                                    copystr = splitarray[1];
                                }
                                distinct.partNumber = copystr;
                                distinct.partNumberID = partnumberId;
                                distinctStrings.Add(distinct);
                                arraylist.Add(copystr);
                                foreach (var i in distinctStrings)

                                {
                                    var extractedpartnumber = await context.Repositories.AircraftRepository.SaveExtractedPartnumber(configurationDefinitionID, i.partNumberID, i.partNumber);
                                }

                            }
                        }
                        catch (Exception ex)
                        {
                            throw ex;
                        }
                    }

                    BuildPackageHelper bp = new BuildPackageHelper();
                    fp = bp.BuilDCustomContentPackages(buildPath);
                    ConfigurationValidationHelper.ConfigurationValidation(fp, _logger);
                }

                var aircraft = context.Repositories.AircraftRepository.FindByTailNumber(tailNumber);
                if (aircraft == null) return false;

                var definition = (await context.Repositories.ConfigurationDefinitions.FilterAsync("ConfigurationDefinitionID", configurationDefinitionID)).FirstOrDefault();
                if (definition == null) return false;

                // TODO: gah, need to get the primary key on this field updated.
                var maxID = await context.Repositories.ConfigurationDefinitions.MaxConfigurationDefinitionID();
                var nextId = maxID + 1;

                var mapping = (await context.Repositories.AircraftConfigurationMappings.FilterAsync("AircraftID", aircraft.Id)).DefaultIfEmpty(null).FirstOrDefault();
                ConfigurationDefinition currentDefinition = null;

                // delete any previous mapping
                if (mapping != null)
                {
                    currentDefinition = (await context.Repositories.ConfigurationDefinitions.FilterAsync("ConfigurationDefinitionID", mapping.ConfigurationDefinitionID)).FirstOrDefault();

                    await context.Repositories.AircraftConfigurationMappings.DeleteAsync(mapping);
                }

                // new definition being created
                if (currentDefinition == null)
                {
                    var newDefinition = new ConfigurationDefinition
                    {
                        ConfigurationDefinitionID = nextId,
                        ConfigurationDefinitionParentID = configurationDefinitionID,
                        ConfigurationTypeID = definition.ConfigurationTypeID,
                        OutputTypeID = definition.OutputTypeID,
                        FeatureSetID = definition.FeatureSetID,
                        Active = true,
                        AutoLock = 1,
                        AutoDeploy = 1,
                        UpdatedUpToVersion = definition.UpdatedUpToVersion
                    };

                    await context.Repositories.ConfigurationDefinitions.InsertAsync(newDefinition);
                }

                // updating a previous definition
                else
                {
                    nextId = currentDefinition.ConfigurationDefinitionID;
                    currentDefinition.ConfigurationDefinitionParentID = configurationDefinitionID;
                    currentDefinition.ConfigurationTypeID = definition.ConfigurationTypeID;
                    currentDefinition.OutputTypeID = definition.OutputTypeID;
                    currentDefinition.FeatureSetID = definition.FeatureSetID;

                    await context.Repositories.ConfigurationDefinitions.UpdateAsync(currentDefinition);
                }

                // insert the new mapping
                mapping = new AircraftConfigurationMapping()
                {
                    AircraftID = aircraft.Id,
                    ConfigurationDefinitionID = nextId
                };

                await context.Repositories.AircraftConfigurationMappings.InsertAsync(mapping);

                // insert the new config ID
                var isCurrentConfigurationExist = await context.Repositories.ConfigurationRepository.isConfigurationExist(mapping.ConfigurationDefinitionID);
                var maxConfigurationID = await context.Repositories.ConfigurationRepository.MaxConfigurationID();
                var NextConfigurationID = maxConfigurationID + 1;
                if (!isCurrentConfigurationExist)
                {
                    if (file != null)
                    {
                        var newConfiguration = new Configuration()
                        {
                            ConfigurationId = NextConfigurationID,
                            ConfigurationDefinitionId = nextId,
                            Version = 1,
                            Locked = false,
                            Description = "Aircraft configuration from Import initial Configuration"

                        };
                        await context.Repositories.ConfigurationRepository.InsertAsync(newConfiguration);
                    }
                    else
                    {
                        //branch the config from parent config
                        List<ConfigurationName> lockedConfigs = await context.Repositories.ConfigurationRepository.GetLockDefinitionVersions(configurationDefinitionID);
                        if (lockedConfigs.Count > 0)
                        {
                            var latestConfig = lockedConfigs.OrderByDescending(x => x.Version).FirstOrDefault();

                            var config = await context.Repositories.Simple<backend.DataLayer.Models.Configuration.Configuration>().FirstAsync("ConfigurationID", latestConfig.ConfigurationId);
                            if (config == null)
                                return false;

                            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Save Aircraft Configuration");

                            BuildQueueItem item = new BuildQueueItem
                            {
                                Debug = false,
                                Config = new BuildTask()
                            };
                            item.Config.ID = Guid.NewGuid();
                            item.Config.ConfigurationID = latestConfig.ConfigurationId;
                            item.Config.ConfigurationDefinitionID = nextId;
                            item.Config.TaskTypeID = taskType.ID;
                            item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                            item.Config.DateStarted = DateTime.Now;
                            item.Config.DateLastUpdated = DateTime.Now;
                            item.Config.PercentageComplete = 0f;
                            item.Config.StartedByUserID = user.Id;
                            item.Config.AircraftID = aircraft.Id;

                            item.Config.TaskDataJSON = "Aircraft configuration from Parent configuration";

                            await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);

                            string connectionString = _configuration.AzureWebJobsStorage;
                            string queueName = _configuration.AzureWebJobsQueue;
                            string message = JsonConvert.SerializeObject(item);
                            var bytes = Encoding.ASCII.GetBytes(message);
                            var base64 = System.Convert.ToBase64String(bytes);
                            await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);
                        }
                        else
                            return false;
                    }
                }
                else
                {
                    //Configuration ID exist , no need to do initial import
                    return false;
                }
                await context.SaveChanges();
                if (file != null)
                {
                    await _importService.ImportInitialConfig(NextConfigurationID, user, fp.configPathforWebjob, "Import Initial Config");
                    await _importService.ImportCustomContent(NextConfigurationID, fp, user);
                    //Delete temp build directory
                    if (buildPath != "")
                    {
                        string tempDir = Directory.GetParent(buildPath).ToString();
                        if (Directory.Exists(tempDir))
                        {
                            Directory.Delete(tempDir, true);
                        }
                    }
                }
                return true;
            }

            catch (Exception ex)
            {
                throw ex;
            }
        }
        public async Task<ConfigurationAccessHintDTO> GetAccessHint(UserListDTO currentUser)
        {
            using var context = _unitOfWork.Create;

            Guid userId = currentUser.Id;
            var userClaims = await context.Repositories.UserClaimsRepository.GetClaimsByUserId(userId);

            var dto = new ConfigurationAccessHintDTO
            {
                GlobalConfiguration = false,
                PlatformConfiguration = false,
                ProductConfiguration = false,
                Operator = false,
                Operators = false,
                Aircraft = false
            };
            //check of available configuration claim 
            if (userClaims.Any(i => i.Name == PortalClaimType.ManageGlobalConfiguration) || userClaims.Any(i => i.Name == "ManageGlobalConfiguration"))
                dto.GlobalConfiguration = true;
            if (userClaims.Any(i => i.Name == PortalClaimType.ManagePlatformConfigurations))
                dto.PlatformConfiguration = true;
            if (userClaims.Any(i => i.Name == PortalClaimType.ManageProductConfigurations))
                dto.ProductConfiguration = true;

            //get list of operators for the user for all the operator related claims
            List<object> operators = new List<object>();
            if (userClaims.Any(i => i.Name == PortalClaimType.ManageOperator))
            {
                var manageOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageOperator);
                var result = await context.Repositories.UserRoleClaimsRepository.GetScopeValueForUser(userId, manageOperatorClaim.ID, "OperatorID");
                operators.AddRange(result);
            }
            if (userClaims.Any(i => i.Name == PortalClaimType.ViewOperator))
            {
                var viewOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ViewOperator);
                var result = await context.Repositories.UserRoleClaimsRepository.GetScopeValueForUser(userId, viewOperatorClaim.ID, "OperatorID");
                operators.AddRange(result);
            }
            if (userClaims.Any(i => i.Name == PortalClaimType.AdministerOperator))
            {
                var administerOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.AdministerOperator);
                var result = await context.Repositories.UserRoleClaimsRepository.GetScopeValueForUser(userId, administerOperatorClaim.ID, "OperatorID");
                operators.AddRange(result);
            }

            //get the aircrafts with configuration mapping 
            var aircraftMapping = await context.Repositories.AircraftConfigurationMappings.FindAllAsync();
            var aircraftIds = aircraftMapping.Select(x => x.AircraftID).ToArray();
            var allOperatorsWithAircraftConfigurations = await context.Repositories.AircraftRepository.GetOperators(aircraftIds);

            //if scopeValue is null for any claim assume user has access to all the operators
            if (operators.Any(i => i.ToString() == ""))
            {
                dto.Operators = true;
            }
            else
            {
                //check if user has access to multiple operator with configuration otherwise return single one
                var operatorsList = allOperatorsWithAircraftConfigurations.Where(i => operators.Contains(i.Id));
                if (operatorsList.Count() > 1) dto.Operators = true;
                else if (operatorsList.Count() == 1)
                {
                    dto.Operator = true;
                    dto.OperatorID = operatorsList.First().Id;
                }

            }

            //check if the user has access to configuration of only one aircraft

            var roleClaimMap = await context.Repositories.UserRoleClaimsRepository.GetClaimsForUserWithAircraftsConfigurations(currentUser.Id);
            if (roleClaimMap.Count() == 1)
            {
                dto.Aircraft = true;
                dto.AircraftId = roleClaimMap.First().AircraftID;
                var definition = (await context.Repositories.AircraftConfigurationMappings.FilterAsync<AircraftConfigurationMapping>("AircraftID", roleClaimMap.First().AircraftID)).DefaultIfEmpty(null).FirstOrDefault();

                dto.AircraftConfigurationdefintionId = definition.ConfigurationDefinitionID;
            }
            return dto;
        }

        public async Task<IEnumerable<UserConfigurationDefinitionDTO>> GetConfigurationsByUserId(UserListDTO currentUser)
        {
            Guid userId = currentUser.Id;
            using var context = _unitOfWork.Create;
            var configs = await context.Repositories.ConfigurationDefinitions.GetConfigurationDefinitionsForUser(userId);
            var result = _mapper.Map<IEnumerable<UserConfigurationDefinition>, IEnumerable<UserConfigurationDefinitionDTO>>(configs);
            return result;

        }

        public async Task<IEnumerable<OperatorListDTO>> GetOperators(UserListDTO currentUser, int configurationDefinitionId, string operatorType)
        {
            Guid userId = currentUser.Id;
            using var context = _unitOfWork.Create;
            var configs = await context.Repositories.ConfigurationDefinitions.GetOperatorsWithConfigurationDefinitionForUser(userId,configurationDefinitionId, operatorType);
            var result = _mapper.Map<IEnumerable<Operator>, IEnumerable<OperatorListDTO>>(configs);
            return result;
        }

        public async Task<IEnumerable<AircraftConfigurationDTO>> GetAircrafts(Guid operatorId, Guid userId)
        {
            using var context = _unitOfWork.Create;
            var configs = await context.Repositories.ConfigurationDefinitions.GetAircraftsWithConfigurationDefinitionForOperator(operatorId, userId);
            var result = _mapper.Map<IEnumerable<AircraftConfiguration>, IEnumerable<AircraftConfigurationDTO>>(configs);
            return result;
        }

        public async Task<IEnumerable<ConfigurationDefinitionVersionDTO>> GetDefinitionVersions(int definitionId)
        {
            using var context = _unitOfWork.Create;
            var versions = await context.Repositories.ConfigurationRepository.GetDefinitionVersions(definitionId);
            var result = _mapper.Map<IEnumerable<ConfigurationName>, IEnumerable<ConfigurationDefinitionVersionDTO>>(versions);
            DateTimeOffset dto = new DateTimeOffset(1970, 1, 1, 0, 0, 0, TimeSpan.Zero);
            foreach (var item in result)
            {
                if (item.LockDate.Equals(dto.Date.ToShortDateString()))
                {
                    item.LockDate = null;
                }
                else
                {
                    item.LockDate = item.LockDate;
                }


            }
            return result;

        }


        public async Task<IEnumerable<ConfigurationDefinitionVersionDTO>> GetLockDefinitionVersions(int definitionId)
        {
            using var context = _unitOfWork.Create;
            var versions = await context.Repositories.ConfigurationRepository.GetLockDefinitionVersions(definitionId);
            var result = _mapper.Map<IEnumerable<Configuration>, IEnumerable<ConfigurationDefinitionVersionDTO>>(versions);
            DateTimeOffset dto = new DateTimeOffset(1970, 1, 1, 0, 0, 0, TimeSpan.Zero);
            foreach (var item in result)
            {
                if (item.LockDate.Equals(dto.Date.ToShortDateString()))
                {
                    item.LockDate = string.Empty;
                }
                else
                {
                    item.LockDate = item.LockDate;
                }


            }
            return result;

        }

        public async Task<ConfigurationUpdatesDTO> GetConfigurationUpdates(int configurationId)
        {
            using var context = _unitOfWork.Create;
            IDictionary<string, UpdatesDTO> configuration = new Dictionary<string, UpdatesDTO>();
            var features = await context.Repositories.ConfigurationRepository.GetFeatures(configurationId);
            var customConfig = features.Where(feature => feature.Name.Equals("CustomConfig"));
            var customContent = features.Where(feature => feature.Name.Equals("CustomContent"));

           

            var customConfigEnabled = customConfig.Count() > 0 && customConfig.First().Value.ToLower() == "true";

            if (customConfigEnabled)
            {
                configuration.Add("customconfiguration", new UpdatesDTO
                {
                    Updates = 0,
                    HasConflicts = false
                });
            }

            var customContentEnabled = customContent.Count() > 0 && customContent.First().Value.ToLower() == "true";
         

            if (customContentEnabled)
            {
                configuration.Add("customcontent", new UpdatesDTO
                {
                    Updates = 0,
                    HasConflicts = false
                });
            }

            var updates = new ConfigurationUpdatesDTO();
            updates.ConfigurationUpdates = configuration;
            return updates;
        }

        public async Task<IEnumerable<ConfigurationFeature>> GetConfigurationFeatures(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var features = await context.Repositories.ConfigurationRepository.GetFeatures(configurationId);
            return features;
        }

        public async Task<ConfigurationFeature> GetConfigurationFeature(int configurationId, string featureName)
        {
            using var context = _unitOfWork.Create;
            var feature = await context.Repositories.ConfigurationRepository.GetFeature(configurationId, featureName);
            return feature;
        }

        public async Task<ConfigurationDefinitionDetails> GetConfigurationInfoByConfigurationId(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var configs = await context.Repositories.ConfigurationDefinitions.GetConfigurationInfoByConfigurationId(configurationId);
            return configs.Count() > 0 ? configs.First() : null;
        }

        public async Task<DataCreationResultDTO> CreateInsetConfigurationMapping(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ConfigurationRepository.CreateInsetConfigurationMapping(configurationId);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Inset Configuration Mapping has been created" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error creating Inset Configuration Mapping" };
        }

        #region Config definition lock and deploy
        public async Task<DataCreationResultDTO> UpdateConfigurationDefinitionSettings(int configurationId, List<ConfigurationSettings> configurationDefinitionSettings)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ConfigurationRepository.UpdateConfigurationDefinitionSettings(configurationId, configurationDefinitionSettings);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Config settings updated successfully" };
            }
            return new DataCreationResultDTO { IsError = true, Message = "Config settings updation failed" };
        }
        #endregion

        public async Task<IEnumerable<string>> GetDefaultLockingComments(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ConfigurationRepository.GetDefaultLockingComments(configurationId);
            return result;
        }

        public async Task<DataCreationResultDTO> LockConfiguration(int configurationId, string lockComments, Guid currentUser)
        {
            using var context = _unitOfWork.Create;
            var config = await context.Repositories.Simple<backend.DataLayer.Models.Configuration.Configuration>().FirstAsync("ConfigurationID", configurationId);
            if (config == null)
                return new DataCreationResultDTO { IsError = true, Message = "invalid configuration" };

            var definition = await context.Repositories.Simple<ConfigurationDefinition>().FirstAsync("ConfigurationDefinitionID", config.ConfigurationDefinitionId);
            if (definition == null)
                return new DataCreationResultDTO { IsError = true, Message = "invalid configuration definition" };

            string taskType = "MergCofiguration";
            var taskTypeRecord = await context.Repositories.Simple<TaskType>().FirstAsync("Name", taskType);

            BuildQueueItem item = new BuildQueueItem
            {
                Debug = false,
                Config = new BuildTask()
            };
            item.Config.ID = Guid.NewGuid();
            item.Config.ConfigurationDefinitionID = config.ConfigurationDefinitionId;
            item.Config.ConfigurationID = configurationId;
            item.Config.StartedByUserID = currentUser;
            item.Config.TaskTypeID = taskTypeRecord.ID;
            item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
            item.Config.DateStarted = DateTime.Now;
            item.Config.DateLastUpdated = DateTime.Now;
            item.Config.PercentageComplete = 0f;
            item.Config.TaskDataJSON = lockComments;

            // look for an associated aircraft id
            var aircraftConfiguration = await context.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("ConfigurationDefinitionID", definition.ConfigurationDefinitionID);
            if (aircraftConfiguration != null)
                item.Config.AircraftID = aircraftConfiguration.AircraftID;

            await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
            await context.SaveChanges();

            string connectionString = _configuration.AzureWebJobsStorage;
            string queueName = _configuration.AzureWebJobsQueue;
            string message = JsonConvert.SerializeObject(item);
            var bytes = Encoding.ASCII.GetBytes(message);
            var base64 = System.Convert.ToBase64String(bytes);
            await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);

            return new DataCreationResultDTO()
            {
                IsError = false,
                Id = item.Config.ID,
                Message = "Lock configuration task is Initiated."
            };
        }

        public async Task<DataCreationResultDTO> UpdateReleaseNotes(int configurationId, string version, string releaseNotes)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ConfigurationRepository.UpdateReleaseNotes(configurationId, version, releaseNotes);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Release Notes Updated!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Updating the Relese Notes" };
        }

        //get all the configs that are queued for locking and check last updated Date
        //if update 1 hr before, the create a task for merge config
        public async Task<int> CheckConfigUpdates()
        {
            using var context = _unitOfWork.Create;

            var taskTypeForQueuedForLocking = await context.Repositories.Simple<TaskType>().FirstAsync("Name", taskNameQueuedForLock);

            var list = await context.Repositories.ConfigurationRepository.GetConfigurationsToBeLocked(taskTypeForQueuedForLocking.ID, _configuration.ConfigUpdatesWaitingTimeBeforeLock);
            _logger.LogInfo("Child config id count is " + list.Count);

            foreach (var item in list)
            {
                var result = await CreateMergeTask(item);
                if (result > 0)
                {
                    //update the queue task as completed
                    var buildTask = new BuildTask();
                    buildTask.ID = item.TaskId;
                    buildTask.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.Succeeded;
                    buildTask.DateLastUpdated = DateTime.Now;
                    buildTask.PercentageComplete = 100f;
                    await context.Repositories.ConfigurationRepository.UpdateTaskStatus(buildTask);
                }
            }
            await context.SaveChanges();
            return 1;
        }

        private async Task<int> CreateMergeTask(BuildQueue buildQueue)
        {

            using var context = _unitOfWork.Create;
            try
            {
                string taskType = "MergCofiguration";
                var taskTypeRecord = await context.Repositories.Simple<TaskType>().FirstAsync("Name", taskType);

                BuildQueueItem item = new BuildQueueItem
                {
                    Debug = false,
                    Config = new BuildTask()
                };
                item.Config.ID = Guid.NewGuid();
                item.Config.ConfigurationDefinitionID = buildQueue.ConfigurationDefinitionID;
                item.Config.ConfigurationID = buildQueue.ConfigurationId;
                item.Config.StartedByUserID = buildQueue.StartedByUserId;
                item.Config.TaskTypeID = taskTypeRecord.ID;
                item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                item.Config.DateStarted = DateTime.Now;
                item.Config.DateLastUpdated = DateTime.Now;
                item.Config.PercentageComplete = 0f;
                item.Config.TaskDataJSON = buildQueue.LockComments;

                // look for an associated aircraft id
                var aircraftConfiguration = await context.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("ConfigurationDefinitionID", buildQueue.ConfigurationDefinitionID);
                if (aircraftConfiguration != null)
                    item.Config.AircraftID = aircraftConfiguration.AircraftID;

                await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
                await context.SaveChanges();

                string connectionString = _configuration.AzureWebJobsStorage;
                string queueName = _configuration.AzureWebJobsQueue;
                string message = JsonConvert.SerializeObject(item);
                var bytes = Encoding.ASCII.GetBytes(message);
                var base64 = System.Convert.ToBase64String(bytes);
                await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);
                _logger.LogInfo("Merge task is created for " + buildQueue.ConfigurationId);
                return 1;
            }
            catch (Exception ex)
            {
                _logger.LogError("CreateMergeTask failed for : " + ex);
                return 0;
            }

        }
        public async Task<DataCreationResultDTO> UpdateConfigModifiedDateTime(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ConfigurationRepository.UpdateConfigModifiedDateTime(configurationId);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Date Modified!" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error in Date Modify" };
        }

        public async Task<PlatformConfigurationData> GetPlatformConfigurationData(int configurationDefinitionId)
        {
            PlatformConfigurationData platformConfigurationData = new PlatformConfigurationData();
            var context = _unitOfWork.Create;

            platformConfigurationData.PlatformList = await context.Repositories.ConfigurationDefinitions.GetPlatforms(configurationDefinitionId);
            platformConfigurationData.InstallationTypes = await context.Repositories.ConfigurationDefinitions.GetInstallationTypes();
            platformConfigurationData.OutputTypes = await context.Repositories.ConfigurationDefinitions.GetOutputTypes();

            return platformConfigurationData;
        }

        public async Task<DataCreationResultDTO> UpdatePlatformData(Platform platformData, Guid userId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ConfigurationDefinitions.UpdatePlatformData(platformData, userId);

            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Successfully updated platform data." };
            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed to update platform data." };
        }

        public async Task<DataDownloadResultDTO> SaveProductConfigurationData(ProductConfigurationData productConfigurationData, Guid userId)
        {
            using var context = _unitOfWork.Create;

            if (productConfigurationData.Type.ToLower() == "create platform")
            {
                var definition = await context.Repositories.Simple<ConfigurationDefinition>().FirstAsync("ConfigurationDefinitionID", productConfigurationData.ConfigurationDefinitionId);
                var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Save Product Configuration");

                if (definition == null)
                {
                    return new DataDownloadResultDTO
                    {
                        IsError = true,
                        Message = "Invalid configuration"
                    };
                }
                BuildQueueItem item = new BuildQueueItem
                {
                    Debug = false,
                    Config = new BuildTask()
                };
                item.Config.ID = Guid.NewGuid();
                item.Config.ConfigurationID = 0;
                item.Config.ConfigurationDefinitionID = productConfigurationData.ConfigurationDefinitionId;
                item.Config.TaskTypeID = taskType.ID;
                item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                item.Config.DateStarted = DateTime.Now;
                item.Config.DateLastUpdated = DateTime.Now;
                item.Config.PercentageComplete = 0f;
                item.Config.StartedByUserID = userId;
                item.Config.TaskDataJSON = JsonConvert.SerializeObject(productConfigurationData);

                await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
                await context.SaveChanges();

                string connectionString = _configuration.AzureWebJobsStorage;
                string queueName = _configuration.AzureWebJobsQueue;
                string message = JsonConvert.SerializeObject(item);
                var bytes = Encoding.ASCII.GetBytes(message);
                var base64 = System.Convert.ToBase64String(bytes);
                await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);

                return new DataDownloadResultDTO()
                {
                    IsError = false,
                    Id = item.Config.ID,
                    Message = "Task to save product configuration data has been created"
                };
            }
            else
            {
                DataTable platformDataTable = new DataTable();
                platformDataTable.Columns.Add("ConfigurationDefinitionID", typeof(int));
                platformDataTable.Columns.Add("Name", typeof(string));
                platformDataTable.Columns.Add("Description", typeof(string));
                platformDataTable.Columns.Add("PlatformId", typeof(int));
                platformDataTable.Columns.Add("InstallationTypeID", typeof(string));

                productConfigurationData.PlatformConfiguration.ForEach(platform =>
                {
                    platformDataTable.Rows.Add(platform.ConfigurationDefinitionID, platform.Name, platform.Description, platform.PlatformId, platform.InstallationTypeID);
                });

                var result = await context.Repositories.ConfigurationDefinitions.SaveProductConfigurationData(productConfigurationData, userId, platformDataTable);
                if (result == -100)
                {
                    return new DataDownloadResultDTO { IsError = true, Data = result.ToString(), Message = "Failed to save product data." };
                }
                else if (result > 0)
                {
                    await context.SaveChanges();
                    return new DataDownloadResultDTO { IsError = false, Message = "Product data saved successfully." };
                }
                return new DataDownloadResultDTO { IsError = true, Message = "Failed to save product data." };
            }
        }

        public async Task<IEnumerable<OutputTypes>> GetOutputTypes()
        {
            var context = _unitOfWork.Create;
            return await context.Repositories.ConfigurationDefinitions.GetOutputTypes();
        }

        public async Task<DataDownloadResultDTO> SaveProducts(ProductConfigurationData productConfigurationData, Guid userId)
        {
            using var context = _unitOfWork.Create;

            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Save Products");

            BuildQueueItem item = new BuildQueueItem
            {
                Debug = false,
                Config = new BuildTask()
            };
            item.Config.ID = Guid.NewGuid();
            item.Config.ConfigurationID = 0;
            item.Config.ConfigurationDefinitionID = 0;
            item.Config.TaskTypeID = taskType.ID;
            item.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
            item.Config.DateStarted = DateTime.Now;
            item.Config.DateLastUpdated = DateTime.Now;
            item.Config.PercentageComplete = 0f;
            item.Config.StartedByUserID = userId;
            item.Config.TaskDataJSON = JsonConvert.SerializeObject(productConfigurationData);

            await context.Repositories.Simple<BuildTask>().InsertAsync(item.Config);
            await context.SaveChanges();

            string connectionString = _configuration.AzureWebJobsStorage;
            string queueName = _configuration.AzureWebJobsQueue;
            string message = JsonConvert.SerializeObject(item);
            var bytes = Encoding.ASCII.GetBytes(message);
            var base64 = System.Convert.ToBase64String(bytes);
            await AzureFileHelper.WriteToQueue(connectionString, queueName, base64);

            return new DataDownloadResultDTO()
            {
                IsError = false,
                Id = item.Config.ID,
                Message = "Task to create product has been initiated"
            };
        }

        public async Task<AllFeatureSetData> GetAllFeatureSet(int configurationDefinitionId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ConfigurationDefinitions.GetAllFeatureSet(configurationDefinitionId);
        }

        public async Task<FeatureSetDataList> FeatureSetDataList(int configurationDefinitionId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ConfigurationDefinitions.FeatureSetDataList(configurationDefinitionId);
        }

        public async Task<DataCreationResultDTO> SaveFeatureSet(SaveFeatureSetData saveFeatureSetData)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ConfigurationDefinitions.SaveFeatureSet(saveFeatureSetData);

            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Success" };
            }
            return new DataCreationResultDTO { IsError = true, Message = "Failed" };
        }
        public async Task<BuildTask> GetProductPlatformAircraftStatus(string name, Guid userId)
        {
            using var context = _unitOfWork.Create;
            var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", name);

            return await context.Repositories.ConfigurationDefinitions.GetProductPlatformAircraftStatus(taskType.ID.ToString(),userId);
        }
    }
}
