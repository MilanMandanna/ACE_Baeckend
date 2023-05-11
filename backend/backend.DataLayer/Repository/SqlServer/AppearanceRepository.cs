using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    class AppearanceRepository : SimpleRepository<Appearance>, IAppearanceRepository
    {
        public AppearanceRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction) { }

        public async Task<SqlDataReader> GetExportAS4000Appearance(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000Appearance]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportAS4000AppearanceResolution6(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000AppearanceResolution6]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportASXI3dAppearance(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportASXI3dAppearance]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportCESHTSEAppearance(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportCESHTSEAppearance]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
    }
}
