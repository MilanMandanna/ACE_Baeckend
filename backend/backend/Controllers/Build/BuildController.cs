using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Build;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.Controllers.Build
{
    [Route("api/build")]
    [ApiController]
    public class BuildController : PortalController
    {
        private IBuildService _buildService;
        private ILoggerManager _logger;

        public BuildController(IBuildService buildService, ILoggerManager logger)
        {
            _buildService = buildService;
            _logger = logger;
        }

        [HttpGet]
        [Route("{taskId}/errorlog")]
        [Authorize]
        public async Task<ActionResult<string>> GetErrorLog(string taskId)
        {
            try
            {
                return Ok(await _buildService.GetErrorLog(taskId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{taskId}/cancel")]
        [Authorize]
        public async Task<ActionResult<DataCreationResultDTO>> CancelBuild(string taskId)
        {
            try
            {
                return Ok(await _buildService.CancelBuild(taskId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{taskId}/delete")]
        [Authorize]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteBuild(string taskId)
        {
            try
            {
                return Ok(await _buildService.DeleteBuild(taskId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("buildprogress")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<BuildProgress>>> GetBuildProgress([FromBody] string[] taskIds)
        {
            try
            {
                return Ok(await _buildService.BuildProgress(taskIds));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{pageName}/{configurationId}/activeimport")]
        public async Task<ActionResult<BuildProgress>> GetActiveImportStatus(string pageName, string configurationId)
        {
            try
            {
                return Ok(await _buildService.GetActiveImportStatus(pageName, configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed:" + ex);
                return NoContent();
            }
        }
    }
}
