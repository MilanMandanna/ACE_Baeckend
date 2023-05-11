using backend.Helpers.Portal;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Threading.Tasks;
using backend.Helpers;

namespace backend.BusinessLayer.Authentication
{
    /**
     * Class that encapsulates the jwt authentication options used. For development purposes the token lifetime
     * validation can be disabled via configuration.
     **/
    public class PortalJwtBearerOptions
    {
        public static void Configure(JwtBearerOptions options, Helpers.Configuration _configuration)
        {
            byte[] key = Convert.FromBase64String(_configuration.TokenSecret);

            options.SaveToken = true;
            //options.EventsType = typeof(PortalJwtBearerEvents);
            options.Events = new PortalJwtBearerEvents(_configuration.TokenSecret);

            options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters()
            {
                ValidateAudience = true,
                ValidateIssuer = true,
                ValidateLifetime = Boolean.Parse(_configuration.TokenValidateLifetime),
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidIssuer = _configuration.TokenIssuer,
                ValidAudience = _configuration.TokenAudience
            };
        }

    }
}
