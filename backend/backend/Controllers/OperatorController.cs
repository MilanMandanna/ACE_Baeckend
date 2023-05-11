using AutoMapper;
using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OperatorController : PortalController
    {
        private readonly IOperatorService _operatorService;
        private readonly ILoggerManager _logger;
        public OperatorController(IOperatorService operatorService, ILoggerManager logger)
        {
            _operatorService = operatorService;
            _logger = logger;
        }

        [HttpGet]
        [Authorize]
        [Route("all")]
        public async Task<ActionResult<IEnumerable<OperatorListDTO>>> GetAllOperators()
        {
            try
            {
                return Ok(await _operatorService.FindAllOperators());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        [HttpGet]
        [Authorize]
        [Route("{operatorId}")]
        public async Task<ActionResult<IEnumerable<OperatorListDTO>>> GetOperatorById(string operatorId)
        {
            try
            {
                Guid operatorID = Guid.Parse(operatorId);
                return Ok(await _operatorService.FindOperatorById(operatorID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }

        /**
       * Test function that indicates if the current user can view operators. This for example
       * could be used to indicate if the user settings page shows the "operators" selection. A final form
       * might combine this check with several other checks so that only one api call has to be made
       **/
        [HttpGet]
        [Route("canview")]
        [Authorize]
        public ActionResult CanView()
        {
            // forbidden if there is no user (which really shouldn't happen at this level), 
            // 1 if there is at least one manage operator right, 0 if none
            if (!IsAuthenticated())
                return new UnauthorizedResult();
            if (HasInstanceOfClaim(PortalClaimType.ViewOperator))
                return new JsonResult(1);
            return new JsonResult(0);
        }

        /**
         * Test function that indicates if the current user can manage operators. This for example
         * could be used to indicate if the user settings page shows the "operators" selection. A final form
         * might combine this check with several other checks so that only one api call has to be made
         **/
        [HttpGet]
        [Route("canmanage")]
        [Authorize]
        public ActionResult CanManage()
        {
            // forbidden if there is no user (which really shouldn't happen at this level), 
            // 1 if there is at least one manage operator right, 0 if none
            if (!IsAuthenticated())
                return new UnauthorizedResult();
            if (HasInstanceOfClaim(PortalClaimType.ManageOperator))
                return new JsonResult(1);
            return new JsonResult(0);
        }

        /**
         * Endpoint to update the name of an operator
         **/
        [HttpPost]
        [Route("update/{operatorId}/name/{name}")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateOperator(string operatorId, string name)
        {
            try
            {
                return Ok(await _operatorService.UpdateOperator(operatorId, name));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        /**
         * Endpoint to add a new operator
         **/
        [HttpPost]
        [Route("add/{name}")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> AddOperator(string name)
        {
            try
            {
                return Ok(await _operatorService.AddOperator(name, GetCurrentUser()));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        /**
         * Endpoint to flag an operator as deleted
        **/
        [HttpPost]
        [Route("delete/{operatorId}")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteOperator(string operatorId)
        {
            try
            {
                return Ok(await _operatorService.DeleteOperator(operatorId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("manage/{roleId}")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<OperatorDTO>>> GetOperatorsByRights(string roleId)
        {
            try
            {
                Guid roleID = Guid.Parse(roleId);
                return Ok(await _operatorService.GetOperatorsByUserRights(roleID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }
        [HttpGet]
        [Route("{operatorId}/users")]
        [Authorize(Policy = PortalPolicy.ManageOperator)]
        public async Task<ActionResult<IEnumerable<UserListDTO>>> GetUsersByOperatorRights(string operatorId)
        {
            try
            {
                Guid operatorID = Guid.Parse(operatorId);
                return Ok(await _operatorService.GetUsersByOperatorRights(operatorID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }
        [HttpPost]
        [Route("{operatorId}/users/{userId}/add/rights/{claimId}")]
        [Authorize(Policy = PortalPolicy.ManageOperator)]
        public async Task<ActionResult<IEnumerable<DataCreationResultDTO>>> AddUserToOperatorGroup(string operatorId, string userId, string claimId)
        {
            try
            {
                Guid operatorID = Guid.Parse(operatorId);
                Guid userID = Guid.Parse(userId);
                Guid claimID = Guid.Parse(claimId);
                return Ok(await _operatorService.AddUserToOperatorGroup(operatorID, userID, claimID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }
        [HttpPost]
        [Route("{operatorId}/users/{userId}/remove")]
        [Authorize(Policy = PortalPolicy.ManageOperator)]
        public async Task<ActionResult<IEnumerable<DataCreationResultDTO>>> RemoveUserFromOperatorGroup(string operatorId, string userId)
        {
            try
            {
                Guid operatorID = Guid.Parse(operatorId);
                Guid userID = Guid.Parse(userId);
                return Ok(await _operatorService.RemoveUserFromOperatorGroup(operatorID, userID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }
        [HttpPost]
        [Route("{operatorId}/users/{userId}/update/{claimId}")]
        [Authorize(Policy = PortalPolicy.ManageOperator)]
        public async Task<ActionResult<IEnumerable<DataCreationResultDTO>>> UpdateUsersOperatorGroup(string operatorId, string userId, string claimId)
        {
            try
            {
                Guid operatorID = Guid.Parse(operatorId);
                Guid userID = Guid.Parse(userId);
                Guid claimID = Guid.Parse(claimId);
                return Ok(await _operatorService.UpdateUserRightsToManageOrViewOperator(operatorID, userID, claimID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }
    }
}
