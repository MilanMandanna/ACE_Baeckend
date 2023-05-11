using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Subscription
{
    [DataProperty(TableName = "dbo.tblAirshowSubscriptionAssignment")]
    public class AirshowSubscriptionAssignment
    {
        [DataProperty(PrimaryKey = true)]
        public Guid ID { get; set; }

        [DataProperty] public int ConfigurationDefinitionID { get; set; }

        [DataProperty] public Guid SubscriptionID { get; set; }

        [DataProperty] public DateTime DateNextSubscriptionCheck { get; set; }

        [DataProperty] public bool IsActive { get; set; }
    }
}
