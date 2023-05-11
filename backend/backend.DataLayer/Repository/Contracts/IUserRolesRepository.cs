using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IUserRolesRepository : IInsertAsync<UserRoles>,
        IUpdateAsync<UserRoles>,
        IFindAllAsync<UserRoles>,
        IFindByIDAsync<UserRoles>,
        IFindObsoleteAsync<UserRoles>,
        IDeleteAsync<UserRoles>,
        IFindByStringDataPropertyAsync<UserRoles>
    {
        Task<IEnumerable<UserRoles>> GetRolesByUserId(Guid userId);
    }
}
