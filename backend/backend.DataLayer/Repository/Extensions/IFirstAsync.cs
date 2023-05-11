using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{

    public interface IFirstAsync<T> :IExtensionInterface { }


    public static class FirstAsyncExtension
    {
        public static async Task<T> FirstAsync<T>(this IFirstAsync<T> instance, string fieldName, object value) where T : class
        {
            string query = DatabaseMapper.Instance.GenerateSelectAll(typeof(T));
            if (query == null) return null;

            query = $"{query} WHERE {fieldName} = @value";
            var command = instance.CreateCommand(query);
            command.Parameters.AddWithValue("@value", value);
            List<T> results = new List<T>();

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
