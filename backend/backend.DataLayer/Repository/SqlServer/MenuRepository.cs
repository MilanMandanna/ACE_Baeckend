using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using Newtonsoft.Json;

namespace backend.DataLayer.Repository.SqlServer
{
    public class MenuRepository : Repository, IMenuRepository
    {
        public MenuRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public MenuRepository()
        {
        }

        public async Task<List<UserMenu>> GetMenusByUserId(Guid userId)
        {
            List<UserMenu> menus = new List<UserMenu>();
            var command = CreateCommand("[dbo].[SP_GetMenus_UserId]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@userId", userId);
            command.CommandTimeout = 0;
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    UserMenu menu = new UserMenu();
                    menu.MenuId = DbHelper.DBValueToInt(reader["MenuId"]);
                    menu.MenuName = DbHelper.StringFromDb(reader["MenuName"]);
                    menu.Description = DbHelper.StringFromDb(reader["Description"]);
                    menu.ParentMenuId = DbHelper.DBValueToInt(reader["ParentMenuId"]);
                    menu.MenuClass = DbHelper.StringFromDb(reader["MenuClass"]);
                    menu.MinimizedMenuClass = DbHelper.StringFromDb(reader["MinimizedMenuClass"]);
                    menu.RouteURL = DbHelper.StringFromDb(reader["RouteURL"]);
                    menu.IsConfigIdRequired = DbHelper.BoolFromDb(reader["IsConfigIdRequired"]);
                    menu.isEnabled = DbHelper.BoolFromDb(reader["isEnabled"]);
                    menu.AccessLevel = DbHelper.DBValueToInt(reader["Accesslevel"]);
                    menus.Add(menu);
                }
            }
            List<UserMenu> menuHierarchy = new List<UserMenu>();
            if (menus.Count > 0)
            {                
                menuHierarchy = menus
                                .Where(c => c.ParentMenuId == 0)
                                .Select(c => new UserMenu()
                                {
                                    MenuId = c.MenuId,
                                    MenuName = c.MenuName,
                                    Description = c.Description,
                                    ParentMenuId = c.ParentMenuId,
                                    MenuClass = c.MenuClass,
                                    MinimizedMenuClass = c.MinimizedMenuClass,
                                    RouteURL = c.RouteURL,
                                    IsConfigIdRequired = c.IsConfigIdRequired,
                                    isEnabled = c.isEnabled,
                                    AccessLevel = c.AccessLevel,
                                    HasSubMenu = menus.Where(s => s.ParentMenuId == c.MenuId).Count() > 0,
                                    SubMenu = GetSubMenu(menus, c.MenuId)
                                })
                                .ToList();
            }
            string message = JsonConvert.SerializeObject(menuHierarchy);
            return menuHierarchy;
        }
        public List<UserMenu> GetSubMenu(List<UserMenu> menus, int parentId)
        {
            return menus
                    .Where(c => c.ParentMenuId == parentId)
                    .Select(c => new UserMenu
                    {
                        MenuId = c.MenuId,
                        MenuName = c.MenuName,
                        Description = c.Description,
                        ParentMenuId = c.ParentMenuId,
                        MenuClass = c.MenuClass,
                        MinimizedMenuClass = c.MinimizedMenuClass,
                        RouteURL = c.RouteURL,
                        IsConfigIdRequired = c.IsConfigIdRequired,
                        isEnabled = c.isEnabled,
                        AccessLevel = c.AccessLevel,
                        HasSubMenu = menus.Where(s => s.ParentMenuId == c.MenuId).Count() > 0,
                        SubMenu = GetSubMenu(menus, c.MenuId) 
                    })
                    .ToList();
        }
    }
}
