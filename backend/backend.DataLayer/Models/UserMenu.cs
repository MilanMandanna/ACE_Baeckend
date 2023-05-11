using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Authorization;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models
{
    public class UserMenu
    {
        public int MenuId { get; set; }
		public string MenuName { get; set; }
		public string Description { get; set; }
		public string MenuClass { get; set; }
		public string MinimizedMenuClass { get; set; }
		public int ParentMenuId { get; set; }
		public bool HasSubMenu { get; set; }
		public string RouteURL { get; set; }
		public bool IsConfigIdRequired { get; set; }
		public bool isEnabled { get; set; }
		public int AccessLevel { get; set; }
		public List<UserMenu> SubMenu { get; set; }
	}
}
