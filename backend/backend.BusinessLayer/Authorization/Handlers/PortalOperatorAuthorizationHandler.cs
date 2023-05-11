using backend.BusinessLayer.Contracts;
using backend.DataLayer.Authentication;
using backend.DataLayer.Authorization;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Authorization;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Authorization
{
    /**
     * Authorization handler that is responsible for validating operator requirements.
     * This handler checks if the operator specified in the route is accessible by the current user rights and will validate
     * the requirement if they have the correct rights in place.
     **/
    public class PortalOperatorAuthorizationHandler : AuthorizationHandler<PortalOperatorRequirement>
    {
        private IHttpContextAccessor _httpContextAccessor;
        private IUserService _userService;
        private ILoggerManager _logger;

        public PortalOperatorAuthorizationHandler(IHttpContextAccessor httpContextAccessor, IUserService userService, ILoggerManager logger)
        {
            _httpContextAccessor = httpContextAccessor;
            _userService = userService;
            _logger = logger;
        }

        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, PortalOperatorRequirement requirement)
        {
            HttpContext httpContext = _httpContextAccessor.HttpContext;
            httpContext.Items.TryGetValue("JWTPayload", out var payload);
            PortalJWTPayload jwtPayload = payload as PortalJWTPayload;
            if (jwtPayload == null) return Task.CompletedTask;

            RouteData routeData = httpContext.GetRouteData();
            var user = _userService.GetUser(jwtPayload.UserName);
            string operatorId = HttpHelper.FindRouteParameter(routeData, requirement.HttpParameterNames);

            if (operatorId == null)
            {
                _logger.LogError($"Failed to find operator id in request");
                return Task.CompletedTask;
            }

            PortalClaimsCollection claims = new PortalClaimsCollection(jwtPayload);
            bool canAccess = ClaimsHelper.ValidateRightScoped(claims, operatorId, PortalClaimType.ManageOperator, PortalClaimType.ViewOperator, requirement.RequireManage);
            if (canAccess)
                context.Succeed(requirement);

            return Task.CompletedTask;
        }
    }
}
