using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    /**
     * Interface description for accessing Subscriptions in the database
     **/
    public interface ISubscriptionRepository :
        IInsertAsync<Subscription>,
        IUpdateAsync<Subscription>,
        IFindAllAsync<Subscription>,
        IFindByIDAsync<Subscription>,
        IFindByStringDataPropertyAsync<Subscription>,
        IFindObsoleteAsync<Subscription>
    {
    }
}
