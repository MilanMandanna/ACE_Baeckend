using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Text;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Repository.Extensions
{
    /**
     * Extension interface that adds a FindObsoleteAsync method to a class
     **/
    public interface IFindObsoleteAsync<T> : IExtensionInterface
    {
    }

    public static class FindObsoleteAsyncExtension
    {
        /**
         * Returns a listing of records that have the IsObsolete field set to the specified value in the table bound to the Type <T>
         **/
        public static async Task<List<T>> FindObsoleteAsync<T>(this IFindObsoleteAsync<T> instance, bool obsolete) where T: class
        {
            string query = DatabaseMapper.Instance.GenerateSelectAll(typeof(T));
            if (query == null) return null;

            query = $"{query} WHERE IsObsolete = {(obsolete ? 1 : 0)}";
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
