using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ISpellingRepository : ISimpleRepository<Spelling>
    {
        Task<SqlDataReader> GetExportAS4000Spellings(int configurationid);
        Task<SqlDataReader> GetExportDataAS4000DestinationSpelling(int configurationId);
        Task<SqlDataReader> GetExportCESHTSESpellings(int configurationId);
        Task<SqlDataReader> GetExportCESHTSESpellingsTrivia(int configurationId, List<Language> languages);
        Task<SqlDataReader> GetExportThalesPNameTriva(int configurationId);
        Task<SqlDataReader> GetExportThalesSpellings(int configurationId);
        Task<SqlDataReader> GetExportSpellings(int configurationId, List<Language> languages);

    }
}
