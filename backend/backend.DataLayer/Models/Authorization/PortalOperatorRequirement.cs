using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Authorization
{
    public class PortalOperatorRequirement : PortalHttpParameterRequirement
    {
        public Boolean RequireManage { get; }


        public PortalOperatorRequirement(bool requireManage, string[] httpParameterNames) : base(httpParameterNames) {
            RequireManage = requireManage;
        }

        public PortalOperatorRequirement(bool requireManage, string httpParameterName) : base(new string[] { httpParameterName })
        {
            RequireManage = requireManage;
        }
    }
}

