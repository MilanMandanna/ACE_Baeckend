using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using AutoMapper;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Services.Configurations
{
    public class TickerConfigurationService : ITickerConfigurationService
    {

        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;

        public TickerConfigurationService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        /// <summary>
        /// Get all the ticker attributes for <ticker></ticker> tag. 
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns>Dictionary of visibility,position and ticker speed</returns>
        public async Task<Dictionary<string, object>> GetTicker(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.TickerConfigurationRepository.GetTicker(configurationId);
            return result;
        }

        /// <summary>
        /// Updates the ticker attributes for <ticker></ticker> tag.
        /// Attrivutes are visibility,position and ticker speed
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="name"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateTicker(int configurationId, string name, string value)
        {
            using var context = _unitOfWork.Create;
            if (await context.Repositories.TickerConfigurationRepository.CheckAndCreateTicker(configurationId) > 0)
            {
                var result = await context.Repositories.TickerConfigurationRepository.UpdateTicker(configurationId, name, value);
                if (result > 0)
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Ticker is updated" };

                }
            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Updating the Ticker" };
        }

        /// <summary>
        /// Get the ticker parameters from /infoItems/infoItem where "ticker" = true.
        /// Ticker names and Ticker display names are present in the tblFeatureSet.
        /// External mapping has been done to map the tickernames to display names 
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<TickerParameter>> GetSelectedTickerParameters(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var allParams = await context.Repositories.TickerConfigurationRepository.GetAllTickerParameters(configurationId);
            var selectedParams = await context.Repositories.TickerConfigurationRepository.GetSelectedTickerParameters(configurationId);
            List<string> names = allParams.Select(param => param.Name).ToArray().ToList();
            List<TickerParameter> result = new List<TickerParameter>();
            foreach (string param in selectedParams)
            {
                if (names.Contains(Regex.Replace(param, @"\t|\n|\r", "")))
                {
                    result.Add(allParams.Where(x => x.Name.Equals(Regex.Replace(param, @"\t|\n|\r", ""))).First());
                }
            }
            return result;
        }

        /// <summary>
        /// Get the super set of all posible ticker items. This list is populated from tblfeatureSet ticker-parameters.
        /// Also, it is mapped to ticker-parameter-display to get the display name for the UI
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<TickerParameter>> GetAllTickerParameters(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var allParams = await context.Repositories.TickerConfigurationRepository.GetAllTickerParameters(configurationId);
            return allParams;
        }

        /// <summary>
        /// Adding new ticker parameter into /infoItems/infoIetm tag.
        /// If the ticker item with the same name exists and "ticker" value is false, funtion updates the "ticker" attribute to true.
        /// Otherwise, adds the new ticker item
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="tickerData"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> AddTickerParameter(int configurationId, TickerParameter[] tickerData)
        {
            using var context = _unitOfWork.Create;
            int addresult = 0;
            List<string> tickerParameters = tickerData.Select(param => param.Name).ToArray().ToList();
            addresult = await context.Repositories.TickerConfigurationRepository.AddTickerParameters(configurationId, tickerParameters);
            if (addresult > 0 )
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Ticker item has been Added" };

            }                
            
            return new DataCreationResultDTO { IsError = true, Message = "Error adding Ticker item" };
        }


        /// <summary>
        /// Updates the ticker item node with given ticker name by changing the "ticker" to false
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="tickerData"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> RemoveTickerParameter(int configurationId, int position)
        {
            using var context = _unitOfWork.Create;
            var selectedParams = await context.Repositories.TickerConfigurationRepository.GetSelectedTickerParameters(configurationId);
            var count = selectedParams.Where(param => Regex.Replace(param, @"\t|\n|\r", "").Equals(Regex.Replace(selectedParams.ElementAt(position), @"\t|\n|\r", ""))).Count();
            if (count == 0)
            {
                return new DataCreationResultDTO { IsError = true, Message = "Ticker Does not exist" };
            }
            else
            {
                var result = await context.Repositories.TickerConfigurationRepository.RemoveTickerParameter(configurationId, position);
                if (result > 0)
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Ticker item has been Deleted" };

                }
            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Deleting Ticker item" };

        }
        /// <summary>
        /// Moves ticker parameter position. position is 0 based.
        /// if the toPosition < 0, the item is moved to 0th position.
        /// if the toPosition > number of ticker info items, item is moved to last position.
        /// Similar assumption the fromPosition
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="fromPosition"></param>
        /// <param name="toPosition"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> MoveTickerParameterPosition(int configurationId, int fromPosition, int toPosition)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.TickerConfigurationRepository.MoveTickerParameterPosition(configurationId, fromPosition, toPosition);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Ticker item position updated" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error updating Ticker item position" };

        }
    }
}
