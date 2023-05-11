using backend.BusinessLayer.Contracts;
using backend.Logging.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.Controllers.Build
{
    [Route("api/export")]
    [ApiController]
    public class ExportController : PortalController
    {
        private IExportService _exportService;
        private ILoggerManager _logger;

        public ExportController(IExportService exportService, ILoggerManager logger)
        {
            _exportService = exportService;
            _logger = logger;
        }

        [HttpGet]
        [Route("configuration/{configurationId:int}/development")]
        [Authorize]
        public async Task<ActionResult> ExportDevelopmentConfiguration(int configurationId)
        {
            try
            {
                return Ok(await _exportService.ExportDevelopmentConfig(configurationId, GetCurrentUser()));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("configuration/{configurationId:int}/downloadproduct")]
        [Authorize]
        public async Task<ActionResult> DownloadProduct(int configurationId)
        {
            try
            {
                return await _exportService.DownloadProduct(configurationId, GetCurrentUser());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("definition/{configurationDefinitionId:int}/downloadproduct")]
        [Authorize]
        public async Task<ActionResult> DownloadLatestProduct(int configurationDefinitionId)
        {
            try
            {
                return await _exportService.DownloadProductByDefinition(configurationDefinitionId, GetCurrentUser());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }
    }
}
