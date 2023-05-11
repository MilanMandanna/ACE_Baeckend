using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IInfoSpellingRepository: ISimpleRepository<InfoSpelling>
    {

        Task<SqlDataReader> GetExportSpellingsForConfig(int configurationId, List<Language> languages);

    }
}
