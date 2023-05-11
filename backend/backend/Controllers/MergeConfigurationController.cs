using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.MergeConfiguration;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MergeConfigurationController : PortalController
    {
        private readonly IMergeConfigurationService _mergeConfigurationService;
        private readonly ILoggerManager _logger;
        public MergeConfigurationController(IMergeConfigurationService mergeConfigurationService,ILoggerManager logger)
        {
            _mergeConfigurationService = mergeConfigurationService;
            _logger = logger;
        }
        [HttpGet]
        [Route("{definitionId}/{configurationId}/updatesavailable")]
        [Authorize]
        public async Task<ActionResult<MergeConfigurationAvailable>> CheckUpdatesAvailable(string definitionId, string configurationId)
        {
            try
            {
                return Ok(await _mergeConfigurationService.CheckUpdatesAvailable(int.Parse(definitionId), int.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationId}/{configurationIds}/DownloadVersionUpdatesReport")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult> DownloadVersionUpdatesReport(string configurationId, string configurationIds)
        {
            try
            {
                return await _mergeConfigurationService.DownloadVersionUpdatesReport(int.Parse(configurationId), configurationIds.Split(",").ToList());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        /// <summary>
        /// Method to get all the versions which are available for update.
        /// </summary>
        /// <param name="configurationDefinitionID"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationDefinitionID}")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<List<MergeConfigurationUpdateDetails>>> GetMergeConfigurationUpdateDetails(string configurationDefinitionID)
        {
            try
            {
                return Ok(await _mergeConfigurationService.GetMergeConfigurationUpdateDetails(int.Parse(configurationDefinitionID)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// Method to update data in tasks table
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("{childConfigurationId}/{parentConfigurationIds}/UpdateTaskDetails")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateMergeTaskDetails(string childConfigurationId, string parentConfigurationIds)
        {
            try
            {
                UserListDTO user = GetCurrentUser();
                return Ok(await _mergeConfigurationService.UpdateMergeTaskDetails(int.Parse(childConfigurationId), parentConfigurationIds, user));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("{configurationId}/TaskData")]
        [Authorize(Policy =PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<List<MergeTaskInfo>>> GetMergeConfigurationTaskData(string configurationId)
        {
            try
            {
                return Ok(await _mergeConfigurationService.GetMergeConfigurationTaskData(int.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed " + ex);
                return NotFound();
            }
        }
		
		/// <summary>
        /// Method to get conflicts data
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/{taskId}/GetMergeConficts")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<List<MergeConflictData>>> GetMergeConflicts(string configurationId, string taskId)
        {
            try
            {
                UserListDTO user = GetCurrentUser();
                Guid taskid = Guid.Parse(taskId);
                return Ok(await _mergeConfigurationService.GetMergeConflictData(int.Parse(configurationId), taskid, user));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// Method to update selection in mergedetails table
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/{taskId}/{conflictIds}/{buildSelection}/UpdateMergeConflictSelection")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateMergeConflictSelection(string configurationId, string taskId, string conflictIds, MergeBuildType buildSelection)
        {
            try
            {
                UserListDTO user = GetCurrentUser();
                Guid taskid = Guid.Parse(taskId);
                return Ok(await _mergeConfigurationService.UpdateMergeConflictSelection(int.Parse(configurationId), taskid, conflictIds, buildSelection, user));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// Method to update selection in mergedetails table
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/{taskId}/ResolveConflicts")]
        [Authorize(Policy = PortalPolicy.ManageGlobalConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> ResolveConflicts(string configurationId, string taskId, [FromBody] List<MergeConflictData> mergData)
        {
            try
            {
                UserListDTO user = GetCurrentUser();
                Guid taskid = Guid.Parse(taskId);
                return Ok(await _mergeConfigurationService.ResolveConflicts(int.Parse(configurationId), taskid, mergData, user));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed " + ex);
                return NotFound();
            }
        }
    }
}
