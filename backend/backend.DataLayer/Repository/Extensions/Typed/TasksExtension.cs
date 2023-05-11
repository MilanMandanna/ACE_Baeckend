using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    public static class TasksExtension
    {
        public static object QueryExports { get; private set; }

        public static async Task<List<BuildTask>> GetProductExports(this ISimpleRepository<BuildTask> instance, int configurationId)
        {
            var command = instance.CreateCommand(QueryExport.SQL_GetProductExport);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<BuildTask> results = new List<BuildTask>();

            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    var into = DatabaseMapper.Instance.Create<BuildTask>();
                    DatabaseMapper.Instance.FromReader(reader, into);
                    results.Add(into);
                }
            }

            return results;
        }
    }
}
