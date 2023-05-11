using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Authorization
{
    /**
     * Test: not fully implemented yet
     **/
    public class PortalHttpParameterRequirement : IAuthorizationRequirement
    {
        public string[] HttpParameterNames = null;

        public PortalHttpParameterRequirement(string[] httpParameterNames)
        {
            HttpParameterNames = httpParameterNames;
        }
    }
}
