using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    public static class FontsExtension
    {
        public static async Task<SqlDataReader> GetExportASXi3DFonts(this ISimpleRepository<Font> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportASXi3DFonts);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DFontCategory(this ISimpleRepository<FontCategory> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportASXi3DFontCategory);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DFontDefaultCategory(this ISimpleRepository<FontDefaultCategory> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportASXi3DFontDefaultCategory);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DFontFamily(this ISimpleRepository<FontFamily> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportASXi3DFontFamily);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DFontMarker(this ISimpleRepository<FontMarker> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportASXi3DFontMarker);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DFontTextEffect(this ISimpleRepository<FontTextEffect> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportASXi3DFontTextEffect);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }
        public static async Task<SqlDataReader> GetExportCESHTSEFonts(this ISimpleRepository<Font> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportCESHTSEFonts);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportCESHTSEFontCategories(this ISimpleRepository<FontCategory> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportCESHTSEFontCategories);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportCESHTSEFontDefaultCategories(this ISimpleRepository<FontCategory> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportCESHTSEFontDefaultCategories);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportCESHTSEFontFamily(this ISimpleRepository<FontFamily> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryFonts.SQL_GetExportCESHTSEFontFamily);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }
    }
}
