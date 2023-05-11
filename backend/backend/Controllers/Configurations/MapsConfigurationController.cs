using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Configuration;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers.Configurations
{

    /**
     * Controller dedicated to handling high-level tasks associated with Maps configurations,
    */
    [Route("api/[controller]")]
    [ApiController]
    public class MapsConfigurationController: PortalController
    {

        private IMapsConfigurationService _mapsConfigurationService;
        private ILoggerManager _logger;
        public MapsConfigurationController(IMapsConfigurationService mapsConfigurationService, ILoggerManager logger)
        {
            _mapsConfigurationService = mapsConfigurationService;
            _logger = logger;
        }
       

        [HttpGet]
        [Route("{configurationId}/layers")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<Layer>>> GetLayers(string configurationId)
        {
            try
            {
                return Ok(await _mapsConfigurationService.GetLayers(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/layers/update")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateLayer(string configurationId, [FromBody] Layer layerData)
        {
            try
            {
                return Ok(await _mapsConfigurationService.UpdateLayer(Int32.Parse(configurationId), layerData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationId}/simple/{section}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<Dictionary<string, object>>> GetConfigurationFor(string configurationId, string section)
        {
            try
            {
                return Ok(await _mapsConfigurationService.GetConfigurationFor(Int32.Parse(configurationId), section));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }


        [HttpPost]
        [Route("{configurationId}/simple/{section}/set/{name}/to/{value}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateSectionData(string configurationId, string section, string name, string value)
        {
            try
            {
                return Ok(await _mapsConfigurationService.UpdateSectionData(Int32.Parse(configurationId), section, name, value));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("{configurationId}/isProductLevelConfig")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<bool>> GetProductLevelConfigDetails(string configurationId)
        {
            try
            {
                return Ok(await _mapsConfigurationService.GetProductLevelConfigDetails(int.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
    }

}
