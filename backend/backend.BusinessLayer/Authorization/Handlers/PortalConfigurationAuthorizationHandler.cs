using System;
using System.Linq;
using System.Threading.Tasks;
using Ace.DataLayer.Models;
using backend.BusinessLayer.Contracts;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Authentication;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Authorization;
using backend.DataLayer.Models.Configuration;
using backend.Logging.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace backend.BusinessLayer.Authorization.Handlers
{
    public class PortalConfigurationAuthorizationHandler : IAuthorizationHandler
    {
        IHttpContextAccessor _httpContextAccessor;
        IConfigurationService _configurationService;
        IAircraftService _aircraftService;

        ILoggerManager _logger;

        private Helpers.Configuration _configuration;

        int timerCount = 0;
        System.Threading.Timer timer;
        public PortalConfigurationAuthorizationHandler(
            IHttpContextAccessor httpContextAccessor,
            IConfigurationService configurationService,
            IAircraftService aircraftService,
            ILoggerManager logger, Helpers.Configuration configuration)
        {
            _httpContextAccessor = httpContextAccessor;
            _configurationService = configurationService;
            _aircraftService = aircraftService;
            _logger = logger;
            _configuration = configuration;

            var startTimeSpan = TimeSpan.Zero;
            var periodTimeSpan = TimeSpan.FromMinutes(_configuration.IntervalTimeForCheckQueuedLockConfig);
            _logger.LogInfo("Set the timer method " + DateTime.Now.ToUniversalTime());

            timer = new System.Threading.Timer((e) =>
            {
                _logger.LogInfo("Call the timer " + DateTime.Now.ToUniversalTime());
                timerCount++;
                System.Threading.Tasks.Task.Run(() => CheckConfigUpdates()).Wait();
            }, null, startTimeSpan, periodTimeSpan);


        }

        private async Task CheckConfigUpdates()
        {
            //var startTimeSpan =(int) TimeSpan.Zero.TotalMilliseconds;
            //var periodTimeSpan =(int) TimeSpan.FromMinutes(_configuration.IntervalTimeForCheckQueuedLockConfig).TotalMilliseconds;
            var startTimeSpan = TimeSpan.Zero;
            var periodTimeSpan = TimeSpan.FromMinutes(_configuration.IntervalTimeForCheckQueuedLockConfig);
            if (timerCount > 10)
            {
                timer.Change(startTimeSpan, periodTimeSpan);
                timerCount = 0;
            }
            _logger.LogInfo("Check config ids to be locked " + DateTime.Now.ToUniversalTime());
            await _configurationService.CheckConfigUpdates();

        }
        public Task HandleAsync(AuthorizationHandlerContext context)
        {
            HttpContext httpContext = _httpContextAccessor.HttpContext;
            httpContext.Items.TryGetValue("JWTPayload", out var payload);
            PortalJWTPayload jwtPayload = payload as PortalJWTPayload;
            if (jwtPayload == null) return Task.CompletedTask;

            var pendingRequirements = context.PendingRequirements.ToList();
            var configurationId = HttpHelper.FindRouteParameter(httpContext.GetRouteData(), "configurationId");
            if (configurationId == null) return Task.CompletedTask;
            var configuration = _configurationService.GetConfigurationInfoByConfigurationId(Int32.Parse(configurationId)).Result;
            var aircraft = _aircraftService.GetAircraftByConfigurationId(Int32.Parse(configurationId)).Result;
            Product product = null;
            if (aircraft != null)
            {
                product = _aircraftService.GetAircraftsProduct(aircraft.Id).Result;
            }
            var claims = new PortalClaimsCollection(jwtPayload);

            foreach (var requirement in pendingRequirements)
            {
                if (requirement is PortalEditConfigurationRequirement)
                {
                    if (MeetsRequirement(claims, configuration, aircraft, product))
                        context.Succeed(requirement);
                }
            }

            return Task.CompletedTask;
        }

        /**
        * Checks if an edit configuration requirement is valid for the current user
        **/
        public bool MeetsRequirement(PortalClaimsCollection claims, ConfigurationDefinitionDetails configuration, Aircraft aircraft, Product aircraftProduct)
        {
            if(configuration != null && configuration.ConfigurationDefinitionType != null)
            {
                if (configuration.ConfigurationDefinitionType.Equals("Global"))
                {
                    return claims.HasClaim(PortalClaimType.ManageGlobalConfiguration) || claims.HasClaim("ManageGlobalConfiguration"); // temporary fix until we can get stage updated
                }
                else if (configuration.ConfigurationDefinitionType.Equals("Product"))
                {
                    return (claims.HasClaim(PortalClaimType.ManageProductConfigurations) || claims.HasClaim(PortalClaimType.ManageProductConfigurations, configuration.ConfigurationDefinitionID.ToString()));
                }
                else if (configuration.ConfigurationDefinitionType.Equals("Platform"))
                {
                    return (claims.HasClaim(PortalClaimType.ManagePlatformConfigurations) || claims.HasClaim(PortalClaimType.ManagePlatformConfigurations, configuration.ConfigurationDefinitionID.ToString()));

                }
            }
           
            if (aircraft != null)
            {
                bool canEdit = false;
                canEdit = claims.HasClaim(PortalClaimType.AdministerAircraft) ||
                          claims.HasClaim(PortalClaimType.AdministerAircraft, aircraft.TailNumber) ||
                          claims.HasClaim(PortalClaimType.AdministerOperator) ||
                          claims.HasClaim(PortalClaimType.AdministerOperator, aircraft.OperatorId.ToString()) ||
                          claims.HasClaim(PortalClaimType.ManageAircraft, aircraft.TailNumber) ||
                          claims.HasClaim(PortalClaimType.ManageOperator) ||
                          claims.HasClaim(PortalClaimType.ManageOperator, aircraft.OperatorId.ToString()) ||
                          claims.HasClaim(PortalClaimType.AdministerAircraftByProduct, aircraftProduct.ProductID.ToString());
                return canEdit;
            }
          
            return false;
        }
    }
}
