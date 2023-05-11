using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.SqlServer;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ICountryRepository
    {
        Task<IEnumerable<Country>> GetAllCountries(int configurationId);
        Task<CountryInfo> GetCountryInfo(int configurationId, int countryId);
        Task<IEnumerable<Language>> GetSelectedLanguages(int configurationId);
        Task<int> UpdateCountry(int configurationId,int countryId,string description,int regionId);
        Task<int> AddCountryDetails(int configurationId, int countryId, int languageId, string countryName);
        Task<int> AddCountry(int configurationId, string description, int regionId);
        Task<int> UpdateCountrySpelling(int configurationId, int spellingId, int languageId, string countryName);

    }
}
