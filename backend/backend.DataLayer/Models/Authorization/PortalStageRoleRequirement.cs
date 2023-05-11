using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Authorization
{
    public class PortalStageRoleRequirement : PortalClaimRequirement
    {
        /**
         * This is class just for testing policy setup, this should be removed at some point
         **/
        public PortalStageRoleRequirement(string role) : base("Stage Flight Mgmt", role, "operator_privilege")
        {           
        }
    }
}
