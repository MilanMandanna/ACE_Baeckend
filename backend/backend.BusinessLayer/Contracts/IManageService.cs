using backend.DataLayer.Models.Roles_Claims;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Manage;
using backend.Mappers.DataTransferObjects.User;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IManageService
    {
        Task<List<AdminRoleDTO>> GetAllRoles();
        Task<AdminRoleDTO> GetRoleById(Guid roleId);
        Task<IEnumerable<ClaimsListDTO>> GetClaimsByRoleId(Guid roleId);
        Task<List<UserClaims>> GetAllClaims();
        Task<DataCreationResultDTO> AddClaimToRoleAssignment(FormCreateClaimToRoleAssignmentDTO formData);
        Task<DataCreationResultDTO> RemoveClaimToRoleAssignment(FormRemoveClaimToRoleAssignmentDTO formData);
        Task<IEnumerable<UserListDTO>> GetUsersByRoleId(Guid roleId);
        Task<DataCreationResultDTO> AddUserToRole(Guid roleId, Guid userId);
        Task<DataCreationResultDTO> RemoveUserFromRole(Guid roleId, Guid userId);
        Task<DataCreationResultDTO> AddRole(FormCreateRoleDTO formData);
        Task<DataCreationResultDTO> UpdateRole(Guid roleId, FormCreateRoleDTO formData);
        Task<DataCreationResultDTO> RemoveRole(Guid roleId);
    }
}
