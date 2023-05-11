using System;
using Ace.DataLayer.Models;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.Aircraft")]
    public class AircraftConfiguration: Aircraft
    {
        [DataProperty]
        public int ConfigurationDefinitionID { get; set; }
        [DataProperty]
        public int ConfigurationID { get; set; }
        
    }
}
