using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IModesConfigurationRepository :
      IInsertAsync<ConfigModeDefs>

    {
        Task<IEnumerable<Mode>> GetAllModes(int configurationId);
        Task<(int, string)> AddMode(int configurationId, Mode modeData);
        Task<int> AddModeItem(int configurationId, Mode modeData);
        Task<int> RemoveMode(int configurationId, string modeId);
        Task<IEnumerable<Mode>> GetMode(int configurationId, string modeId);
        Task<int> GetNextModeDefID();
        Task<int> InsetNewMode(Mode modeData);
        Task<int> GetMaxModeDefID(int configurationId);


    }
}
