using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Build
{
    [DataProperty(TableName = "dbo.tblTasks")]
    public class BuildTask
    {
        [DataProperty(PrimaryKey = true)]
        public Guid ID { get; set; }

        [DataProperty]
        public Guid TaskTypeID { get; set; }

        [DataProperty]
        public Guid StartedByUserID { get; set; }

        [DataProperty]
        public int TaskStatusID { get; set; }

        [DataProperty]
        public DateTime DateStarted { get; set; }

        [DataProperty]
        public DateTime DateLastUpdated { get; set; }

        [DataProperty]
        public double PercentageComplete { get; set; }

        [DataProperty]
        public string DetailedStatus { get; set; }

        [DataProperty]
        public int AzureBuildID { get; set; }

        [DataProperty]
        public Guid AircraftID { get; set; }

        [DataProperty]
        public int ConfigurationDefinitionID { get; set; }

        [DataProperty]
        public int ConfigurationID { get; set; }

        [DataProperty]
        public string ErrorLog { get; set; }

        [DataProperty]
        public string TaskDataJSON { get; set; }

        [DataProperty]
        public bool Cancelled { get; set; }
    }
}
