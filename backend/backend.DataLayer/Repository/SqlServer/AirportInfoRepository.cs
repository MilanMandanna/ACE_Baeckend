using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    public class AirportInfoRepository : SimpleRepository<AirportInfo>, IAirportInfoRepository
    {
        public AirportInfoRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction) { }

        public AirportInfoRepository() { }

        public async Task<SqlDataReader> GetExportAS4000AirportInfo(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000AirportInfo]", CommandType.StoredProcedure);

            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportASXI3dAirportInfo(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportASXI3dAirportInfo]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportCESHTSEAirportInfo(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportCESHTSEAirportInfo]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportThalesAirportInfo(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportThalesAirportInfo]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public virtual async Task<List<string>> GetIATAList(int configurationId)
        {
            var command = CreateCommand("[dbo].[SP_Airport_GetNames]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", "iata"));
            command.CommandTimeout = 0;
            var result = new List<string>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(reader.GetString(0));
                }
            }
            return result;

        }

        public virtual async Task<List<string>> GetICAOList(int configurationId)
        {
            var command = CreateCommand("[dbo].[SP_Airport_GetNames]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", "icao"));
            command.CommandTimeout = 0;
            var result = new List<string>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(reader.GetString(0));
                }
            }
            return result;
        }

        public virtual async Task<IEnumerable<Airport>> GetAllAirports(int configurationId)
        {
            IEnumerable<Airport> airports;
            var command = CreateCommand("[dbo].[SP_Airport_GetInfo]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.CommandTimeout = 0;
            using (var reader = await command.ExecuteReaderAsync())
            {
                airports = await DatabaseMapper.Instance.FromReaderAsync<Airport>(reader);
            }

            return airports;
        }

        public virtual async Task<(int, string)> UpdateAirport(int configurationId, ListModlistInfo airportInfo)
        {
            DataTable modListTable = new DataTable();
            modListTable.Columns.Add("id",typeof(int));
            modListTable.Columns.Add("row", typeof(int));
            modListTable.Columns.Add("column", typeof(int));
            modListTable.Columns.Add("resolution", typeof(int));
            int i = 1;
            airportInfo.ModlistInfoArray.ForEach(modlist =>
            {
                
                modListTable.Rows.Add(i,modlist.Row,modlist.Column,modlist.Resolution);
                i++;

            });
            var command = CreateCommand("[dbo].[SP_Airport_UpdateAirport]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@airportInfoID", airportInfo.AirportInfoID));
            command.Parameters.Add(new SqlParameter("@fourLetID", airportInfo.FourLetID));
            command.Parameters.Add(new SqlParameter("@threeLetID", airportInfo.ThreeLetID));
            command.Parameters.Add(new SqlParameter("@lat", airportInfo.Lat));
            command.Parameters.Add(new SqlParameter("@lon", airportInfo.Lon));
            command.Parameters.Add(new SqlParameter("@geoRefID", airportInfo.GeoRefID));
            command.Parameters.Add(new SqlParameter("@cityName", airportInfo.CityName));
            command.Parameters.Add(new SqlParameter("@modlistinfo", modListTable));
            command.CommandTimeout = 0;
            int result = -1;
            string message = "";
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result = reader.GetInt32(0);
                    message = reader.GetString(1);
                }
            }
            return (result,message);
        }

        public virtual async Task<(int, string)> AddAirport(int configurationId, Airport airportInfo)
        {
            var command = CreateCommand("[dbo].[SP_Airport_AddAirport]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@fourLetID", airportInfo.FourLetID));
            command.Parameters.Add(new SqlParameter("@threeLetID", airportInfo.ThreeLetID));
            command.Parameters.Add(new SqlParameter("@lat", airportInfo.Lat));
            command.Parameters.Add(new SqlParameter("@lon", airportInfo.Lon));
            command.Parameters.Add(new SqlParameter("@geoRefID", airportInfo.GeoRefID));
            command.Parameters.Add(new SqlParameter("@cityName", airportInfo.CityName));
            command.CommandTimeout = 0;
            int result = -1;
            string message = "";
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result = DbHelper.DBValueToInt(reader[0]);
                    message = DbHelper.DBValueToString(reader[1]);
                }
            }
            return (result, message);
        }

        public virtual async Task<IEnumerable<CityInfo>> getAllCities(int configurationId)
        {
            IEnumerable<CityInfo> cities;
            var command = CreateCommand("[dbo].[SP_Airport_GetCityInfo]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.CommandTimeout = 0;
            using (var reader = await command.ExecuteReaderAsync())
            {
                cities = await DatabaseMapper.Instance.FromReaderAsync<CityInfo>(reader);
            }

            return cities;
        }

        public virtual async Task<IEnumerable<Airport>> GetExportAllAirports(int configurationId)
        {
            IEnumerable<Airport> airports;
            var command = CreateCommand("[dbo].[SP_GetExportAS4000FourLetter]");
            command.CommandType = CommandType.StoredProcedure;
			command.CommandTimeout = 0;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            using (var reader = await command.ExecuteReaderAsync())
            {
                airports = await DatabaseMapper.Instance.FromReaderAsync<Airport>(reader);
            }

            return airports;
        }

        /// <summary>
        /// This Method returns the Landsat value for the given configurationID
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<string> getlandsatvalue(int configurationId)
        {
            try
            {
                string landSatValue = string.Empty;
                var command = CreateCommand("[dbo].[SP_GetLandSatValue]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.CommandTimeout = 0;
                using var reader = await command.ExecuteReaderAsync();

                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        landSatValue = DbHelper.DBValueToString(reader.GetString(0));
                    }
                }
                return landSatValue;
            }

            catch (Exception e)
            {
                throw e;
            }
           
        }

    }
}
