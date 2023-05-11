using backend.BusinessLayer.Contracts;
using backend.DataLayer.Authentication;
using backend.DataLayer.Models.Authorization;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Authorization
{
    /**
     * This middleware simply checks if a authorization token is attached to the http context and if it is
     * then a user is looked up based on that token and attached to the http context.
     **/
    public class PortalAuthorizationMiddleware
    {
        private readonly RequestDelegate _next;
        private IUserService _userService;

        public PortalAuthorizationMiddleware(RequestDelegate next, IUserService userService)
        {
            _next = next;
            _userService = userService;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            context.Items.TryGetValue("JWTPayload", out var payload);
            if (payload != null)
            {
                PortalJWTPayload jwtPayload = payload as PortalJWTPayload;
                if (jwtPayload != null)
                {
                    var user = await _userService.GetUser(jwtPayload.UserName);

                    // populate the claims on the user
                    PortalClaimsCollection claims = new PortalClaimsCollection(jwtPayload);
                    user.Claims = claims;

                    context.Items["InternalUser"] = user;
                }
            }
            await _next(context);
        }

    }
}
