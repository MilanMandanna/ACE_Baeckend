using System;
using System.Collections.Generic;
using System.Text;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblConfigurationComponents")]
    public class ConfigurationComponents
    {
        [DataProperty]
        public int ConfigurationComponentID { get; set; }

        [DataProperty]
        public string Path { get; set; }
        [DataProperty]
        public int ConfigurationComponentTypeID { get; set; }
        [DataProperty]
        public string Name { get; set; }

    }
}
