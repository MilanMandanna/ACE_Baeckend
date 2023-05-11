
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Data;

namespace backend.DataLayer.Repository.SqlServer
{
    /**
     * Repository for accessing the SubscriptionFeatureAssignment table
     **/
    public class SubscriptionFeatureAssignmentRepository : 
        SimpleRepository<SubscriptionFeatureAssignment>,
        ISubscriptionFeatureAssignmentRepository
    {
        public SubscriptionFeatureAssignmentRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }

        public async Task<IEnumerable<SubscriptionFeatureAssignment>> FindBySubscriptionId(Guid subscriptionId)
        {
            var command = CreateCommand("[dbo].[SP_Subscription_Find]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@subscriptionId", subscriptionId);

            using (var reader = await command.ExecuteReaderAsync())
                return await DatabaseMapper.Instance.FromReaderAsync<SubscriptionFeatureAssignment>(reader);
        }
    }
}
