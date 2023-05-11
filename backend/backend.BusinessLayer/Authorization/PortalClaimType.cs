using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Authorization
{
    /**
     * The list of individual claims that will be provided by the
     * identity service (proposed)
     **/
    public class PortalClaimType
    {
        public const string ManageSiteSettings = "Manage Site Settings";
        public const string ManageAccounts = "Manage Accounts";
        public const string ViewAccounts = "View Accounts";
        public const string ManageRoleAssignment = "Manage Role Assignment";
        public const string ManageOperator = "Manage Operator";
        public const string ViewOperator = "View Operator";
        public const string ManageAircraft = "Manage Aircraft";
        public const string ManageAircraftByProduct = "ManageAircraftByProduct";
        //public const string ViewAircraft = "ViewAircraft";
        public const string ViewAircraftByProduct = "ViewAircraftByProduct";
        public const string Reports = "Reports";
        public const string AdministerOperator = "Administer Operator";
        public const string AdministerAircraft = "Administer Aircraft";
        public const string AdministerAircraftByProduct = "AdministerAircraftByProduct";
        public const string ManageGlobalConfiguration = "Manage Global Configuration";
        public const string ManageProductConfigurations = "ManageProductConfiguration";
        public const string ManagePlatformConfigurations = "ManagePlatformConfiguration";
    }
}
