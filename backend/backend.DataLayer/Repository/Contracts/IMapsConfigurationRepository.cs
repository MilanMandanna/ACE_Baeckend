using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IMapsConfigurationRepository
    {
        Task<Dictionary<string, object>> GetConfigurationFor(int configurationId, string section);
        Task<(int,string)> UpdateSectionData(int configurationId, string section, string name, string value);
        Task<IEnumerable<Layer>> GetLayers(int configurationId);
        Task<int> UpdateLayer(int configurationId, Layer layeData);
        Task<bool> GetProductLevelConfigDetails(int configurationId);
    }
}
