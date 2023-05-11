using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblProductConfigurationMapping")]
    public class ProductConfigurationMapping
    {
        [DataProperty(PrimaryKey = true)]
        public int ProductID { get; set; }

        [DataProperty(PrimaryKey = true)]
        public int ConfigurationDefinitionID { get; set; }
    }
}
