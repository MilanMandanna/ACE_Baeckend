using System;
using System.Data.SqlClient;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ModeConfigurationMappingRepository :
           SimpleRepository<ModeConfigurationMapping>,
        IModeConfigurationMappingRepository
    {
        public ModeConfigurationMappingRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }

        public ModeConfigurationMappingRepository()
        { }
    }
}
