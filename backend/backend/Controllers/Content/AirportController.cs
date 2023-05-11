using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts.CustomContent;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers.Content
{
    /**
    Controller for handling all the api related to airport .
   **/
    [Route("api/[controller]")]
    [ApiController]
    public class AirportController: PortalController
    {
        private IAirportService _airportService;
        private ILoggerManager _logger;

        public AirportController(IAirportService airportService, ILoggerManager logger)
        {
            _airportService = airportService;
            _logger = logger;
        }

        [HttpGet]
        [Route("{configurationId}/airports/all")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<Airport>>> GetAllAirports(string configurationId)
        {
            try
            {
                return Ok(await _airportService.getAllAirports(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/airport/update")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> Update(string configurationId, [FromBody] Airport airportInfo)
        {
            try
            {
                return Ok(await _airportService.UpdateAirport(Int32.Parse(configurationId),airportInfo,GetCurrentUser().Id));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/airport/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> Add(string configurationId, [FromBody] Airport airportInfo)
        {
            try
            {
                return Ok(await _airportService.AddAirport(Int32.Parse(configurationId), airportInfo));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("{configurationId}/airport/cities/all")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<CityInfo>>> GetAllCities(string configurationId)
        {
            try
            {
                return Ok(await _airportService.GetAllCities(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }


    }
}
