using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Roles_Claims
{
    [DataProperty(TableName = "dbo.UserRoles")]
    public class UserRoles
    {
        [DataProperty(PrimaryKey = true)]
        public Guid ID { get; set; }
        [DataProperty]
        public string Name { get; set; }
        [DataProperty]
        public string Description { get; set; }
        [DataProperty]
        public bool Hidden { get; set; }
        [DataProperty]
        public bool ThirdParty { get; set; }
    }
}
