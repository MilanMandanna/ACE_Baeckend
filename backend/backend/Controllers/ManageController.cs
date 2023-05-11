using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Roles_Claims;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Manage;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ManageController : PortalController
    {
        private readonly IManageService _manageService;
        private readonly ILoggerManager _logger;

        public ManageController(IManageService manageService, ILoggerManager logger)
        {
            _manageService = manageService;
            _logger = logger;
        }
        /// <summary>
        /// EndPoint to get all the existing roles in the system
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Route("roles/all")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<IEnumerable<AdminRoleDTO>>> GetAllRoles()
        {
            try
            {
                return Ok(await _manageService.GetAllRoles());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to get role details by role id
        /// </summary>
        /// <param name="roleId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("roles/{roleId}")]
        [Authorize]
        public async Task<ActionResult<AdminRoleDTO>> GetRoleById(string roleId)
        {
            try
            {
                Guid roleID = Guid.Parse(roleId);
                return Ok(await _manageService.GetRoleById(roleID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// Endpoint to get list of users for a role
        /// </summary>
        /// <param name="roleId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("roles/{roleId}/users")]
        [Authorize]
        public async Task<ActionResult<RoleDTO>> GetUsersByRoleId(string roleId)
        {
            try
            {
                Guid roleID = Guid.Parse(roleId);
                return Ok(await _manageService.GetUsersByRoleId(roleID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to add an user to a role
        /// </summary>
        /// <param name="roleId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("roles/{roleId}/add/user/{userId}")]
        [Authorize]
        public async Task<ActionResult<DataCreationResultDTO>> AddUserToRole(string roleId, string userId)
        {
            try
            {
                Guid roleID = Guid.Parse(roleId);
                Guid userID = Guid.Parse(userId);
                return Ok(await _manageService.AddUserToRole(roleID, userID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to remove an user from a role
        /// </summary>
        /// <param name="roleId"></param>
        /// <param name="userId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("roles/{roleId}/remove/user/{userId}")]
        [Authorize]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveUserFromRole(string roleId, string userId)
        {
            try
            {
                Guid roleID = Guid.Parse(roleId);
                Guid userID = Guid.Parse(userId);
                return Ok(await _manageService.RemoveUserFromRole(roleID, userID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to get all the associated claims for an existing role
        /// </summary>
        /// <param name="roleId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("roles/{roleId}/rights")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<ClaimsListDTO>>> GetClaimsByRoleId(string roleId)
        {
            try
            {
                Guid roleID = Guid.Parse(roleId);
                return Ok(await _manageService.GetClaimsByRoleId(roleID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to get all the existing claims in system
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Route("rights/all")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<IEnumerable<UserClaims>>> GetAllClaims()
        {
            try
            {
                return Ok(await _manageService.GetAllClaims());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to add a claim to an existing role
        /// </summary>
        /// <param name="formData"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("roles/{id}/rights/add")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> AddClaimToRoleAssignment(FormCreateClaimToRoleAssignmentDTO formData)
        {
            try
            {
                return Ok(await _manageService.AddClaimToRoleAssignment(formData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to remove claim from an existing role
        /// </summary>
        /// <param name="roleId"></param>
        /// <param name="claimId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("roles/{roleId}/rights/remove/{claimId}")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveClaimToRoleAssignment(string roleId, string claimId)
        {
            try
            {
                FormRemoveClaimToRoleAssignmentDTO formData =
                    new FormRemoveClaimToRoleAssignmentDTO { RoleID = Guid.Parse(roleId), ClaimID = Guid.Parse(claimId) };
                return Ok(await _manageService.RemoveClaimToRoleAssignment(formData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to add a new Role
        /// </summary>
        /// <param name="formData"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("roles/add")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> AddRole([FromBody] FormCreateRoleDTO formData)
        {
            try
            {
                return Ok(await _manageService.AddRole(formData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to update an existing Role
        /// </summary>
        /// <param name="roleId"></param>
        /// <param name="formData"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("roles/{roleId}/update")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateRole(string roleId, [FromBody] FormCreateRoleDTO formData)
        {
            try
            {
                Guid roleID = Guid.Parse(roleId);
                return Ok(await _manageService.UpdateRole(roleID, formData));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        /// <summary>
        /// EndPoint to delete an existing Role
        /// </summary>
        /// <param name="roleId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("roles/{roleId}/remove")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveRole(string roleId)
        {
            try
            {
                Guid roleID = Guid.Parse(roleId);
                return Ok(await _manageService.RemoveRole(roleID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
    }
}
