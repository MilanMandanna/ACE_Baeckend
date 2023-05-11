using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ScreenSizeRepository : Repository, IScreenSizeRepository
    {
        public ScreenSizeRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public ScreenSizeRepository()
        {
        }

        public async Task<SqlDataReader> GetExportScreenSizeForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportScreenSizeForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

    }
}
