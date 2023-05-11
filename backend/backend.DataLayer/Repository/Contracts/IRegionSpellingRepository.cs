using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IRegionSpellingRepository : ISimpleRepository<RegionSpelling>
    {
        Task<SqlDataReader> GetExportASXInfoRegionSpellings(int configurationId, List<Language> languages);
        Task<SqlDataReader> GetExportASXI3dRegionSpelling(int configurationId,List<Language> languages);
    }
}
