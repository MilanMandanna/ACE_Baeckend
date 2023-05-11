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
    public class RegionController : PortalController
    {
        private IRegionService _regionService;
        private ILoggerManager _logger;

        public RegionController(IRegionService regionService, ILoggerManager logger)
        {
            _regionService = regionService;
            _logger = logger;
        }

        [HttpGet]
        [Route("{configurationId}/all")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<Region>>> GetAllRegions(string configurationId)
        {
            try
            {
                return Ok(await _regionService.GetAllRegions(Int32.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("{configurationId}/details/{regionId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<RegionInfo>> GetRegionInfo(string configurationId, string regionId)
        {
            try
            {
                return Ok(await _regionService.GetRegionInfo(Int32.Parse(configurationId), Int32.Parse(regionId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }


        [HttpPost]
        [Route("{configurationId}/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> Add(string configurationId, [FromBody] RegionInfo regionInfo)
        {
            try
            {
                return Ok(await _regionService.AddRegion(Int32.Parse(configurationId), regionInfo));

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
        public async Task<ActionResult<DataCreationResultDTO>> Update(string configurationId, [FromBody] RegionInfo regionInfo)
        {
            try
            {
                return Ok(await _regionService.UpdateRegion(Int32.Parse(configurationId), regionInfo));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
    }
   
}
