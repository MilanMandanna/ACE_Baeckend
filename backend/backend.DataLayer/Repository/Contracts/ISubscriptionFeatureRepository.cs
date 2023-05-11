using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    /**
     * Interface description for accessing Subscription Features in the database
     **/
    public interface ISubscriptionFeatureRepository :
        IInsertAsync<SubscriptionFeature>,
        IUpdateAsync<SubscriptionFeature>,
        IFindAllAsync<SubscriptionFeature>,
        IFindByIDAsync<SubscriptionFeature>,
        IFindByStringDataPropertyAsync<SubscriptionFeature>,
        IFindObsoleteAsync<SubscriptionFeature>
    {
    }
}
