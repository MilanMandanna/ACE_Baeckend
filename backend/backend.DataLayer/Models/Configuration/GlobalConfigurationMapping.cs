using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblGlobalConfigurationMapping")]
    public class GlobalConfigurationMapping
    {
        [DataProperty(PrimaryKey = true)]
        public int GlobalConfigurationMappingID { get; set; }

        [DataProperty]
        public int GlobalID { get; set; }

        [DataProperty]
        public int ConfigurationDefinitionID { get; set; }

        [DataProperty]
        public int MappingIndex { get; set; }
    }
}
