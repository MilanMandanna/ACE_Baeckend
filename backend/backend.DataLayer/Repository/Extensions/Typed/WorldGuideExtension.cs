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
    public static class WorldGuideExtension
    {
        public static async Task<SqlDataReader> GetExportASXi3DWGContent(this ISimpleRepository<WorldGuideContent> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryWorldGuide.GetExportASXi3DWGContent);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DWGImage(this ISimpleRepository<WorldGuideImage> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryWorldGuide.GetExportASXi3DWGImage);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DWGText(this ISimpleRepository<WorldGuideText> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryWorldGuide.SQL_GetExportASXi3DWGText);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DWGType(this ISimpleRepository<WorldGuideType> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryWorldGuide.SQL_GetExportASXi3DWGType);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DWGCities(this ISimpleRepository<WorldGuideCities> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryWorldGuide.SQL_GetExportASXi3DWGCities);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }
    }
}
