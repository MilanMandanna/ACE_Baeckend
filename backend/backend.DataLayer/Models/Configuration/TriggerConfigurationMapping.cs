using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
   
    [DataProperty(TableName = "cust.tblTriggerMap")]
    public class TriggerConfigurationMapping
{
        [DataProperty]
        public int TriggerID { get; set; }
        [DataProperty]
        public int ConfigurationID { get; set; }
        [DataProperty]
        public int? PreviousTriggerID { get; set; }
        [DataProperty]
        public bool IsDeleted { get; set; }
        [DataProperty]
        public string LastModifiedBy { get; set; }
        [DataProperty]
        public string Action { get; set; }

    }
}
