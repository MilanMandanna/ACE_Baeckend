using backend.DataLayer.Authentication;
using backend.DataLayer.Models.Authorization;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Helpers
{
    public class ClaimsHelper
    {
        /**
         * Validates if a rights collection has the right level of read/write or read priveleges for the provided scope.
         * This can be used for cases where the scope is either a specific instance or all (if no scope is defined). The presence of the read/write right will
         * also validate against a read only right
         **/
        public static bool ValidateRightScoped(PortalClaimsCollection rights, string againstScope, string readWriteRight, string readRight, bool requireReadWrite)
        {
            if (rights.HasClaim(readWriteRight, againstScope) || rights.HasClaim(readWriteRight)) return true;
            if (!requireReadWrite && (rights.HasClaim(readRight, againstScope) || rights.HasClaim(readRight))) return true;
            return false;
        }

        public static bool Satisfies(PortalClaim claim, PortalClaim requirement)
        {
            if (claim.RoleName != requirement.RoleName) return false;
            if (String.IsNullOrEmpty(claim.ContextName)) return true;
            return claim.ContextName == requirement.ContextName;
        }
    }
}
