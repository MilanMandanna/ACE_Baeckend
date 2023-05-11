using backend.DataLayer.Models.Subscription;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Subscription;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface ISubscriptionService
    {

        Task<List<Subscription>> GetAllSubscriptions();

        Task<List<SubscriptionDTO>> GetActiveSubscriptions();

        Task<DataCreationResultDTO> CreateSubscription(FormCreateSubscriptionDTO formData);

        Task<DataCreationResultDTO> UpdateSubscription(FormUpdateSubscriptionDTO formData);

        Task<List<SubscriptionFeature>> GetAllSubscriptionFeatures();

        Task<List<SubscriptionFeature>> GetAllActiveSubscriptionFeatures();

        Task<SubscriptionDetailsDTO> GetSubscriptionDetails(IDRequestDTO subscriptionId);

        Task<DataCreationResultDTO> UpdateSubscriptionDetails(SubscriptionDetailsDTO details);
    }
}
