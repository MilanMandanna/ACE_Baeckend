using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Roles_Claims;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Manage;
using backend.Mappers.DataTransferObjects.Task;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Build;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : PortalController
    {
        private readonly IUserService _userService;
        private readonly ILoggerManager _logger;

        public UserController(IUserService userService, ILoggerManager logger)
        {
            _userService = userService;
            _logger = logger;
        }

        [HttpGet]
        [Route("all")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<IEnumerable<UserListDTO>>> GetAllUsers()
        {
            try
            {
                return Ok(await _userService.GetAllUsers());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        [HttpGet]
        [Route("{username}/details")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<UserListDTO>>> GetUser(string username)
        {
            try
            {
                return Ok(await _userService.GetUser(username));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }
        [HttpPost]
        [Route("create")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> CreateUser(FormCreateUserDTO createUserDTO)
        {
            try
            {
                return Ok(await _userService.CreateUser(createUserDTO));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{username}/remove")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveUser(string username)
        {
            try
            {
                return Ok(await _userService.RemoveUser(username));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }

        /**
     * Test function that indicates if the current user can view accounts. This for example
     * could be used to indicate if the user settings page shows the "All Users" selection. A final form
     * might combine this check with several other checks so that only one api call has to be made
     **/
        [HttpGet]
        [Route("canview")]
        //[Authorize]
        public ActionResult CanView()
        {
            // forbidden if there is no user (which really shouldn't happen at this level), 
            // 1 if there is at least one manage operator right, 0 if none
            if (!IsAuthenticated())
                return new UnauthorizedResult();
            if (HasInstanceOfClaim(PortalClaimType.ViewAccounts))
                return new JsonResult(1);
            return new JsonResult(0);
        }

        /**
         * Test function that indicates if the current user can manage accounts. This for example
         * could be used to indicate if the user settings page allows to add/delete content in the "All Users" selection. A final form
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
            if (HasInstanceOfClaim(PortalClaimType.ManageAccounts))
                return new JsonResult(1);
            return new JsonResult(0);
        }
        [HttpGet]
        [Route("{userId}/rights")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<UserClaims>>> GetClaimsByUserId(string userId)
        {
            try
            {
                Guid userID = Guid.Parse(userId);
                return Ok(await _userService.GetClaimsByUserId(userID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }
        [HttpGet]
        [Route("{userId}/roles")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<UserClaims>>> GetRolesByUserId(string userId)
        {
            try
            {
                Guid userID = Guid.Parse(userId);
                return Ok(await _userService.GetRolesByUserId(userID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }

        /**
         * Returns the services available to the user
         */
        [HttpGet]
        [Route("services")]
        [Authorize]
        public ActionResult<AvailableServicesDTO> GetServices()
        {
            try
            {
                return Ok(_userService.GetAvailableServices(this.GetToken()));
            }
            catch (Exception ex)
            {
                _logger.LogError("request failed: " + ex);
                return NotFound();
            }
        }


        /**
        * Returns the builds that are started by the user and the builds that the user has access to
        */
        [HttpGet]
        [Route("currentbuilds")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<BuildsDTO>>> GetCurrentBuilds()
        {
            try
            {
                return Ok(await _userService.GetBuildTasksByUserId(GetCurrentUser().Id, true));
            }
            catch (Exception ex)
            {
                _logger.LogError("request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("allbuilds")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<BuildsDTO>>> GetAllBuilds()
        {
            try
            {
                return Ok(await _userService.GetBuildTasksByUserId(GetCurrentUser().Id,false));
            }
            catch (Exception ex)
            {
                _logger.LogError("request failed: " + ex);
                return NotFound();
            }
        }
    }
}
