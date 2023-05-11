using System;
using System.Data.SqlClient;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;

namespace backend.DataLayer.Repository.SqlServer
{
    public class TriggerConfigurationMappingRepository :
        SimpleRepository<TriggerConfigurationMapping>,
        ITriggerConfigurationMappingRepository
    {
        public TriggerConfigurationMappingRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }
    }
}
