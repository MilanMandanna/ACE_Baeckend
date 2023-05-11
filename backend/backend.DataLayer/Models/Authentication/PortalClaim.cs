using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Authentication
{
    /**
     * Class that represents a claim received from the stage identity server.
     **/
    public class PortalClaim
    {
        [JsonConstructor]
        public PortalClaim(string roleName, string contextName, string type)
        {
            Type = type;
            ContextName = contextName;
            RoleName = roleName;
        }

        public PortalClaim(string roleName, string contextName)
        {
            RoleName = roleName;
            ContextName = contextName;
            Type = "ACE";
        }

        public PortalClaim(string roleName)
        {
            RoleName = roleName;
            Type = "ACE";
        }

        public string ContextName { get; }
        public string RoleName { get; set; }
        public string Type { get; set; }

    }
}
