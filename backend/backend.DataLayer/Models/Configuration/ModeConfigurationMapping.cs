using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
 
    [DataProperty(TableName = "cust.tblModeDefsMap")]
    public class ModeConfigurationMapping
    {
        [DataProperty]
        public int ModeDefID { get; set; }
        [DataProperty]
        public int ConfigurationID { get; set; }
        [DataProperty]
        public int? PreviousModeDefID { get; set; }
        [DataProperty]
        public bool IsDeleted { get; set; }
        [DataProperty]
        public string LastModifiedBy { get; set; }
        [DataProperty]
        public string Action { get; set; }
        //[DataProperty]
        //public int ModetDefID { get; set; }
    }
}
