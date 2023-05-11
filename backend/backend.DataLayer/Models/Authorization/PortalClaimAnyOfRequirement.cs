using backend.DataLayer.Authentication;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Authorization
{
    public class PortalClaimAnyOfRequirement : IAuthorizationRequirement
    {
        public List<PortalClaim> Claims;

        public PortalClaimAnyOfRequirement(PortalClaim[] claims)
        {
            Claims = new List<PortalClaim>();
            for (int i = 0; i < claims.Length; ++i)
            {
                Claims.Add(claims[i]);
            }
        }
    }
}
