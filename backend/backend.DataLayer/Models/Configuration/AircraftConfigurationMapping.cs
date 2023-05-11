using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblAircraftConfigurationMapping")]
    public class AircraftConfigurationMapping
    {
        [DataProperty(PrimaryKey = true)]
        public int ConfigurationDefinitionID { get; set; }

        [DataProperty(PrimaryKey = true)]
        public int MappingIndex { get; set; }

        [DataProperty(PrimaryKey = true)]
        public Guid AircraftID { get; set; }
    }
}
