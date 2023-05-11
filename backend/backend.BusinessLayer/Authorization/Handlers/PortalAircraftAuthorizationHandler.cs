using Ace.DataLayer.Models;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Authentication;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Authorization;
using backend.Logging.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Authorization.Handlers
{
    /**
     * Class that handles aircraft related authorization requirements
     **/ 
    public class PortalAircraftAuthorizationHandler : IAuthorizationHandler
    {
        IHttpContextAccessor _httpContextAccessor;
        IOperatorService _operatorService;
        IAircraftService _aircraftService;
        ILoggerManager _logger;

        public PortalAircraftAuthorizationHandler(
            IHttpContextAccessor httpContextAccessor,
            IOperatorService operatorService,
            IAircraftService aircraftService,
            ILoggerManager logger)
        {
            _httpContextAccessor = httpContextAccessor;
            _operatorService = operatorService;
            _aircraftService = aircraftService;
            _logger = logger;
        }

        /**
         * Main authorization routine
         **/ 
        public Task HandleAsync(AuthorizationHandlerContext context)
        {
            HttpContext httpContext = _httpContextAccessor.HttpContext;
            httpContext.Items.TryGetValue("JWTPayload", out var payload);
            PortalJWTPayload jwtPayload = payload as PortalJWTPayload;
            if (jwtPayload == null) return Task.CompletedTask;

            var pendingRequirements = context.PendingRequirements.ToList();

            var aircraftId = HttpHelper.FindRouteParameter(httpContext.GetRouteData(), "tailNumber");
            if (aircraftId == null) return Task.CompletedTask;
            var aircraft = _aircraftService.FindAircraftByTailNumber(aircraftId);
            if (aircraft == null) return Task.CompletedTask;

            var claims = new PortalClaimsCollection(jwtPayload);

            foreach (var requirement in pendingRequirements)
            {
                if (requirement is PortalEditAircraftRequirement)
                {
                    if (MeetsRequirement(claims, aircraft, requirement as PortalEditAircraftRequirement))
                        context.Succeed(requirement);
                }
            }

            return Task.CompletedTask;
        }

        /**
         * Checks if an edit aircraft requirement is valid for the current user
         **/ 
        public bool MeetsRequirement(PortalClaimsCollection claims, Aircraft aircraft, PortalEditAircraftRequirement requirement)
        {
            var operatorId = aircraft.OperatorId.ToString();
            var tailNumber = aircraft.TailNumber;

            var canManage =
                (claims.HasClaim(PortalClaimType.ManageOperator, operatorId) ||
                 claims.HasClaim(PortalClaimType.ManageAircraft, tailNumber) ||
                 claims.HasClaim(PortalClaimType.AdministerOperator, operatorId) ||
                 claims.HasClaim(PortalClaimType.AdministerAircraft, tailNumber));
            if (requirement.RequiresReadWrite && canManage) return true;
            var canView = canManage || claims.HasClaim(PortalClaimType.ViewOperator, operatorId);
            if (!requirement.RequiresReadWrite && canView) return true;
            return false;
        }
    }
}
