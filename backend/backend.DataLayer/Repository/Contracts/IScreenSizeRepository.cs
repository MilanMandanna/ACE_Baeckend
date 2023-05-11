using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IScreenSizeRepository
    {
        Task<SqlDataReader> GetExportScreenSizeForConfig(int configurationId);
    }
}