using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Subscription
{
    public class FormCreateSubscriptionFeatureAssignmentDTO
    {
        public Guid Id { get; set; }

        public Guid SubscriptionId { get; set; }

        public Guid SubscriptionFeatureId { get; set; }

        public string ConfigurationJSON { get; set; }
    }
}
