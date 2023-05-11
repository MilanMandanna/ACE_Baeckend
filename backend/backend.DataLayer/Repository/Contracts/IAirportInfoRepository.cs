using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IAirportInfoRepository : ISimpleRepository<AirportInfo>
    {
        Task<IEnumerable<Airport>> GetExportAllAirports(int configurationId);
        Task<SqlDataReader> GetExportAS4000AirportInfo(int configurationId);
        Task<SqlDataReader> GetExportASXI3dAirportInfo(int configurationId);
        Task<SqlDataReader> GetExportCESHTSEAirportInfo(int configurationId);
        Task<SqlDataReader> GetExportThalesAirportInfo(int configurationId);

        Task<List<string>> GetIATAList(int configurationId);
        Task<List<string>> GetICAOList(int configurationId);
        Task<IEnumerable<Airport>> GetAllAirports(int configurationId);
        Task<(int,string)> UpdateAirport(int configurationId, ListModlistInfo airportInfo);
        Task<(int, string)> AddAirport(int configurationId, Airport airportInfo);
        Task<IEnumerable<CityInfo>> getAllCities(int configurationId);
        Task<string> getlandsatvalue(int configurationId);

    }
}
