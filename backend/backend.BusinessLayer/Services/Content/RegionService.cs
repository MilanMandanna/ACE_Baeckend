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
    public class RegionService : IRegionService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;
        public RegionService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        
        public async Task<IEnumerable<Region>> GetAllRegions(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var regions = await context.Repositories.RegionRepository.GetAllRegions(configurationId);
            return regions;
        }

        public async Task<RegionInfo> GetRegionInfo(int configurationId, int regionId)
        {
            using var context = _unitOfWork.Create;
            var region = await context.Repositories.RegionRepository.GetRegionInfo(configurationId, regionId);
            return region;
        }

        public async Task<DataCreationResultDTO> UpdateRegion(int configurationId, RegionInfo regionInfo)
        {
            using var context = _unitOfWork.Create;
            List<int> results = new List<int>();
            foreach (var regionNameInfo in regionInfo.names)
            {
                var result = await context.Repositories.RegionRepository.UpdateRegion(configurationId,regionInfo.RegionID,regionNameInfo.LanguageID,regionNameInfo.RegionName);
                results.Add(result);
            }
            if (results.Any(result => result < 0) || results.Any(result => result == 0))
            {
                return new DataCreationResultDTO { IsError = true, Message = "Error updating Region details!" };
            }
            else
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Region Details Updated Successfully!" };
            }
        }

        public async Task<DataCreationResultDTO> AddRegion(int configurationId, RegionInfo regionInfo)
        {
            using var context = _unitOfWork.Create;
            List<int> results = new List<int>();
            var regionId = await context.Repositories.RegionRepository.AddRegion(configurationId, "");
            if(regionId < 0)
            {
                return new DataCreationResultDTO { IsError = true, Message = "Error Adding Region!" };
            } else
            {
                foreach (var regionNameInfo in regionInfo.names)
                {
                    var result = await context.Repositories.RegionRepository.AddRegionDetails(configurationId,regionId, regionNameInfo.LanguageID, regionNameInfo.RegionName);
                    results.Add(result);
                }
                if (results.Any(result => result < 0) || results.Any(result => result == 0))
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Error Adding Region!" };
                }
                else if(results.Any(result => result == 3))
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Region Already Exists!" };
                }
                else
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Region Added Successfully!" };
                }
            }
           
        }

    }
}
