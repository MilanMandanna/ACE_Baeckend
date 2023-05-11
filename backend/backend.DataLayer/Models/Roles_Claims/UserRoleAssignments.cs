using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Roles_Claims
{
    [DataProperty(TableName = "dbo.UserRoleAssignments")]
    public class UserRoleAssignments
    {
        [DataProperty(PrimaryKey = true)]
        public Guid ID { get; set; }
        [DataProperty]
        public Guid UserID { get; set; }
        [DataProperty]
        public Guid? RoleID { get; set; }
    }
}
