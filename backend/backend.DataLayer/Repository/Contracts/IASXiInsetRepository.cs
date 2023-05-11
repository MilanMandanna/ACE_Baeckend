using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IASXiInsetRepository : IInsertAsync<ASXiInset>,
        IUpdateAsync<ASXiInset>,
        IDeleteAsync<ASXiInset>,
        IFilterAsync<ASXiInset>
    {
        Task<int> AddASXiInset(int configurationId, ASXiInset _mapInset, Guid userId);

        Task<List<ASXiInset>> GetASXiInsets(int configurationID);
    }
}
