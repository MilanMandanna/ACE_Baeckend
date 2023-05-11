using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IUserClaimsRepository : IInsertAsync<UserClaims>,
        IUpdateAsync<UserClaims>,
        IFindAllAsync<UserClaims>,
        IFindByIDAsync<UserClaims>,
        IFindObsoleteAsync<UserClaims>,
        IDeleteAsync<UserClaims>,
        IFindByStringDataPropertyAsync<UserClaims>
    {
        Task<IEnumerable<UserClaims>> GetClaimsByRoleId(Guid roleId);
        Task<IEnumerable<UserClaims>> GetClaimsByUserId(Guid userId);
    }
}
