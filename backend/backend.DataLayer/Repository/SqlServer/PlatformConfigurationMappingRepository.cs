using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer
{
    public class PlatformConfigurationMappingRepository :
        SimpleRepository<PlatformConfigurationMapping>,
        IPlatformConfigurationMappingRepository
    {
        public PlatformConfigurationMappingRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }
    }
}
