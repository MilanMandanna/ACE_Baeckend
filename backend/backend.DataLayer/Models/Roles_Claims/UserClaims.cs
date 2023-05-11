using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Roles_Claims
{
    [DataProperty(TableName = "dbo.UserClaims")]
    public class UserClaims
    {
        [DataProperty(PrimaryKey = true)]
        public Guid ID { get; set; }
        [DataProperty]
        public string Name { get; set; }
        [DataProperty]
        public string? Description { get; set; }
        [DataProperty]
        public string? ScopeType { get; set; }
    }
}
