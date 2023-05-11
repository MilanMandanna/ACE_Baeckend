using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IConfigurationComponentsRepository :
        IInsertAsync<ConfigurationComponents>,
        IUpdateAsync<ConfigurationComponents>,
        IDeleteAsync<ConfigurationComponents>,
        IFilterAsync<ConfigurationComponents>
    {
        Task<int> AddConfigurationComponent(string azurePath, int configCompID, string configCompName);

        Task<IEnumerable<ConfigurationComponents>> GetCofigurationComponentsArtifacts(int configurationID);
    }
}
