using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IAppearanceRepository : ISimpleRepository<Appearance>
    {
        Task<SqlDataReader> GetExportAS4000Appearance(int configurationId);

        Task<SqlDataReader> GetExportAS4000AppearanceResolution6(int configurationId);

        Task<SqlDataReader> GetExportASXI3dAppearance(int configurationId);
        Task<SqlDataReader> GetExportCESHTSEAppearance(int configurationId);
    }
}
