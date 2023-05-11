using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblPlatformConfigurationMapping")]
    public class PlatformConfigurationMapping
    {
        [DataProperty(PrimaryKey = true)]
        public int PlatformID { get; set; }

        [DataProperty(PrimaryKey = true)]
        public int ConfigurationDefinitionID { get; set; }
    }
}
