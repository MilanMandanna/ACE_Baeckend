using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Extensions
{
    public interface IFindByStringDataPropertyAsync<T> : IExtensionInterface
    { }
    public static class FindByStringDataPropertyExtension
    {
        /**
         * Returns the first record with the given name from the table bound to Type <T>
         **/
        public static async Task<T> FindByStringDataPropertyAsync<T>(
            this IFindByStringDataPropertyAsync<T> instance, string propertyName, string value) where T : class
        {
            string query = DatabaseMapper.Instance.GenerateSelectAll(typeof(T));
            if (query == null) return null;
            query = $"{query} WHERE " + propertyName + " = @value";

            var command = instance.CreateCommand(query);
            command.Parameters.AddWithValue("@value", value);

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
