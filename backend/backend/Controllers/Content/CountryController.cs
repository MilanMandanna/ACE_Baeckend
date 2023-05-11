using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts.Content;
using backend.DataLayer.Models.Configuration;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers.Content
{
    /**
    Controller for handling all the api related to country management .
    **/
    [Route("api/[controller]")]
    [ApiController]
    public class CountryController: PortalController
    {
        private ICountryService _countryService;
        private ILoggerManager _logger;

        public CountryController(ICountryService countryService, ILoggerManager logger)
        {
            _countryService = countryService;
            _logger = logger;
        }

        [HttpGet]
        [Route("{configurationId}/all")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<Country>>> GetAllCountries(string configurationId)
        {
            try
            {
                return Ok(await _countryService.GetAllCountries(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("{configurationId}/details/{countryId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<CountryInfo>> GetCountryInfo(string configurationId, string countryId)
        {
            try
            {
                return Ok(await _countryService.GetCountryInfo(Int32.Parse(configurationId), Int32.Parse(countryId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("{configurationId}/languages/selected")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<Language>>> GetSelectedLanguages(string configurationId)

        {
            try
            {
                return Ok(await _countryService.GetSelectedLanguages(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> Add(string configurationId, [FromBody] CountryInfo countryInfo)
        {
            try
            {
                return Ok(await _countryService.AddCountry(Int32.Parse(configurationId), countryInfo));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/update")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> Update(string configurationId, [FromBody] CountryInfo countryInfo)
        {
            try
            {
                return Ok(await _countryService.UpdateCountry(Int32.Parse(configurationId), countryInfo));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

    }
}
