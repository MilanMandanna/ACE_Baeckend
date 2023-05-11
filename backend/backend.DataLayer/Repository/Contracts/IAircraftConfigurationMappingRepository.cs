using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IAircraftConfigurationMappingRepository :
        IInsertAsync<AircraftConfigurationMapping>,
        IFilterAsync<AircraftConfigurationMapping>,
        IUpdateAsync<AircraftConfigurationMapping>,
        IDeleteAsync<AircraftConfigurationMapping>,
        IFindAllAsync<AircraftConfigurationMapping>
    {
        
    }
}
