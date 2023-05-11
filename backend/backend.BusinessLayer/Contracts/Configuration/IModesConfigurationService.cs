using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Contracts.Configuration
{
    public interface IModesConfigurationService
    {

        Task<IEnumerable<Mode>> GetAllModes(int configurationId);
        Task<DataCreationResultDTO> RemoveMode(int configurationId, string modeId);
        Task<DataCreationResultDTO> AddMode(int configurationId, Mode modeData);
        Task<DataCreationResultDTO> UpdateMode(int configurationId, Mode modeData);
    }
}
