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
    public class FontRepository : Repository, IFontRepository
    {
        public FontRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public FontRepository()
        {
        }

        public async Task<SqlDataReader> GetExportFontForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontForConfigPAC3D(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontForConfigPAC3D]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontCategoryForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontCategoryForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontCategoryForConfigPAC3D(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontCategoryForConfigPAC3D]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontDefaultCategoryForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontDefaultCategoryForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontDefaultCategoryForConfigPAC3D(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontDefaultCategoryForConfigPAC3D]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontFamilyForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontFamilyForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontFamilyForConfigPAC3D(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontFamilyForConfigPAC3D]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontMarkerForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontMarkerForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontMarkerForConfigPAC3D(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontMarkerForConfigPAC3D]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontTextEffectForConfig(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontTextEffectForConfig]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportFontTextEffectForConfigPAC3D(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportFontTextEffectForConfigPAC3D]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
    }
}
