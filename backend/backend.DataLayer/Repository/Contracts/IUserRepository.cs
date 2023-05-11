using backend.DataLayer.Models;
using backend.DataLayer.Repository.Contracts.Actions;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{

    public enum ObjectType
    {
        Aircraft,
        Operator,
        Configuration,
        ProductType
    }
    public interface IUserRepository : IInsertAsync<User>,
        IFilterAsync<User>,
        IUpdateAsync<User>,
        IFindAllAsync<User>,
        IFindByIDAsync<User>,
        IFindObsoleteAsync<User>,
        IDeleteAsync<User>,
        IFindByStringDataPropertyAsync<User>
    {       

        Task<IEnumerable<User>> GetUsersByObjectType(Guid objectID, Guid manageOperatorClaimID, Guid viewOperatorID, ObjectType objectType);

    }
}
