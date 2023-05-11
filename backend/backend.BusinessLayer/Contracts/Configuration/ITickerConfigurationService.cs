using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Contracts.Configuration
{
    public interface ITickerConfigurationService
    {

        Task<Dictionary<string, object>> GetTicker(int configurationId);
        Task<DataCreationResultDTO> UpdateTicker(int configurationId, string name, string value);
        Task<IEnumerable<TickerParameter>> GetSelectedTickerParameters(int configurationId);
        Task<IEnumerable<TickerParameter>> GetAllTickerParameters(int configurationId);
        Task<DataCreationResultDTO> AddTickerParameter(int configurationId, TickerParameter[] tickerData);
        Task<DataCreationResultDTO> RemoveTickerParameter(int configurationId, int position);
        Task<DataCreationResultDTO> MoveTickerParameterPosition(int configurationId, int fromPosition, int toPosition);

    }
}
