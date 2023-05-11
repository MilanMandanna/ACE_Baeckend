using backend.BusinessLayer.Authorization;
using backend.DataLayer.Authentication;
using backend.DataLayer.Authorization;
using backend.DataLayer.Models.Authorization;
using Microsoft.AspNetCore.Authorization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Authorization
{
    /**
     * Class that is responsible for setting up the authorization
     * options for the portal interface
     **/
    public class PortalAuthorizationOptions
    {

        public static void Configure(AuthorizationOptions options)
        {
            ConfigureStageTestPolicies(options);

            ConfigureAdminPolicies(options);
            ConfigureOperatorPolicies(options);
            ConfigureAircraftPolicies(options);
            ConfigureConfigurationPolicies(options);
            ConfigureRolePolicies(options);
        }

        private static void ConfigureStageTestPolicies(AuthorizationOptions options)
        {
            /** 
             *  The below policies are just test ones based off of the existing
             *  stage manager claims interface. A completely different set of policies
             *  will need to be created once the token interface between the identity server
             *  and the backend is established
             **/
            options.AddPolicy("RoleAccountManagement", policy =>
                policy.Requirements.Add(new PortalStageRoleRequirement("Account Management")));

            options.AddPolicy("RoleOperatorContentManagement", policy =>
                policy.Requirements.Add(new PortalStageRoleRequirement("Operator Content Management")));

            options.AddPolicy("RoleAircraftManagement", policy =>
                policy.Requirements.Add(new PortalStageRoleRequirement("Aircraft Management")));
        }

        private static void ConfigureAdminPolicies(AuthorizationOptions options)
        {
            options.AddPolicy(PortalPolicy.ManageSiteSettings, policy =>
                policy.Requirements.Add(new PortalClaimRequirement(PortalClaimType.ManageSiteSettings))
            );

            options.AddPolicy(PortalPolicy.ManageAccounts, policy =>
                policy.Requirements.Add(new PortalClaimRequirement(PortalClaimType.ManageAccounts))
            );

            options.AddPolicy(PortalPolicy.ViewAccounts, policy => {
                PortalClaimAnyOfRequirement requirement = new PortalClaimAnyOfRequirement(new PortalClaim[]
                {
                    new PortalClaim(PortalClaimType.ManageAccounts),
                    new PortalClaim(PortalClaimType.ViewAccounts)
                });
                policy.Requirements.Add(requirement);
            });

            options.AddPolicy(PortalPolicy.Reports, policy =>
                policy.Requirements.Add(new PortalClaimRequirement(PortalClaimType.Reports))
            );
        }

        private static void ConfigureOperatorPolicies(AuthorizationOptions options)
        {
            options.AddPolicy(PortalPolicy.ManageOperator, policy =>
                policy.Requirements.Add(new PortalOperatorRequirement(true, "operatorId")));

            options.AddPolicy(PortalPolicy.ViewOperator, policy =>
                policy.Requirements.Add(new PortalOperatorRequirement(false, "operatorId")));

            options.AddPolicy(PortalPolicy.AdministerOperator, policy => policy.RequireAssertion((context) => { return true; }));
        }

        private static void ConfigureAircraftPolicies(AuthorizationOptions options)
        {
            options.AddPolicy(PortalPolicy.ManageAircraft, policy => policy.RequireAssertion((context) => { return true; }));

            options.AddPolicy(PortalPolicy.AdministerAircraft, policy => policy.RequireAssertion((context) => { return true; }));

            options.AddPolicy(PortalPolicy.EditAircraft,
                policy => policy.Requirements.Add(new PortalEditAircraftRequirement(true))
            );

            options.AddPolicy(PortalPolicy.ViewAircraft,
                policy => policy.Requirements.Add(new PortalEditAircraftRequirement(false))
            );
        }

        private static void ConfigureConfigurationPolicies(AuthorizationOptions options)
        {

            options.AddPolicy(PortalPolicy.ManageGlobalConfiguration, policy =>
                policy.Requirements.Add(new PortalClaimRequirement(PortalClaimType.ManageGlobalConfiguration))
            );

            options.AddPolicy(PortalPolicy.ManageGlobalConfiguration, policy => policy.RequireAssertion((context) => { return true; }));

            options.AddPolicy(PortalPolicy.ManageProductConfiguration, policy => policy.RequireAssertion((context) => { return true; }));

            options.AddPolicy(PortalPolicy.EditConfiguration,
               policy => policy.Requirements.Add(new PortalEditConfigurationRequirement())
           );

        }

        private static void ConfigureRolePolicies(AuthorizationOptions options)
        {
            options.AddPolicy(PortalPolicy.ManageRoleAssignment, policy => policy.RequireAssertion((context) => { return true; }));
        }
    }
}
