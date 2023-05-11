using backend.DataLayer.Models;
using backend.DataLayer.Models.Roles_Claims;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Manage;
using backend.Mappers.DataTransferObjects.User;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using backend.DataLayer.Authentication;
using backend.Mappers.DataTransferObjects.Task;
using backend.DataLayer.Models.Build;

namespace backend.BusinessLayer.Contracts
{
    public interface IUserService
    {
        Task<IEnumerable<UserListDTO>> GetAllUsers();
        Task<UserListDTO> GetUser(string userName);
        Task<DataCreationResultDTO> CreateUser(FormCreateUserDTO createUserDTO);
        Task<DataCreationResultDTO> RemoveUser(string username);
        Task<IEnumerable<UserClaims>> GetClaimsByUserId(Guid userId);
        Task<IEnumerable<UserRoles>> GetRolesByUserId(Guid userId);
        Task<IEnumerable<BuildsDTO>> GetBuildTasksByUserId(Guid userId, bool currentBuild);

        AvailableServicesDTO GetAvailableServices(PortalJWTPayload token);

    }
}
