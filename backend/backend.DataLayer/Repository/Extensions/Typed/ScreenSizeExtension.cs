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
    public static class ScreenSizeExtension
    {
        public static async Task<SqlDataReader> GetExportASXi3DScreenSize(this ISimpleRepository<ScreenSize> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryScreenSize.SQL_GetExportASXi3DScreenSize);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }
    }
}
