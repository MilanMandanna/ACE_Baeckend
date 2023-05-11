using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Authorization
{
    /**
     * Authorization requirement that can be used to restrict editing to an aircraft based off claims
     **/ 
    public class PortalEditAircraftRequirement : IAuthorizationRequirement
    {
        public bool RequiresReadWrite { get; }

        public PortalEditAircraftRequirement(bool requiresReadWrite)
        {
            RequiresReadWrite = requiresReadWrite;
        }

    }
}
