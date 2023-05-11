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
    public static class LanguagesExtension
    {
        public static async Task<SqlDataReader> GetExportAS4000Languages(this ISimpleRepository<Language> instance, int configurationId)
        {
            var command = instance.CreateCommand("[dbo].[sp_GetExportAS4000Languages]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }

        public static async Task<SqlDataReader> GetExportASXi3DLanguages(this ISimpleRepository<Language> instance, int configurationId)
        {
            var command = instance.CreateCommand("[dbo].[sp_GetExportASXi3DLanguages]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }
    }
}
