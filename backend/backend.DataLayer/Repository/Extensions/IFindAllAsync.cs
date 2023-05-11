using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    /**
     * Extension interface that adds support for a FindAllAsync method to a class
     **/
    public interface IFindAllAsync<T> : IExtensionInterface
    {
    }

    public static class FindAllAsyncExtension
    {
        /**
         * Returns a full listing of all records from the table bound to the Type <T>
         **/
        public static async Task<List<T>> FindAllAsync<T>(this IFindAllAsync<T> instance) where T : class
        {
            string query = DatabaseMapper.Instance.GenerateSelectAll(typeof(T));
            if (query == null) return null;

            var command = instance.CreateCommand(query);
            List<T> results = new List<T>();

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
