using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblTrigger")]
    public class ConfigTrigger
    {
        [DataProperty(PrimaryKey = true)]
        public int TriggerID { get; set; }

        [DataProperty]
        public string TriggerDefs { get; set; }
    }
}
