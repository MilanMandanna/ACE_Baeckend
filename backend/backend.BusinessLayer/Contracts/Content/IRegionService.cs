using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Contracts.Content
{
    public interface IRegionService
    {
        Task<IEnumerable<Region>> GetAllRegions(int configurationId);
        Task<RegionInfo> GetRegionInfo(int configurationId, int regionId);
        Task<DataCreationResultDTO> AddRegion(int configurationId, RegionInfo regionInfo);
        Task<DataCreationResultDTO> UpdateRegion(int configurationId, RegionInfo regionInfo);
    }
}
