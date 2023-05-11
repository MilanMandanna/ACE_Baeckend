using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Authorization
{
    /**
     * The list of defined policies that can be authorized against
     **/
    public class PortalPolicy
    {
        public const string ManageSiteSettings = "ManageSiteSettings";
        public const string ManageAccounts = "ManageAccounts";
        public const string ViewAccounts = "ViewAccounts";
        public const string ManageRoleAssignment = "ManageRoleAssignment";
        public const string ManageOperator = "ManageOperator";
        public const string ViewOperator = "ViewOperator";
        public const string ManageAircraft = "ManageAircraft";
        public const string Reports = "Reports";
        public const string AdministerOperator = "AdministerOperator";
        public const string AdministerAircraft = "AdministerAircraft";
        public const string ManageGlobalConfiguration = "ManageGlobalConfiguration";
        public const string ManageProductConfiguration = "ManageProductConfiguration";
        public const string ManagePlatformConfiguration = "ManagePlatformConfiguration";

        // compound policies
        // these policies are more abstract in nature and usually involve consideration of a
        // combination of claims
        public const string EditAircraft = "EditAircraftDownloadPreferences";
        public const string ViewAircraft = "ViewAircraft";

        public const string EditConfiguration = "EditConfiguration";

    }
}
