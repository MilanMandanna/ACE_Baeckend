using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Build
{
    [DataProperty(TableName = "dbo.tblTasks")]
    public class BuildEntry
    {
        [DataProperty]
        public Guid ID { get; set; }

        [DataProperty]
        public string DefinitionName { get; set; }

        [DataProperty]
        public string BuildStatus { get; set; }

        [DataProperty]
        public double PercentageComplete { get; set; }

        [DataProperty]
        public int ConfigurationVersion { get; set; }

        [DataProperty]
        public int ConfigurationID { get; set; }

        [DataProperty]
        public int ConfigurationDefinitionID { get; set; }

        [DataProperty]
        public DateTime DateStarted { get; set; }
        [DataProperty]
        public string TaskTypeName { get; set; }
    }
}
