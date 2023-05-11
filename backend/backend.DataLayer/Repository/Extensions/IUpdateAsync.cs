using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    /**
     * Extension interface that adds an UpdateAsync method to a class
     **/
    public interface IUpdateAsync<T> : IExtensionInterface
    {
    }

    public static class UpdateAsyncExtension
    {
        /**
         * Updates a record in the table bound to the Type T
         **/
        public static async Task<int> UpdateAsync<T>(this IUpdateAsync<T> instance, T data)
        {
            int result = 0;
            using (var command = instance.CreateCommand(null))
            {
                if (command.Connection != null)
                {
                    DatabaseMapper.Instance.PrepareUpdate(data, command);
                    result = await command.ExecuteNonQueryAsync();
                }
            }
            return result;
        }
    }
}
