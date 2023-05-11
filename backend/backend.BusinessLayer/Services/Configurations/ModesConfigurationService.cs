using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.Repository.SqlServer.Queries;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Services.Configurations
{
    public class ModesConfigurationService : IModesConfigurationService
    {

        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;

        public ModesConfigurationService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        /// <summary>
        /// Get all the mode details under <mode_defs> tag
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<Mode>> GetAllModes(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ModesConfigurationRepository.GetAllModes(configurationId);
        }

        /// <summary>
        /// If the mapping with guven configuration id is not present, insert new mode and create a mapping.
        /// else check if the mode item is alreday present and add the new mode. mode item id need not be sent from the front-end.
        /// it is calculated as max() existing mode items id + 1
        /// 
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="modeData"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> AddMode(int configurationId, Mode modeData)
        {
            using var context = _unitOfWork.Create;
            var modeConfigurationMapping = await context.Repositories.ModeConfigurationMappingRepository.FilterAsync("ConfigurationID", configurationId);
            if(modeConfigurationMapping.Count() > 0)
            {
                var maxModeId = await context.Repositories.ModesConfigurationRepository.GetMaxModeDefID(configurationId);
                modeData.Id = (maxModeId + 1).ToString();
                var result = await context.Repositories.ModesConfigurationRepository.AddMode(configurationId, modeData);
                if(result.Item1 > 0)
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = result.Item2 };
                } else
                {
                    return new DataCreationResultDTO { IsError = true, Message = result.Item2 };
                }

            } else
            {
                var insertResult = await context.Repositories.ModesConfigurationRepository.InsetNewMode(modeData);

                if(insertResult > 0)
                {
                    await context.SaveChanges();
                     var modeDefID = await context.Repositories.ModesConfigurationRepository.GetNextModeDefID();

                    var modeDefMapping = new ModeConfigurationMapping()
                    {
                        ConfigurationID = configurationId,
                        ModeDefID = modeDefID,
                        PreviousModeDefID = null,
                        IsDeleted = false,
                        Action = null
                    };
                    using var Updatecontext = _unitOfWork.Create;
                    await Updatecontext.Repositories.ModeConfigurationMappingRepository.InsertAsync(modeDefMapping);
                    await Updatecontext.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "New Mode has been added" };
                }
                return new DataCreationResultDTO { IsError = true, Message = "Error adding new Mode"};

            }



        }

        /// <summary>
        /// removed mode with given id
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="modeId"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> RemoveMode(int configurationId, string modeId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ModesConfigurationRepository.RemoveMode(configurationId, modeId);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Mode has been Deleted" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Deleting Mode" };
        }

        /// <summary>
        /// Update mode, removes the existing mode and adds the given mode as the order of modes is not important
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="modeData"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateMode(int configurationId, Mode modeData)
        {
            using var context = _unitOfWork.Create;
            var modes = await context.Repositories.ModesConfigurationRepository.GetMode(configurationId, modeData.Id);
            if (modes.Count() == 0)
            {
                return new DataCreationResultDTO { IsError = true, Message = "Error Updating Mode. Mode not found!" };
            }
            else
            {
                var existingMode = modes.First();
                var removeResult = await context.Repositories.ModesConfigurationRepository.RemoveMode(configurationId, existingMode.Id);
                if (removeResult > 0)
                {
                    var updateResult = await context.Repositories.ModesConfigurationRepository.AddModeItem(configurationId, modeData);
                    if (updateResult > 0)
                    {
                        await context.SaveChanges();
                        return new DataCreationResultDTO { IsError = false, Message = "Mode has been Updated" };
                    }
                }

                return new DataCreationResultDTO { IsError = true, Message = "Error Updating Mode." };
            }
        }
       
      
    }
}
