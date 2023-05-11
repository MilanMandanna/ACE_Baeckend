using backend.Mappers.DataTransferObjects.CustomContent;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IMapPackageService
    {
        Task<IEnumerable<CityDTO>> GetCities(int configurationId);
    }
}
