using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;

namespace backend.DataLayer.Repository.SqlServer
{
    public class BuildTaskRepository : Repository, IBuildTaskRepository
    {
        public BuildTaskRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public BuildTaskRepository()
        {
        }

        public async Task<List<BuildTask>> GetProductExports(int configurationId)
        {
            var command = CreateCommand("sp_GetProductExport", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<BuildTask> results = new List<BuildTask>();

            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    var into = DatabaseMapper.Instance.Create<BuildTask>();
                    DatabaseMapper.Instance.FromReader(reader, into);
                    results.Add(into);
                }
            }

            return results;
        }

    }
}
