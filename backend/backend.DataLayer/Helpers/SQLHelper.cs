using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace backend.DataLayer.Helpers
{
    public class SQLHelper
    {
        public static async Task<Dictionary<string, object>> GetSQLResultsForCommand(SqlCommand command)
        {
            var result = new Dictionary<string, object>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        string name = reader.GetName(i);
                        int index = reader.GetOrdinal(name);
                        object value = reader.GetValue(index);
                        result.Add(name, value);
                    }
                }
            }
        return result;
        }
    }
}
