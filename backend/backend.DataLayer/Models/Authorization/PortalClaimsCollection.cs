using backend.DataLayer.Authentication;
using System;
using System.Collections.Generic;

namespace backend.DataLayer.Models.Authorization
{
    /**
     * Class that encapsulates claims retrieved from a JWT token. This class
     * indexes the claims based on their type to facilitate quick checks against
     * individual claim types.
     **/
    public class PortalClaimsCollection : Dictionary<string, List<PortalClaim>>
    {

        public PortalClaimsCollection() { }

        public PortalClaimsCollection(PortalJWTPayload token)
        {
            FromToken(token);
        }

        public void AddClaim(PortalClaim claim)
        {
            if (!ContainsKey(claim.RoleName)) Add(claim.RoleName, new List<PortalClaim>());

            this[claim.RoleName].Add(claim);
        }

        public bool HasClaim(string right, string scope = null)
        {
            if (!ContainsKey(right)) return false;

            foreach (var claim in this[right])
            {
                if (claim.ContextName == scope || String.IsNullOrEmpty(claim.ContextName))
                    return true;
            }

            return false;
        }

        public bool HasInstanceOfClaim(string right)
        {
            return ContainsKey(right);
        }

        public void FromToken(PortalJWTPayload token)
        {
            foreach (var claim in token.Claims)
            {
                AddClaim(claim);
            }
        }
    }
}
