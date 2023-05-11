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
    * Controller dedicated to handling high-level tasks associated with Modes configurations,
    */
 
    [Route("api/[controller]")]
    [ApiController]
    public class ModesConfigurationController : PortalController
    {
       
        private IModesConfigurationService _modesConfigurationService;
        private ILoggerManager _logger;

        public ModesConfigurationController(IModesConfigurationService modesConfigurationService, ILoggerManager logger)
        {
            _modesConfigurationService = modesConfigurationService;
            _logger = logger;
        }



        [HttpGet]
        [Route("{configurationId}/modes/all")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<Mode>>> GetAllModes(string configurationId)
        {
            try
            {
                return Ok(await _modesConfigurationService.GetAllModes(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }


        [HttpPost]
        [Route("{configurationId}/modes/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddMode(string configurationId, [FromBody] Mode modeData)
        {
            try
            {
                return Ok(await _modesConfigurationService.AddMode(Int32.Parse(configurationId), modeData));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/modes/{modeId}/remove")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveMode(string configurationId, string modeId)
        {
            try
            {
                return Ok(await _modesConfigurationService.RemoveMode(Int32.Parse(configurationId), modeId));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }


        [HttpPost]
        [Route("{configurationId}/modes/update")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateMode(string configurationId, [FromBody] Mode modeData)
        {
            try
            {
                return Ok(await _modesConfigurationService.UpdateMode(Int32.Parse(configurationId), modeData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
    }
}
