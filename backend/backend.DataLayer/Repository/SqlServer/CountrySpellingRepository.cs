using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using backend.DataLayer.Repository.SqlServer.Queries;

namespace backend.DataLayer.Repository.SqlServer
{
    public class CountrySpellingRepository : SimpleRepository<CountrySpelling>, ICountrySpellingRepository
    {

        public CountrySpellingRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }
        public async Task<SqlDataReader> GetAllCountrySpellings(int configurationId, List<Language> languages)
        {
            string languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));
            //string sql = QueryCountrySpelling.SQL_GetAllCountrySpellings.Replace("{languageCodes}", languageCodes);
            var command = CreateCommand("sp_GetAllCountrySpellings", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@languageCodes", languageCodes);
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
        public async Task<SqlDataReader> GetAS4000CountrySpellings(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetAS4000CountrySpellings]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetASXI3dCountryData(int configurationId,List<Language> languages)
        {
            string languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));
            var command = CreateCommand("[dbo].[sp_GetASXI3dCountryData]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@languages", languageCodes);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
    }
}
