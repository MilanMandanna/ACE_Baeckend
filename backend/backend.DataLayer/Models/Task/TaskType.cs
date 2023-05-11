using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Task
{
    [DataProperty(TableName = "dbo.tblTaskType")]
    public class TaskType
    {
        [DataProperty(PrimaryKey = true)]
        public Guid ID { get; set; }

        [DataProperty]
        public String Name { get; set; }

        [DataProperty]
        public String Description { get; set; }

        [DataProperty]
        public int AzureDefinitionID { get; set; }

        [DataProperty]
        public bool ShouldShowInBuildDashboard { get; set; }
    }
}
