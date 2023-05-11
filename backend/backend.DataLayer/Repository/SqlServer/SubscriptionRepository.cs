using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.Contracts;
using System.Data.SqlClient;


namespace backend.DataLayer.Repository.SqlServer
{
    /**
     * Repository for accessing the Subscription table
     **/
    public class SubscriptionRepository: SimpleRepository<Subscription>, ISubscriptionRepository
    {
        public SubscriptionRepository()
        {

        }
        public SubscriptionRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }
    }
}
