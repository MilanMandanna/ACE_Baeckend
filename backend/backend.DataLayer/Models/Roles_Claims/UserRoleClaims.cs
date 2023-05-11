using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Roles_Claims
{
    [DataProperty(TableName = "dbo.UserRoleClaims")]
    public class UserRoleClaims
    {
        [DataProperty(PrimaryKey = true)]
        public Guid ID { get; set; }       
        [DataProperty]
        public Guid RoleID { get; set; }
        [DataProperty]
        public Guid ClaimID { get; set; }
        [DataProperty]
        public Guid AircraftID { get; set; }
        [DataProperty]
        public Guid UserRoleID { get; set; }
        [DataProperty]
        public int? ConfigurationID { get; set; }
        [DataProperty]
        public int? ConfigurationDefinitionID { get; set; }
        [DataProperty]
        public Guid OperatorID { get; set; }

        [DataProperty]
        public int? ProductTypeID { get; set; }
    }
}
