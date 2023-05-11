using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

namespace backend.Helpers.Fleet
{
    public class FleetConfiguration
    {

        public static readonly FleetConfigurationSection Instance = (FleetConfigurationSection) ConfigurationManager.GetSection("FleetConfiguration");
    
    }
}
