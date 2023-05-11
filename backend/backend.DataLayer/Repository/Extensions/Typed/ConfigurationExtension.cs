using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    public static class ConfigurationExtension
    {

        public static async Task<Configuration> GetLatestConfiguration(this ISimpleRepository<Configuration> instance, int configurationDefinitionId)
        {
            var command = instance.CreateCommand(QueryExport.SQL_GetLatestConfiguration);
            command.Parameters.AddWithValue("@configurationDefinitionId", configurationDefinitionId);
            
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    var into = DatabaseMapper.Instance.Create<Configuration>();
                    DatabaseMapper.Instance.FromReader(reader, into);
                    return into;
                }
            }

            return null;
        }

    }
}
