using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    /** extension interface that adds a function to filter on a single arbitrary field and return the list of records
     * matching the filter.
     **/
    public interface IFilterAsync<T>: IExtensionInterface
    {
    }

    public static class FilterAsyncExtension
    {
        public static async Task<List<T>> FilterAsync<T>(this IFilterAsync<T> instance, string fieldName, object value) where T : class
        {
            string query = DatabaseMapper.Instance.GenerateSelectAll(typeof(T));
            if (query == null) return null;

            query = $"{query} WHERE {fieldName} = @value";
            var command = instance.CreateCommand(query);
            command.Parameters.AddWithValue("@value", value);
            List<T> results = new List<T>();
            if (command.Connection != null)
            {

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    var into = DatabaseMapper.Instance.Create<T>();
                    DatabaseMapper.Instance.FromReader(reader, into);
                    results.Add(into);
                }
                reader.Close();
            }

            return results;
        }
    }
}
