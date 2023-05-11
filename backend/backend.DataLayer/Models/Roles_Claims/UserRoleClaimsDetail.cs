using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Roles_Claims
{
    //had to add tabel name here as it was gving empty table name while deleting the UserRoleClaims entry 
    [DataProperty(TableName = "dbo.UserRoleClaims")]
    public class UserRoleClaimsDetail : UserRoleClaims
    {        
        [DataProperty]
        public String Name { get; set; }
    }
}
