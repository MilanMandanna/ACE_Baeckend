using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ITickerConfigurationRepository
    {

        Task<Dictionary<string, object>> GetTicker(int configurationId);
        Task<int> UpdateTicker(int configurationId, string name, string value);
        Task<IEnumerable<string>> GetSelectedTickerParameters(int configurationId);
        Task<IEnumerable<TickerParameter>> GetAllTickerParameters(int configurationId);
        Task<int> AddTickerParameters(int configurationId, List<string> tickerParameters);
        Task<int> RemoveTickerParameter(int configurationId, int position);
        Task<int> IsTickerItemDisabled(int configurationId, string tickerParameterName);
        Task<int> MoveTickerParameterPosition(int configurationId, int fromPosition, int toPosition);
        Task<int> CheckAndCreateTicker(int configurationId);
    }
}
