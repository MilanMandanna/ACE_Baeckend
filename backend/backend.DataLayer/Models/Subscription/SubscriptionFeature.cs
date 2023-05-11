using backend.DataLayer.Helpers.Database;
using System;

namespace backend.DataLayer.Models.Subscription
{
    [DataProperty(TableName = "dbo.tblSubscriptionFeature")]
    public class SubscriptionFeature
    {
        [DataProperty(PrimaryKey = true)]
        public Guid Id { get; set; }

        [DataProperty]
        public string Name { get; set; }

        [DataProperty]
        public string Description { get; set; }

        [DataProperty]
        public string DefaultJSON { get; set; }

        [DataProperty]
        public string EditorJSONSchema { get; set; }

        [DataProperty]
        public bool IsObsolete { get; set; }
    }
}
