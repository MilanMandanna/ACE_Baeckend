using System;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ITriggerConfigurationMappingRepository :
        IInsertAsync<TriggerConfigurationMapping>,
        IUpdateAsync<TriggerConfigurationMapping>,
        IFindAllAsync<TriggerConfigurationMapping>,
        IFilterAsync<TriggerConfigurationMapping>
    {
    }
}
