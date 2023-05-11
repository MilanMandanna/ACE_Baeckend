using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    public interface IFirstMappedAsync<T>: IExtensionInterface { }

    public static class FirstMappedAsyncExtension
    {
        public static async Task<T> FirstMappedAsync<T>(this IFirstMappedAsync<T> instance, int configurationId) where T : class
        {
            string query = DatabaseMapper.Instance.GenerateMappedStoredProcedure(typeof(T));
            if (query == null) return null;

            var command = instance.CreateCommand(query);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    var into = DatabaseMapper.Instance.Create<T>();
                    DatabaseMapper.Instance.FromReader(reader, into);
                    return into;
                }
            }

            return null;
        }
    }
}
