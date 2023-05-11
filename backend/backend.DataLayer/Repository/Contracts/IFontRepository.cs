using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IFontRepository
    {
        Task<SqlDataReader> GetExportFontForConfig(int configurationId);
        Task<SqlDataReader> GetExportFontCategoryForConfig(int configurationId);
        Task<SqlDataReader> GetExportFontDefaultCategoryForConfig(int configurationId);
        Task<SqlDataReader> GetExportFontFamilyForConfig(int configurationId);
        Task<SqlDataReader> GetExportFontMarkerForConfig(int configurationId);
        Task<SqlDataReader> GetExportFontTextEffectForConfig(int configurationId);

        #region font for PAC3D
        Task<SqlDataReader> GetExportFontForConfigPAC3D(int configurationId);
        Task<SqlDataReader> GetExportFontCategoryForConfigPAC3D(int configurationId);
        Task<SqlDataReader> GetExportFontDefaultCategoryForConfigPAC3D(int configurationId);
        Task<SqlDataReader> GetExportFontFamilyForConfigPAC3D(int configurationId);
        Task<SqlDataReader> GetExportFontMarkerForConfigPAC3D(int configurationId);
        Task<SqlDataReader> GetExportFontTextEffectForConfigPAC3D(int configurationId);

        #endregion





    }
}