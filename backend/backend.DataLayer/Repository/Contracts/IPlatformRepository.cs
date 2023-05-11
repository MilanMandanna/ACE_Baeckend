using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IPlatformRepository :
        IInsertAsync<Platform>,
        IUpdateAsync<Platform>,
        IFindAllAsync<Platform>,
        IFilterAsync<Platform>,
        IDeleteAsync<Platform>
    {
    }
}
