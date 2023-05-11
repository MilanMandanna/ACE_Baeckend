using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Contracts.Content
{
    public interface ICountryService
    {
        Task<IEnumerable<Country>> GetAllCountries(int configurationId);
        Task<CountryInfo> GetCountryInfo(int configurationId, int countryId);
        Task<IEnumerable<Language>> GetSelectedLanguages(int configurationId);
        Task<DataCreationResultDTO> AddCountry(int configurationId, CountryInfo countryInfo);
        Task<DataCreationResultDTO> UpdateCountry(int configurationId, CountryInfo countryInfo);

    }
}
