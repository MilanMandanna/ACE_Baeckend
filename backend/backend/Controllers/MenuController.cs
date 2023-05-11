using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models;
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
    public class MenuController : PortalController
    {
        private readonly IMenuService _menuService;
        private readonly ILoggerManager _logger;

        public MenuController(IMenuService menuService, ILoggerManager logger)
        {
            _menuService = menuService;
            _logger = logger;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Route("menus")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<UserMenu>>> GetMenus()
        {
            try
            {
                //Guid userID = Guid.Parse(userId);
                return Ok(await _menuService.GetMenusByUserId(GetCurrentUser().Id));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }        
    }
}
