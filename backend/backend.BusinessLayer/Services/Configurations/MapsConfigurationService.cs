using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Services.Configurations
{
    public class MapsConfigurationService : IMapsConfigurationService
    {

        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;

        public MapsConfigurationService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

       

        /// <summary>
        /// Generalised funtion for getting the data for the xml section.
        /// refer https://alm.rockwellcollins.com/wiki/pages/viewpage.action?pageId=584077917 , simple API for possibel "section"
        /// parameter values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="section"></param>
        /// <returns></returns>
        public async Task<Dictionary<string, object>> GetConfigurationFor(int configurationId, string section)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.MapsConfigurationRepository.GetConfigurationFor(configurationId, section);
            return result;
        }

        /// <summary>
        /// Fecth all the layer info form the tblMenu.Layers, category/item tag
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<Layer>> GetLayers(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.MapsConfigurationRepository.GetLayers(configurationId);
            return result;
        }

        /// <summary>
        /// Funtion to update the Layer details in the tblMenu.Layers, category/item tag
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="layerData"> Layer item to be updated with active and enable values</param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateLayer(int configurationId, Layer layerData)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.MapsConfigurationRepository.UpdateLayer(configurationId,layerData);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Layer is updated" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Updating Layer" };
        }

        /// <summary>
        /// Generalised funtion for updating the data for the xml section.
        /// refer https://alm.rockwellcollins.com/wiki/pages/viewpage.action?pageId=584077917 , simple API for possibel "section", "name" and "value"
        /// parameter values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="section"></param>
        /// <returns></returns>

        public async Task<DataCreationResultDTO> UpdateSectionData(int configurationId, string section, string name, string value)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.MapsConfigurationRepository.UpdateSectionData(configurationId, section, name, value);
            if (result.Item1 > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Config section is updated" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Updating Config " + result.Item2 };
        }

        public async Task<bool> GetProductLevelConfigDetails(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.MapsConfigurationRepository.GetProductLevelConfigDetails(configurationId);
        }
    }
}
