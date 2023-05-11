using System;
using System.Data.SqlClient;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.SqlServer;

namespace backend.DataLayer.Repository.Contracts
{
    public class ConfigurationComponentMappingRepository :
         SimpleRepository<ConfigurationComponentMapping>,
        IConfigurationComponentMappingRepository
    {
        public ConfigurationComponentMappingRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }
    }
}
