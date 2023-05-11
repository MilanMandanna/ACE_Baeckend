﻿using backend.BusinessLayer.Authorization;
using backend.DataLayer.Authentication;
using backend.Helpers.Portal;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Authentication
{
    /**
     * Class that intercepts events generated by the JWT authentication system.
     * Primarily this is used to decode the JWT token into a friendlier to use
     * format for the rest of the application
     **/
    public class PortalJwtBearerEvents : JwtBearerEvents
    {
        private byte[] _key = null;

        public PortalJwtBearerEvents(string TokenSecret)
        {
            _key = Convert.FromBase64String(TokenSecret);
        }

        public override Task AuthenticationFailed(AuthenticationFailedContext context)
        {
            return base.AuthenticationFailed(context);
        }

        public override Task Challenge(JwtBearerChallengeContext context)
        {
            return base.Challenge(context);
        }

        public override Task Forbidden(ForbiddenContext context)
        {
            return base.Forbidden(context);
        }

        public override Task MessageReceived(MessageReceivedContext context)
        {
            return base.MessageReceived(context);
        }

        /**
         * Make the token available on the http context for the request. This lets the token
         * be used in downstream processes (e.g. authorization). At this point the authentication
         * middleware has already processed and validated the token so we don't
         * need to check anything else here.
         **/
        public override Task TokenValidated(TokenValidatedContext context)
        {
            context.HttpContext.Request.Headers.TryGetValue("Authorization", out var authorizationHeader);
            string header = authorizationHeader.DefaultIfEmpty(null).FirstOrDefault();
            string json = Jose.JWT.Decode(header.Split(' ')[1], _key);
            PortalJWTPayload payload = JsonConvert.DeserializeObject<PortalJWTPayload>(json);


            //payload.Claims.Add(new PortalClaim(PortalClaimType.ManageAccounts));
            //payload.Claims.Add(new PortalClaim(PortalClaimType.ManageOperator));
            //payload.Claims.Add(new PortalClaim(PortalClaimType.ManageOperator, "1"));
            //payload.Claims.Add(new PortalClaim(PortalClaimType.ViewOperator));
            //payload.Claims.Add(new PortalClaim(PortalClaimType.ManageAircraft));
            //payload.Claims.Add(new PortalClaim(PortalClaimType.ManageSiteSettings, PortalClaimScopeType.Airshow));

            context.HttpContext.Items["JWTPayload"] = payload;

            return base.TokenValidated(context);
        }
    }
}