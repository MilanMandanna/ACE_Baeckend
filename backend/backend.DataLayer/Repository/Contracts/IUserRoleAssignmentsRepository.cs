using backend.DataLayer.Models;
using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IUserRoleAssignmentsRepository : IInsertAsync<UserRoleAssignments>,
        IUpdateAsync<UserRoleAssignments>,
        IFindAllAsync<UserRoleAssignments>,
        IFindByIDAsync<UserRoleAssignments>,
        IFindObsoleteAsync<UserRoleAssignments>,
        IDeleteAsync<UserRoleAssignments>,
        IFindByStringDataPropertyAsync<UserRoleAssignments>
    {
        Task<int> GetCountByUserIdRoleId(Guid userId, Guid roleId);
        Task<IEnumerable<User>> GetUsersByRoleId(Guid roleId);
        Task<int> RemoveRoleAssignmentByUserId(Guid userId, Guid? manageRoleId, Guid? viewRoleId);
        Task<int> RemoveRoleAssignmentByUserId(Guid userId, Guid roleId);
    }
}
