using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IProductConfigurationMappingRepository :
        IFilterAsync<ProductConfigurationMapping>,
        IInsertAsync<ProductConfigurationMapping>,
        IDeleteAsync<ProductConfigurationMapping>
    {
    }
}
