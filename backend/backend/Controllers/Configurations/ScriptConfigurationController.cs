using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.Controllers.Configurations
{
    [Route("api/[controller]")]
    [ApiController]
    public class ScriptConfigurationController : PortalController
    {
        private IScriptConfigurationService _scriptConfigurationService;
        private ILoggerManager _logger;
        public ScriptConfigurationController(IScriptConfigurationService scriptConfigurationService, ILoggerManager logger)
        {
            _scriptConfigurationService = scriptConfigurationService;
            _logger = logger;
        }

        [HttpGet]
        [Route("scripts/{configurationId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult> GetScripts(int configurationId)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetScripts(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("scripts/{configurationId}/remove/{scriptId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveScript(string configurationId, int scriptId)
        {
            try
            {
                return Ok(await _scriptConfigurationService.RemoveScript(Int32.Parse(configurationId), scriptId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/getlanguages/{scriptId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult> GetForcedLanguages(string configurationId, int scriptId)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetForcedLanguages(Int32.Parse(configurationId), scriptId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("scripts/{configurationId}/setlanguages/{scriptId}/{twoLetterlanguageCodes?}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SetForcedLanguage(string configurationId, int scriptId, string? twoLetterlanguageCodes = "")
        {
            try
            {
                return Ok(await _scriptConfigurationService.SetForcedLanguage(Int32.Parse(configurationId), scriptId, twoLetterlanguageCodes));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("scripts/{configurationId}/addscript/{scriptName}/{scriptID}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<ScriptItemCreationResult>> SaveScript(string configurationId, string scriptName, int scriptID)
        {
            try
            {
                return Ok(await _scriptConfigurationService.SaveScript(Int32.Parse(configurationId), scriptName, scriptID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/getscriptitems/{scriptId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ScriptItemDisplay>>> GetScriptItemsByScript(int configurationId, int scriptId)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetScriptItemsByScript(scriptId, configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/getscriptItemdetails/{scriptId}/{index}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<ScriptItem>> GetScriptItemDetails(int configurationId, int scriptId,int index)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetScriptItemDetails(scriptId,index, configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("scripts/{configurationId}/removeitem/{scriptId}/{index}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveScriptItem(int configurationId, int scriptId, int index)
        {
            try
            {
                return Ok(await _scriptConfigurationService.RemoveScriptItem(index, scriptId, configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("scripts/{configurationId}/saveitem")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<ScriptItemCreationResult>> SaveScriptItem(int configurationId, ScriptItem scriptItem)
        {
            try
            {
                return Ok(await _scriptConfigurationService.SaveScriptItem(scriptItem,Convert.ToInt32(scriptItem.ScriptId), configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/getitems")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ScriptItemType>>> GetScriptItemTypes(int configurationId)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetScriptItemTypes(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/triggers")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<string>>> GetTriggers(int configurationId)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetTriggers(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/overridelanguages")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ScriptForcedLanguage>>> GetLanguagesOverride(int configurationId)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetLanguagesOverride(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/flightinfo/{scriptId}/{index}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ScriptConfigFlightInfo>>> GetFlightInfoView(int configurationId, int scriptId, int index)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetFlightInfoView(configurationId, scriptId, index));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/flightinfo/params/{scriptId}/{index}/{viewName}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ScriptConfigFlightInfoParams>>> GetFlightInfoViewParameters(int configurationId, int scriptId, int index, string viewName)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetFlightInfoViewParameters(configurationId, scriptId, index,viewName));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("scripts/{configurationId}/flightinfo/availableparams/{scriptId}/{index}/{viewName}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ScriptConfigFlightInfoParams>>> GetAvailableInfoParameters(int configurationId, int scriptId, int index, string viewName)
        {
            try
            {
                return Ok(await _scriptConfigurationService.GetAvailableInfoParameters(configurationId, scriptId, index,viewName));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("scripts/{configurationId}/flightinfo/addparams/{scriptId}/{index}/{infoName}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> FlightInfoViewUpdateParameters(int configurationId, int scriptId, int index, string infoName, [FromBody] string selectedParameters)
        {
            try
            {
                return Ok(await _scriptConfigurationService.FlightInfoViewUpdateParameters(configurationId, scriptId, index, infoName, selectedParameters=="NA"?"":selectedParameters));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("scripts/{configurationId}/flightinfo/addview/{InfoName}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> FlightInfoAddView(int configurationId, string infoName)
        {
            try
            {
                return Ok(await _scriptConfigurationService.FlightInfoAddView(configurationId, infoName));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("scripts/{configurationId}/flightinfo/setView/{scriptId}/{index}/{selectedInfo}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SetFlightInfoViewForItem(int configurationId, int scriptId, int index, string selectedInfo)
        {
            try
            {
                return Ok(await _scriptConfigurationService.SetFlightInfoViewForItem(configurationId, scriptId, index, selectedInfo));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }

        }

        [HttpPost]
        [Route("scripts/{configurationId}/moveitemposition/{scriptId}/{currentPoistion}/{toPosition}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ScriptItemDisplay>>> MoveItemToPosition(int configurationId, int scriptId, int currentPoistion, int toPosition)
        {
            try
            {
                return Ok(await _scriptConfigurationService.MoveItemToPosition(configurationId, scriptId, currentPoistion, toPosition));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }

        }
    }
}
