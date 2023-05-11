using backend.DataLayer.Authentication;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Authorization
{
    /**
     * Represents an individual claim requirement that is validated against
     **/
    public class PortalClaimRequirement: IAuthorizationRequirement
    {
        public PortalClaim Claim;

        public PortalClaimRequirement(string context, string role, string claimType)
        {
            Claim = new PortalClaim(claimType, context, role);
        }

        public PortalClaimRequirement(string claimType, string context)
        {
            Claim = new PortalClaim(claimType, context, null);
        }

        public PortalClaimRequirement(string claimType)
        {
            Claim = new PortalClaim(claimType, null, null);
        }
    }
}

