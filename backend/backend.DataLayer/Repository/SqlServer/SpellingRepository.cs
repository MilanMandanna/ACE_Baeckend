using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    public class SpellingRepository : SimpleRepository<Spelling>, ISpellingRepository
    {
        public SpellingRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }

        public async Task<SqlDataReader> GetExportAS4000Spellings(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportAS4000Spellings]", System.Data.CommandType.StoredProcedure);

            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportCESHTSESpellings(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportCESHTSESpellings]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
              command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportCESHTSESpellingsTrivia(int configurationId,List<Language> languages)
        {
            string languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));

            var command = CreateCommand("[dbo].[sp_GetExportCESHTSESpellingsTrivia]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@languages", languageCodes);

            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportDataAS4000DestinationSpelling(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportDataAS4000DestinationSpelling]", System.Data.CommandType.StoredProcedure);

            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportThalesPNameTriva(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportThalesPNameTriva]", System.Data.CommandType.StoredProcedure);

            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportThalesSpellings(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_GetExportThalesSpellings]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportSpellings(int configurationId, List<Language> languages)
        {
            string languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));

            var command = CreateCommand("[dbo].[sp_GetExportSpellings]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@languages", languageCodes);

            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }
    }
}
