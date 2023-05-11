using System;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IModeConfigurationMappingRepository :
        IInsertAsync<ModeConfigurationMapping>,
        IUpdateAsync<ModeConfigurationMapping>,
        IFindAllAsync<ModeConfigurationMapping>,
        IFilterAsync<ModeConfigurationMapping>
    {
    }
}
