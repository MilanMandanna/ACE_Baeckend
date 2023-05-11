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
     * Controller dedicated to handling high-level tasks associated with trigger configurations,
     */
    [Route("api/[controller]")]
    [ApiController]
    public class TriggerConfigurationController : PortalController
    {

        private ITriggerConfigurationService _triggerConfigurationService;
        private ILoggerManager _logger;

        public TriggerConfigurationController(ITriggerConfigurationService triggerConfigurationService, ILoggerManager logger)
        {
            _triggerConfigurationService = triggerConfigurationService;
            _logger = logger;
        }

        [HttpGet]
        [Route("{configurationId}/triggers/all")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<Trigger>>> GetAllTriggers(string configurationId)
        {
            try
            {
                return Ok(await _triggerConfigurationService.GetAllTriggers(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("{configurationId}/trigger/parameters")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<TriggerParameter>>> GetAllTriggerParameters(string configurationId)
        {
            try
            {
                return Ok(await _triggerConfigurationService.GetAllTriggerParameters(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/triggers/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddTrigger(string configurationId, [FromBody] Trigger triggerData)
        {
            try
            {
                return Ok(await _triggerConfigurationService.AddTrigger(Int32.Parse(configurationId), triggerData));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/triggers/{triggerId}/remove")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveTrigger(string configurationId, string triggerId)
        {
            try
            {
                return Ok(await _triggerConfigurationService.RemoveTrigger(Int32.Parse(configurationId), triggerId));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

       
        [HttpPost]
        [Route("{configurationId}/triggers/update")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateTrigger(string configurationId, [FromBody] Trigger triggerData)
        {
            try
            {
                return Ok(await _triggerConfigurationService.UpdateTrigger(Int32.Parse(configurationId), triggerData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("trigger/validate")]
        public ActionResult<DataCreationResultDTO> ValidateTrigger([FromBody] Trigger triggerData)
        {
            try
            {
                return Ok(_triggerConfigurationService.ValidateTrigger(triggerData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("trigger/condition")]
        public ActionResult<DataCreationResultDTO> BuildTriggerCondition([FromBody] Trigger triggerData)
        {
            try
            {
                return Ok(_triggerConfigurationService.BuildTriggerCondition(triggerData));
             }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
    }
}
