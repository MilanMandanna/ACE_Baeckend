using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    /**
     * Repository for accessing the SubscriptionFeature table
     **/
    public class SubscriptionFeatureRepository: SimpleRepository<SubscriptionFeature>, ISubscriptionFeatureRepository
    {
        public SubscriptionFeatureRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }
    }
}
