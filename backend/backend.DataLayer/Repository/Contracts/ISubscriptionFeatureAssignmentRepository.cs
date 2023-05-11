using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    /**
     * Interface description for accessing Subscription feature assignments in the database
     **/
    public interface ISubscriptionFeatureAssignmentRepository :
        IInsertAsync<SubscriptionFeatureAssignment>,
        IUpdateAsync<SubscriptionFeatureAssignment>,
        IFindByIDAsync<SubscriptionFeatureAssignment>,
        IFindAllAsync<SubscriptionFeatureAssignment>,
        IDeleteAsync<SubscriptionFeatureAssignment>
    {
        Task<IEnumerable<SubscriptionFeatureAssignment>> FindBySubscriptionId(Guid subscriptionId);

    }
}
