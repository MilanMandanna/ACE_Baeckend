using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    public class CoverageSegmentRepository : SimpleRepository<CoverageSegment>, ICoverageSegmentRepository
    {
        public CoverageSegmentRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }

        public async Task<SqlDataReader> GetAS4000CoverageSegments(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetAS4000CoverageSegments]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetASXI3dCoverageSegments(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetASXI3dCoverageSegments]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetCESHTSECoverageSegments(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetCESHTSECoverageSegments]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
    }
}
