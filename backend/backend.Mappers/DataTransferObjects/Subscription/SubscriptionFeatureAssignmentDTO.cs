using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Subscription
{
    /* tbd */
    public class SubscriptionFeatureAssignmentDTO
    {
        public Guid Id { get; set; }

        public Guid SubscriptionFeatureId { get; set; }

        public string Name { get; set; }

        public string Description { get; set; }

        public string EditorJSONSchema { get; set; }

        public string DefaultJSON { get; set; }

        public String ConfigurationJSON { get; set; }

    }
}
