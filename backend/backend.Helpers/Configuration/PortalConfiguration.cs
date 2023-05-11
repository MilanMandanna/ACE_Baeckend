using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

namespace backend.Helpers.Portal
{
    public class PortalConfiguration
    {
        public static readonly PortalConfigurationSection Instance = (PortalConfigurationSection) ConfigurationManager.GetSection("PortalConfiguration");
    }
}
