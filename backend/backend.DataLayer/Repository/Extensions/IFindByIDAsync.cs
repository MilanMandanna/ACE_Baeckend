using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    /**
     * Extension interface that adds a FindByIDAsync method to a class
     **/
    public interface IFindByIDAsync<T> : IExtensionInterface
    {
    }

    public static class IFindByAsyncExtension
    {
        /**
         * Returns the first record that has the given Id from the table bound to the type <T>
         **/
        public static async Task<T> FindByIdAsync<T>(this IFindByIDAsync<T> instance, Guid Id) where T : class
        {
            string query = DatabaseMapper.Instance.GenerateSelectAll(typeof(T));
            if (query == null) return null;
            query = $"{query} WHERE Id = @Id";

            var command = instance.CreateCommand(query);
            command.Parameters.AddWithValue("@Id", Id);

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
