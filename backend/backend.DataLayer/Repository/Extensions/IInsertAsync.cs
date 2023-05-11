using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    /**
     * Extension interface that adds an InsertAsync method to a class
     **/
    public interface IInsertAsync<T> : IExtensionInterface
    {
    }

    public static class InsertAsyncExtension
    {
        /**
         * Inserts a record into the table bound to the Type T
         **/
        public static async Task<int> InsertAsync<T>(this IInsertAsync<T> instance, T data)
        {
            int result = 0;
            using (var command = instance.CreateCommand(null))
            {
                if (command.Connection != null)
                {
                    DatabaseMapper.Instance.PrepareInsert(data, command);
                    result = await command.ExecuteNonQueryAsync();
                }
            }
            return result;
        }
    }
}
