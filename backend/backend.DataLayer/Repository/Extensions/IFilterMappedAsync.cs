using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    public interface IFilterMappedAsync<T> : IExtensionInterface { }

    public static class FilterMappedAsyncExtension
    {
        public static async Task<List<T>> FilterMappedAsync<T>(this IFilterMappedAsync<T> instance, int configurationId) where T : class
        {
            string query = DatabaseMapper.Instance.GenerateMappedStoredProcedure(typeof(T));
            if (query == null) return null;

            var command = instance.CreateCommand(query);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            var results = new List<T>();

            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    var into = DatabaseMapper.Instance.Create<T>();
                    DatabaseMapper.Instance.FromReader(reader, into);
                    results.Add(into);
                }
            }

            return results;
        }
    }
}
