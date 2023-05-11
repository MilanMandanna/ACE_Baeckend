using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IWorldGuideRepository
    {
        Task<SqlDataReader> GetExportWGContentForConfig(int configurationId);
        Task<SqlDataReader> GetExportWGImageForConfig(int configurationId);
        Task<SqlDataReader> GetExportWGTextForConfig(int configurationId);
        Task<SqlDataReader> GetExportWGTypeForConfig(int configurationId);
        Task<SqlDataReader> GetExportWGCitiesForConfig(int configurationId);
    }
}