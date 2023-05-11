
using backend.DataLayer.Authentication;
using backend.DataLayer.Authorization;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Authorization;
using backend.Logging.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Authorization
{
    /**
     * Authorization handler that handles the generic claim requirement types. Specialized handlers are created
     * for more complex conditions. Note: not all requirement types are handled here, check the other handlers
     * for the handling of other requirement types
     **/
    public class PortalAuthorizationHandler : IAuthorizationHandler
    {
        IHttpContextAccessor _httpContextAccessor = null;
        ILoggerManager _logger;

        public PortalAuthorizationHandler(IHttpContextAccessor httpContextAccessor, ILoggerManager logger)
        {
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
        }

        public Task HandleAsync(AuthorizationHandlerContext context)
        {
            HttpContext httpContext = _httpContextAccessor.HttpContext;
            httpContext.Items.TryGetValue("JWTPayload", out var payload);
            PortalJWTPayload jwtPayload = payload as PortalJWTPayload;
            var pendingRequirements = context.PendingRequirements.ToList();

            foreach (var requirement in pendingRequirements)
            {
                if (requirement is PortalClaimRequirement)
                {
                    if (MeetsRequirement(jwtPayload, requirement as PortalClaimRequirement))
                        context.Succeed(requirement);
                }
                else if (requirement is PortalClaimAnyOfRequirement)
                {
                    if (MeetsRequirement(jwtPayload, requirement as PortalClaimAnyOfRequirement))
                        context.Succeed(requirement);
                }
            }
            return Task.CompletedTask;
        }

        private bool MeetsRequirement(PortalJWTPayload payload, PortalClaimRequirement requirement)
        {
            foreach (var claim in payload.Claims)
            {
                if ((claim.ContextName == requirement.Claim.ContextName || String.IsNullOrEmpty(requirement.Claim.ContextName)) &&
                    claim.RoleName == requirement.Claim.RoleName)
                    return true;
            }

            return false;
        }

        private bool MeetsRequirement(PortalJWTPayload payload, PortalClaimAnyOfRequirement requirement)
        {
            foreach (var claim in payload.Claims)
            {
                foreach (var requiredClaim in requirement.Claims)
                {
                    if (ClaimsHelper.Satisfies(claim, requiredClaim))
                        return true;
                }
            }

            return false;
        }
    }
}
