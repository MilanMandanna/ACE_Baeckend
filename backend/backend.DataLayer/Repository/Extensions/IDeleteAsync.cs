using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    public interface IDeleteAsync<T>: IExtensionInterface
    {
    }

    public static class DeleteAsyncExtension
    {
        public static async Task<int> DeleteAsync<T>(this IDeleteAsync<T> instance, T data)
        {
            using (var command = instance.CreateCommand(null))
            {
                DatabaseMapper.Instance.PrepareDelete(data, command);
                return await command.ExecuteNonQueryAsync();
            }
        }
    }
}
