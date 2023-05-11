using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ICoverageSegmentRepository : ISimpleRepository<CoverageSegment>
    {
        Task<SqlDataReader> GetAS4000CoverageSegments(int configurationId);
        Task<SqlDataReader> GetASXI3dCoverageSegments(int configurationId);
        Task<SqlDataReader> GetCESHTSECoverageSegments(int configurationId);
    }
}
