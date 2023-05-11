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
    public class WorldGuideRepository : Repository, IWorldGuideRepository
    {
        public WorldGuideRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public WorldGuideRepository()
        {
        }

        public async Task<SqlDataReader> GetExportWGContentForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportWGContentForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportWGImageForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportWGImageForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportWGTextForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportWGTextForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportWGTypeForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportWGTypeForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportWGCitiesForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportWGCitiesForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
    }
}
