using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    public class GeoRefRepository : SimpleRepository<GeoRef>, IGeoRefRepository
    {
        public GeoRefRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction) { }

        /**
         * Retrieves the main chunk of information for a georef record suitable for export to the asxinfo database
         * The spellings for each record are also provided as column associated with the two-letter language code for each
         * requested language
         */
        public async Task<SqlDataReader> GetExportASXInfoGeoRefSpellings(int configurationId, List<Language> languages)
        {
            var languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));
            //var sql = QueryGeoRef.SQL_GetExportASXInfoGeoRefSpellings.Replace("{languageCodes}", languageCodes);
            var command = CreateCommand("sp_GetExportASXInfoGeoRefSpellings", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@languageCodes", languageCodes);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        /**
         * Retrieves the latitude and longitude information for each georef record. Suitable for export
         * into the asxinfo database.
         */
        public async Task<SqlDataReader> GetExportASXInfoLatLon(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportASXInfoLatLon]",System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            return await command.ExecuteReaderAsync();
        }

        /**
         * Retrieves appearance information that can be used to build the inclusion column in the asxinfo database.
         * Only the defined resolutions supported by the asx software are returned here so if new resolutions are added
         * then this query would need to be updated. 15 is included for compatibility with the swops tool.
         */
        public async Task<SqlDataReader> GetExportASXInfoAppearance(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportASXInfoAppearance]", System.Data.CommandType.StoredProcedure);

            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
        /**
         * Retrieves information regarding the timezone strip mapping for the georefids associated with a timezone strip.
         * This information should only be used for exporting to an asxinfof database
         */
        public async Task<SqlDataReader> GetExportASXInfoTimezoneStrips(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportASXInfoTimezoneStrips]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportAS4000GeoRefIds(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000GeoRefIds]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportAS4000GeoRefIdsPnameTriviaUS(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000GeoRefIdsPnameTriviaUS]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportAS4000GeoRefIdsPnameTriviaNonUS(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000GeoRefIdsPnameTriviaNonUS]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportAS4000GeoRefIdsArea(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000GeoRefIdsArea]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportAS4000GeoRefIdsElevation(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000GeoRefIdsElevation]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportAS4000GeoRefIdsPopulation(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000GeoRefIdsPopulation]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        // todo: delete this
        public async Task<SqlDataReader> GetExportAboutMaxVersion()
        {
            var sql = "";
            sql += "SELECT 99 as version";
            //sql += "from tblAbout where version = (select max(version) from tblAbout) "; ;
            var command = CreateCommand(sql);
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportASXI3dGeoRefIds(int configurationId,List<Language> languages,string geoRefIds)
        {
            string languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));
            SqlCommand command;
            if (string.IsNullOrEmpty(geoRefIds))
            {
                command = CreateCommand("[dbo].[sp_GetExportASXI3dGeoRefIds]", System.Data.CommandType.StoredProcedure);
            }
            else
            {
                command = CreateCommand("[dbo].[sp_GetExportASXI3dGeoRefIdsFiltered]", System.Data.CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@geoRefIds", geoRefIds);
            }
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@languages", languageCodes);

            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportASXI3dGeoRefIdCategoryType()
        {
            var command = CreateCommand("[dbo].[sp_GetExportASXI3dGeoRefIdCategoryType]", System.Data.CommandType.StoredProcedure);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportASXI3dGeoRefIdTbTzStrip(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportASXI3dGeoRefIdTbTzStrip]", System.Data.CommandType.StoredProcedure);
            command.CommandTimeout = 0;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportCESHTSEGeoRefIds(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportCESHTSEGeoRefIds]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
    }
}
