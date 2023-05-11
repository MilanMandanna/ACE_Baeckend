using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Contracts.CustomContent
{
    public interface IAirportService
    {
        Task<IEnumerable<Airport>> getAllAirports(int configurationId);
        Task<DataCreationResultDTO> UpdateAirport(int configurationId, Airport airportInfo,Guid userId);
        Task<DataCreationResultDTO> AddAirport(int configurationId, Airport airportInfo);
        Task<IEnumerable<CityInfo>> GetAllCities(int configurationId);

    }
}
