using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Contracts.Configuration
{
    public interface IMapsConfigurationService
    {
        Task<Dictionary<string, object>> GetConfigurationFor(int configurationId, string section);
        Task<DataCreationResultDTO> UpdateSectionData(int configurationId, string section, string name, string value);
        Task<IEnumerable<Layer>> GetLayers(int configurationId);
        Task<DataCreationResultDTO> UpdateLayer(int configurationId, Layer layerData);
        Task<bool> GetProductLevelConfigDetails(int configurationId);
    }
}
