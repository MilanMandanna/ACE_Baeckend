using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Subscription
{
    public class JSONValidationRequestDTO
    {
        public string JSONData { get; set; }

        public Guid SubscriptionFeatureId { get; set; }
    }
}
