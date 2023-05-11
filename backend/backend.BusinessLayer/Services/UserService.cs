using AutoMapper;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers;
using backend.Helpers.Portal;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Manage;
using backend.Mappers.DataTransferObjects.User;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
using backend.DataLayer.Authentication;
using backend.Mappers.DataTransferObjects.Task;
using backend.DataLayer.Models.Build;

namespace backend.BusinessLayer.Services
{
    public class UserService : IUserService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public UserService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task<IEnumerable<UserListDTO>> GetAllUsers()
        {
            using var context = _unitOfWork.Create;
            List<User> users = await context.Repositories.UserRepository.FilterAsync("IsDeleted", false);
            return _mapper.Map<List<UserListDTO>>(users);
        }
        public async Task<UserListDTO> GetUser(string userName)
        {
            using var context = _unitOfWork.Create;
            var record = await context.Repositories.Simple<User>().FirstAsync("UserName", userName);
            return _mapper.Map<User, UserListDTO>(record);
        }
        public async Task<DataCreationResultDTO> CreateUser(FormCreateUserDTO createUserDTO)
        {
            try
            {
                if (createUserDTO == null) return new DataCreationResultDTO { IsError = true, Message = "invalid form data" };
                if (createUserDTO.UserName == null) return new DataCreationResultDTO { IsError = true, Message = "invalid username" };
                using var context = _unitOfWork.Create;
                User user = await context.Repositories.UserRepository.FindByStringDataPropertyAsync("UserName", createUserDTO.UserName);
                if (user != null)
                {
                    if (user.UserName == createUserDTO.UserName)
                    {
                        return new DataCreationResultDTO { IsError = true, Message = Constants.UserNameExists };
                    }
                    if (user.Email == createUserDTO.Email)
                    {
                        return new DataCreationResultDTO { IsError = true, Message = Constants.EmailExists };
                    }
                }
                user = _mapper.Map<FormCreateUserDTO, User>(createUserDTO);
                user.PasswordHash = GenerateRandomPassword.GeneratePassword(Convert.ToInt32(
                PortalConfiguration.Instance.MinUserPassLenght.Value));
                user.IsPasswordChangeRequired = true;
                //Have to implement logic for operator assignment
                user.DateCreated = DateTimeOffset.Now;
                user.LastResetDate = DateTimeOffset.Now;
                user.DateModified = DateTimeOffset.Now;
                await context.Repositories.UserRepository.InsertAsync(user);
                await context.SaveChanges();
                var result = await context.Repositories.UserRepository.FindByStringDataPropertyAsync("Email", user.Email);
                return new DataCreationResultDTO { Id = result.Id };
            }

            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<DataCreationResultDTO> RemoveUser(string username)
        {
            if (username == null) return new DataCreationResultDTO { IsError = true, Message = "invalid username" };
            using var context = _unitOfWork.Create;
            User user = await context.Repositories.UserRepository.FindByStringDataPropertyAsync("UserName", username);
            if (user == null)
            {
                return new DataCreationResultDTO { IsError = true, Message = Constants.UserNameDoesNotExists };
            }
            //Any logic required for blacklisting token? (As per Stage API)
            user.IsDeleted = true;
            await context.Repositories.UserRepository.UpdateAsync(user);
            await context.SaveChanges();

            return new DataCreationResultDTO { Id = user.Id };
        }

        public async Task<IEnumerable<UserClaims>> GetClaimsByUserId(Guid userId)
        {
            using var context = _unitOfWork.Create;
            var userClaims = await context.Repositories.UserClaimsRepository.GetClaimsByUserId(userId);
            return userClaims;
        }
        public async Task<IEnumerable<UserRoles>> GetRolesByUserId(Guid userId)
        {
            using var context = _unitOfWork.Create;
            var userRoles = await context.Repositories.UserRolesRepository.GetRolesByUserId(userId);
            return userRoles;
        }


        public AvailableServicesDTO GetAvailableServices(PortalJWTPayload token)
        {
            AvailableServicesDTO result = new AvailableServicesDTO() { Airshow = false, Stage = false };

            result.Airshow = token.Claims.Where(x => x.Type == "ACE").Count() > 0;
            result.Stage = token.Claims.Where(x => x.Type != "ACE").Count() > 0;

            return result;
        }

        public async Task<IEnumerable<BuildsDTO>> GetBuildTasksByUserId(Guid userId, bool currentBuild)
        {
            using var context = _unitOfWork.Create;
            var builds = await context.Repositories.TaskRepository.GetBuildTasksForUser(userId, currentBuild);
            return _mapper.Map<List<BuildsDTO>>(builds);
        }
    }
}
