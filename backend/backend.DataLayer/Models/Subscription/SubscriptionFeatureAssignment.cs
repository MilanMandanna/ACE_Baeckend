using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Subscription
{
    [DataProperty(TableName = "dbo.tblSubscriptionFeatureAssignment")]
    public class SubscriptionFeatureAssignment
    {
        [DataProperty(PrimaryKey = true)]
        public Guid Id { get; set; }

        [DataProperty]
        public Guid SubscriptionId { get; set; }

        [DataProperty]
        public Guid SubscriptionFeatureId { get; set; }

        [DataProperty]
        public string ConfigurationJSON { get; set; }

    }
}
