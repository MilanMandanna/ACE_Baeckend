using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Subscription;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.Controllers.Configurations
{
    /**
     * Controller dedicated to handling high-level tasks associated with airshow configurations,
     * such as retrieving enumerated lists and basic functions. Detailed controls of configurations should
     * be placed in different controllers
     */
    [Route("api/[controller]")]
    [ApiController]
    public class ConfigurationController : PortalController
    {

        private IConfigurationService _configurationService;
        private ILoggerManager _logger;

        public ConfigurationController(IConfigurationService configurationService, ILoggerManager logger)
        {
            _configurationService = configurationService;
            _logger = logger;
        }

        [HttpGet]
        [Route("definitions")]
        [Authorize]
        public async Task<ActionResult<List<ConfigurationDefinitionDTO>>> GetAllDefinitions()
        {
            try
            {
                return Ok(await _configurationService.GetAllDefinitions());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("aircraft/{tailNumber}/definition")]
        [Authorize(Policy = PortalPolicy.ManageAircraft)]
        public async Task<ActionResult<ConfigurationDefinitionDTO>> GetAircraftConfigurationType(string tailNumber)
        {
            try
            {
                return Ok(await _configurationService.GetAircraftConfigurationType(tailNumber));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("aircraft/{tailNumber}/definition/{configurationDefinitionID:int}")]
        [Authorize(Policy = PortalPolicy.ManageAircraft)]
        public async Task<ActionResult> SetAircraftConfigurationType(string tailNumber, int configurationDefinitionID)
        {

            try
            {
                IFormFile file = null;
                if (Request.Form != null && Request.Form.Files.Count > 0)
                {
                    file = Request.Form.Files[0];
                }

                bool result = await _configurationService.SetAircraftConfigurationType(tailNumber, configurationDefinitionID, GetCurrentUser(), file);
                if (result)
                    return Ok();
                else
                    return NoContent();

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }


        [HttpGet]
        [Route("accesshint")]
        [Authorize]
        public async Task<ActionResult<ConfigurationAccessHintDTO>> AccessHint()
        {
            try
            {
                return Ok(await _configurationService.GetAccessHint(GetCurrentUser()));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }


        [HttpGet]
        [Route("definitions/all")]
        [Authorize]
        public async Task<ActionResult<List<UserConfigurationDefinitionDTO>>> AllConfigurationDefinitionsForUser()
        {
            try
            {
                return Ok(await _configurationService.GetConfigurationsByUserId(GetCurrentUser()));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("operators/{configurationDefinitionId}/{operatorType}")]
        [Authorize]
        public async Task<ActionResult<List<OperatorListDTO>>> GetOperators(string configurationDefinitionId,string operatorType)
        {
            try
            {
                return Ok(await _configurationService.GetOperators(GetCurrentUser(),int.Parse(configurationDefinitionId), operatorType));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }


        [HttpGet]
        [Route("operators/{operatorId}/aircraft")]
        [Authorize]
        public async Task<ActionResult<List<AircraftConfigurationDTO>>> GetAircrafts(string operatorId)
        {
            try
            {
                var id = Guid.Parse(operatorId);
                return Ok(await _configurationService.GetAircrafts(id, GetCurrentUser().Id));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("definition/{definitionId}/versions")]
        [Authorize]
        public async Task<ActionResult<List<ConfigurationDefinitionVersionDTO>>> GetDefinitionVersions(string definitionId)
        {
            try
            {
                return Ok(await _configurationService.GetDefinitionVersions(int.Parse(definitionId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("definition/{definitionId}/lockedversions")]
        [Authorize]
        public async Task<ActionResult<List<ConfigurationDefinitionVersionDTO>>> GetLockDefinitionVersions(string definitionId)
        {
            try
            {
                return Ok(await _configurationService.GetLockDefinitionVersions(Int32.Parse(definitionId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }
       

        [HttpGet]
        [Route("{configurationId}/updates")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<ConfigurationUpdatesDTO>> GetConfigurationUpdates(string configurationId)
        {
            try
            {
                return Ok(await _configurationService.GetConfigurationUpdates(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationId}/features")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<string>>> GetConfigurationFeatures(string configurationId)
        {
            try
            {
                return Ok(await _configurationService.GetConfigurationFeatures(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationId}/feature/{featureName}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<string>>> GetConfigurationFeature(string configurationId, string featureName)
        {
            try
            {
                return Ok(await _configurationService.GetConfigurationFeature(Int32.Parse(configurationId), featureName));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/updateInset")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> CreateInsetConfigurationMapping(string configurationId)
        {
            try
            {
                return Ok(await _configurationService.CreateInsetConfigurationMapping(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        #region Config definition merge, lock and deploy 
        /// <summary>
        /// 1. Update Autodeploy column in config def table
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationDefinitionId}/setting/update")]
        [Authorize(Policy = PortalPolicy.ManageAircraft)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateConfigurationDefinitionSettings(string configurationDefinitionId, List<ConfigurationSettings> configurationDefinitionSettings)
        {
            try
            {
                return Ok(await _configurationService.UpdateConfigurationDefinitionSettings(Int32.Parse(configurationDefinitionId), configurationDefinitionSettings));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }
        #endregion
        
        [HttpGet]
        [Route("{configurationId}/lockingComments")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<string>>> GetDefaultLockingComments(string configurationId)
        {
            try
            {
                return Ok(await _configurationService.GetDefaultLockingComments(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/lock/{lockComments}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> LockConfiguration(string configurationId, string lockComments)
        {
            try
            {
                var userId = GetCurrentUser().Id;
                return Ok(await _configurationService.LockConfiguration(Int32.Parse(configurationId), lockComments, userId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/update/{version}/releaseNotes")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateReleaseNotes(string configurationId, string version, [FromBody] string releaseNotes)
        {
            try
            {
                var userId = GetCurrentUser().Id;
                return Ok(await _configurationService.UpdateReleaseNotes(Int32.Parse(configurationId),version, releaseNotes));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/updateConfigModifiedDateTime")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateConfigModifiedDateTime(int configurationId)
        {
            try
            {
                return Ok(await _configurationService.UpdateConfigModifiedDateTime(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationDefinitionID}/getPlatformsData")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<PlatformConfigurationData>> GetPlatformConfigurationData(string configurationDefinitionId)
        {
            try
            {
                return Ok(await _configurationService.GetPlatformConfigurationData(Int32.Parse(configurationDefinitionId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("updatePlatformData")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdatePlatformData([FromBody] Platform platformData)
        {
            try
            {
                var userId = GetCurrentUser().Id;
                return Ok(await _configurationService.UpdatePlatformData(platformData, userId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("saveProductConfigurationData")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<DataDownloadResultDTO>> SaveProductConfigurationData([FromBody] ProductConfigurationData productConfigurationData)
        {
            try
            {
                var userId = GetCurrentUser().Id;
                return Ok(await _configurationService.SaveProductConfigurationData(productConfigurationData, userId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("getOutputTypes")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<IEnumerable<OutputTypes>>> GetOutputTypes()
        {
            try
            {
                return Ok(await _configurationService.GetOutputTypes());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("saveProducts")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<DataDownloadResultDTO>> SaveProducts([FromBody] ProductConfigurationData productConfigurationData)
        {
            try
            {
                var userId = GetCurrentUser().Id;
                return Ok(await _configurationService.SaveProducts(productConfigurationData, userId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("getAllFeatureset/{configurationDefinitionId}")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<AllFeatureSetData>> GetAllFeatureSet(string configurationDefinitionId)
        {
            try
            {
                return Ok(await _configurationService.GetAllFeatureSet(int.Parse(configurationDefinitionId)));
            }
            catch(Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("getFeatureset/{configurationDefinitionId}")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<FeatureSetDataList>> FeatureSetDataList(string configurationDefinitionId)
        {
            try
            {
                return Ok(await _configurationService.FeatureSetDataList(int.Parse(configurationDefinitionId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("saveFeatureSet")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SaveFeatureSet([FromBody] SaveFeatureSetData saveFeatureSetData)
        {
            try
            {
                return Ok(await _configurationService.SaveFeatureSet(saveFeatureSetData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }
        [HttpGet]
        [Route("GetProductPlatformStatus/{name}")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<BuildTask>> GetProductPlatformAircraftStatus(string name)
        {
            try
            {
                var userId = GetCurrentUser().Id;
                return Ok(await _configurationService.GetProductPlatformAircraftStatus(name,userId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

    }
}
