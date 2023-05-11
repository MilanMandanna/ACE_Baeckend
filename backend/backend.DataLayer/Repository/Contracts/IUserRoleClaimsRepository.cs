using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IUserRoleClaimsRepository : IInsertAsync<UserRoleClaims>,
        IUpdateAsync<UserRoleClaims>,
        IFindAllAsync<UserRoleClaims>,
        IFindByIDAsync<UserRoleClaims>,
        IFindObsoleteAsync<UserRoleClaims>,
        IDeleteAsync<UserRoleClaims>,
        IFindByStringDataPropertyAsync<UserRoleClaims>
    {
        Task<int> GetClaimsCountByRoleId(Guid roleId, Guid claimId);      
        Task<IEnumerable<UserRoleClaimsDetail>> GetUserRoleClaims(Guid roleId, Guid claimId);
        Task<int> GetRoleClaimMapByUserIdOperatorRoleIdClaimId(Guid operatorManageOrViewRoleId, Guid userId, Guid claimId);
        Task<List<object>> GetScopeValueForClaim(Guid roleId, Guid claimId, string scopeType);
        Task<List<object>> GetScopeValueForUser(Guid userId, Guid claimId, string scopeType);
        Task<IEnumerable<UserRoleClaims>> GetClaimsForUserWithAircraftsConfigurations(Guid userId);

    }
}
