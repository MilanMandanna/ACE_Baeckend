using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ICountrySpellingRepository : ISimpleRepository<CountrySpelling>
    {
        Task<SqlDataReader> GetAllCountrySpellings(int configurationId, List<Language> languages);
        Task<SqlDataReader> GetAS4000CountrySpellings(int configurationId);
        Task<SqlDataReader> GetASXI3dCountryData(int configurationId, List<Language> languages);
    }
}
