using backend.DataLayer.Models;
using backend.DataLayer.Repository.Contracts.Actions;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IOperatorRepository : IInsertAsync<Operator>,
        IUpdateAsync<Operator>,
        IFindAllAsync<Operator>,
        IFindByIDAsync<Operator>,
        IFindObsoleteAsync<Operator>,
        IDeleteAsync<Operator>,
        IFindByStringDataPropertyAsync<Operator>,
        IFilterAsync<Operator>
    {
    }
}
