using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblFlyOverAlert")]
    public class ConfigFlyOverAlert
    {
        [DataProperty(PrimaryKey = true)]
        public int FlyOverAlertID { get; set; }

        [DataProperty] public string FlyOverAlert { get; set; }
    }
}
