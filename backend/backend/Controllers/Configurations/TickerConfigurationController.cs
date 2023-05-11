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
    * Controller dedicated to handling high-level tasks associated with Ticker configurations,
    */
    [Route("api/[controller]")]
    [ApiController]
    public class TickerConfigurationController :PortalController
    {
        private ITickerConfigurationService _tickerConfigurationService;
        private ILoggerManager _logger;

        public TickerConfigurationController(ITickerConfigurationService tickerConfigurationService, ILoggerManager logger)
        {
            _tickerConfigurationService = tickerConfigurationService;
            _logger = logger;
        }


        [HttpGet]
        [Route("{configurationId}/ticker")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<Dictionary<string, object>>> GetTicker(string configurationId)
        {
            try
            {
                return Ok(await _tickerConfigurationService.GetTicker(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/ticker/{name}/set/{value}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateTicker(string configurationId, string name, string value)
        {
            try
            {
                return Ok(await _tickerConfigurationService.UpdateTicker(Int32.Parse(configurationId), name, value));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("{configurationId}/ticker/parameters/selected")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<TickerParameter>>> GetSelectedTickerParameters(string configurationId)
        {
            try
            {
                return Ok(await _tickerConfigurationService.GetSelectedTickerParameters(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }


        [HttpGet]
        [Route("{configurationId}/ticker/parameters/all")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<TickerParameter>>> GetAllTickerParameters(string configurationId)
        {
            try
            {
                return Ok(await _tickerConfigurationService.GetAllTickerParameters(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/ticker/parameters/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]

        public async Task<ActionResult<DataCreationResultDTO>> AddTickerParameter(string configurationId,[FromBody] TickerParameter[] tickerData)
        {
            try
            {
                return Ok(await _tickerConfigurationService.AddTickerParameter(Int32.Parse(configurationId), tickerData));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
        
        [HttpPost]
        [Route("{configurationId}/ticker/parameters/remove/{position}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveTickerParameter(string configurationId, string position)
        {
            try
            {
                return Ok(await _tickerConfigurationService.RemoveTickerParameter(Int32.Parse(configurationId), Int32.Parse(position)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/ticker/parameters/move/{fromPosition}/to/{toPosition}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> MoveTickerParameterPosition(string configurationId, string fromPosition, string toPosition)
        {
            try
            {
                return Ok(await _tickerConfigurationService.MoveTickerParameterPosition(Int32.Parse(configurationId), Int32.Parse(fromPosition), Int32.Parse(toPosition)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
    }
}
