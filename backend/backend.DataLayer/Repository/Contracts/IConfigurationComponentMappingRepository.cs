using System;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IConfigurationComponentMappingRepository :
        IInsertAsync<ConfigurationComponentMapping>,
        IUpdateAsync<ConfigurationComponentMapping>,
        IFindAllAsync<ConfigurationComponentMapping>,
        IFilterAsync<ConfigurationComponentMapping>
    {
       
    }

}
