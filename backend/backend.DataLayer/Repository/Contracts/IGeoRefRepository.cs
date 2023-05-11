using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IGeoRefRepository : ISimpleRepository<GeoRef>
    {
        Task<SqlDataReader> GetExportASXInfoGeoRefSpellings(int configurationId, List<Language> languages);

        Task<SqlDataReader> GetExportASXInfoTimezoneStrips(int configurationId);

        Task<SqlDataReader> GetExportASXInfoAppearance(int configurationId);
        Task<SqlDataReader> GetExportASXInfoLatLon(int configurationId);
        Task<SqlDataReader> GetExportAS4000GeoRefIds(int configurationId);
        Task<SqlDataReader> GetExportAS4000GeoRefIdsPnameTriviaUS(int configurationId);
        Task<SqlDataReader> GetExportAS4000GeoRefIdsPnameTriviaNonUS(int configurationId);
        Task<SqlDataReader> GetExportAS4000GeoRefIdsArea(int configurationId);
        Task<SqlDataReader> GetExportAS4000GeoRefIdsElevation(int configurationId);
        Task<SqlDataReader> GetExportAS4000GeoRefIdsPopulation(int configurationId);
        Task<SqlDataReader> GetExportAboutMaxVersion();
        Task<SqlDataReader> GetExportASXI3dGeoRefIds(int configurationId, List<Language> languages,string geoRefIds);
        Task<SqlDataReader> GetExportASXI3dGeoRefIdCategoryType();
        Task<SqlDataReader> GetExportASXI3dGeoRefIdTbTzStrip(int configurationId);
        Task<SqlDataReader> GetExportCESHTSEGeoRefIds(int configurationId);
    }
}
