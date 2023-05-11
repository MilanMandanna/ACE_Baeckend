using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using backend.BusinessLayer.Contracts.Content;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Services.Content
{
    public class CountryService : ICountryService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;
        public CountryService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<IEnumerable<Country>> GetAllCountries(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var countries = await context.Repositories.CountryRepository.GetAllCountries(configurationId);
            return countries;
        }

        public async Task<CountryInfo> GetCountryInfo(int configurationId, int countryId)
        {
            using var context = _unitOfWork.Create;
            var country = await context.Repositories.CountryRepository.GetCountryInfo(configurationId,countryId);
            return country;
        }

        public async Task<IEnumerable<Language>> GetSelectedLanguages(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var languages = await context.Repositories.CountryRepository.GetSelectedLanguages(configurationId);
            return languages;

        }

        public async Task<DataCreationResultDTO> UpdateCountry(int configurationId, CountryInfo countryInfo)
        {
            using var context = _unitOfWork.Create;
            List<int> results = new List<int>();
            var CountryResult = await context.Repositories.CountryRepository.UpdateCountry(configurationId, countryInfo.CountryID, countryInfo.Description, countryInfo.RegionID);
            if (CountryResult > 0)
            {
                foreach (var countryNameInfo in countryInfo.names)
                {
                    var result = await context.Repositories.CountryRepository.UpdateCountrySpelling(configurationId, countryNameInfo.CountrySpellingID,
                        countryNameInfo.LanguageID, countryNameInfo.CountryName);
                    results.Add(result);
                }
                if (results.Any(result => result < 0) || results.Any(result => result == 0))
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Error updating country details!" };
                }
                else
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Country Details Updated Successfully!" };
                }
            }
            else
                return new DataCreationResultDTO { IsError = true, Message = "Error updating country details!" };
        }

        public async Task<DataCreationResultDTO> AddCountry(int configurationId, CountryInfo countryInfo)
        {
            using var context = _unitOfWork.Create;
            List<int> results = new List<int>();
            var countryId = await context.Repositories.CountryRepository.AddCountry(configurationId, countryInfo.Description, countryInfo.RegionID);
            if(countryId < 0)
            {
                return new DataCreationResultDTO { IsError = true, Message = "Error Adding country!" };
            } else
            {
                foreach (var countryNameInfo in countryInfo.names)
                {
                    var result = await context.Repositories.CountryRepository.AddCountryDetails(configurationId, countryId,
                        countryNameInfo.LanguageID, countryNameInfo.CountryName);
                    results.Add(result);
                }
                if (results.Any(result => result < 0) || results.Any(result => result == 0))
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Error Adding country!" };
                }
                else if (results.Any(result => result == 3))
                {
                    return new DataCreationResultDTO { IsError = true, Message = "country Already Exists!" };
                }
                else
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "New Country Added Successfully!" };
                }
            }

           
        }
    }
}
