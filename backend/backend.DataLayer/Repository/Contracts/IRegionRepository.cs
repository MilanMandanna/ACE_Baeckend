using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IRegionRepository
    {
        Task<IEnumerable<Region>> GetAllRegions(int configurationId);
        Task<RegionInfo> GetRegionInfo(int configurationId, int regionId);
        Task<int> UpdateRegion(int configurationId, int regionId, int languageId, string regionName);
        Task<int> AddRegion(int configurationId, string regionName);
        Task<int> AddRegionDetails(int configurationId, int regionId, int languageId, string regionName);
    }
}