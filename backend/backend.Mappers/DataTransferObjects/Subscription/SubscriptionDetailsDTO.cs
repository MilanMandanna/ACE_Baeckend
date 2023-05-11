using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Subscription
{
    /**
     * Class that encapsulates all the detailed information for a subscription
     **/
    public class SubscriptionDetailsDTO
    {

        public Guid Id { get; set; }

        public string Name { get; set; }

        public string Description { get; set; }

        public bool IsObsolete { get; set; }

        public DateTime DateCreated { get; set; }

        public List<SubscriptionFeatureAssignmentDTO> Features { get; set; }

    }
}
