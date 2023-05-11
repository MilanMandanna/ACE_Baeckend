using AutoMapper;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Manage;
using backend.Mappers.DataTransferObjects.User;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Linq;

namespace backend.BusinessLayer.Services
{
    public class ManageService : IManageService

    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public ManageService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task<List<AdminRoleDTO>> GetAllRoles()
        {
            using var context = _unitOfWork.Create;
            List<UserRoles> userRoles = await context.Repositories.UserRolesRepository.FindAllAsync();

            return _mapper.Map<List<AdminRoleDTO>>(userRoles.Where(x => x.Hidden == false));
        }

        public async Task<AdminRoleDTO> GetRoleById(Guid roleId)
        {
            using var context = _unitOfWork.Create;
            UserRoles userRole = await context.Repositories.UserRolesRepository.FindByIdAsync(roleId);
            var dtoData = _mapper.Map<UserRoles, AdminRoleDTO>(userRole);
            IEnumerable<UserClaims> claims = await context.Repositories.UserClaimsRepository.GetClaimsByRoleId(roleId);
            dtoData.Claims = _mapper.Map<IEnumerable<UserClaims>, IEnumerable<AdminClaimDTO>>(claims);
            Dictionary<string, int> scopeIndex = new Dictionary<string, int>();
            foreach (var claim in dtoData.Claims)
            {
                if (claim.ScopeType != null && claim.ScopeType.ToLower().Trim() != "none")
                {
                    //storing the scopetype and index in the dictionary as one claim can have multiple scopes and need to mapped accordingly for the claim
                    List<object> scopeValue = await context.Repositories.UserRoleClaimsRepository.GetScopeValueForClaim(roleId, claim.ID, claim.ScopeType);

                    // backward compat for the front-end, should be fixed in the front-end in the next version.
                    if (claim.ScopeType == "User Role") claim.ScopeType = "Role";
                    if (claim.ScopeType == "Product Type") claim.ScopeType = "ProductType";

                    if(!scopeIndex.ContainsKey(claim.ID+claim.ScopeType)) {
                        claim.ScopeValue = scopeValue[0].ToString();
                        scopeIndex.Add(claim.ID + claim.ScopeType, 1);
                    }
                    else
                    {
                        claim.ScopeValue = scopeValue[scopeIndex[claim.ID + claim.ScopeType]].ToString();
                        scopeIndex[claim.ID + claim.ScopeType] = scopeIndex[claim.ID + claim.ScopeType] + 1;
                    }
                }

            }
            return dtoData;
        }

        public async Task<IEnumerable<ClaimsListDTO>> GetClaimsByRoleId(Guid roleId)
        { 
            using var context = _unitOfWork.Create;
            IEnumerable<UserClaims> userClaims = await context.Repositories.UserClaimsRepository.GetClaimsByRoleId(roleId);
            return _mapper.Map<List<ClaimsListDTO>>(userClaims);

        }

      
        public async Task<List<UserClaims>> GetAllClaims()
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.UserClaimsRepository.FindAllAsync();
        }

        public async Task<DataCreationResultDTO> AddClaimToRoleAssignment(FormCreateClaimToRoleAssignmentDTO formData)
        {
            if (formData == null) return new DataCreationResultDTO { IsError = true, Message = "invalid form data" };
            if (formData.RoleID == null || formData.ClaimID == null) return new DataCreationResultDTO { IsError = true, Message = "invalid form data" };
            using var context = _unitOfWork.Create;
            int recordCount = await context.Repositories.UserRoleClaimsRepository.GetClaimsCountByRoleId(formData.RoleID, formData.ClaimID);
            if (recordCount > 0) return new DataCreationResultDTO { IsError = true, Message = "claim is already assigned in specified role" };

            UserRoleClaims roleClaims = _mapper.Map<UserRoleClaims>(formData);
            await context.Repositories.UserRoleClaimsRepository.InsertAsync(roleClaims);
            await context.SaveChanges();
            return new DataCreationResultDTO { Id = roleClaims.ID };
        }
        public async Task<DataCreationResultDTO> RemoveClaimToRoleAssignment(FormRemoveClaimToRoleAssignmentDTO formData)
        {
            if (formData == null) return new DataCreationResultDTO { IsError = true, Message = "invalid form data" };
            if (formData.RoleID == null || formData.ClaimID == null) return new DataCreationResultDTO { IsError = true, Message = "invalid form data" };
            using var context = _unitOfWork.Create;
            int recordCount = await context.Repositories.UserRoleClaimsRepository.GetClaimsCountByRoleId(formData.RoleID, formData.ClaimID);
            if (recordCount == 1)
            {
                UserRoleClaims roleClaims = (UserRoleClaims)await context.Repositories.UserRoleClaimsRepository.GetUserRoleClaims(formData.RoleID, formData.ClaimID);
                await context.Repositories.UserRoleClaimsRepository.DeleteAsync(roleClaims);
                await context.SaveChanges();
                return new DataCreationResultDTO { Id = roleClaims.ID };
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "invalid form data to remove" };
            }
        }

        public async Task<IEnumerable<UserListDTO>> GetUsersByRoleId(Guid roleId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.UserRoleAssignmentsRepository.GetUsersByRoleId(roleId);
            return _mapper.Map<List<UserListDTO>>(result);
        }

        public async Task<DataCreationResultDTO> AddUserToRole(Guid roleId, Guid userId)
        {
            if (roleId == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid RoleID" };
            if (userId == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid UserID" };

            using var context = _unitOfWork.Create;
            var result = await context.Repositories.UserRoleAssignmentsRepository.GetCountByUserIdRoleId(userId, roleId);
            if (result > 0)
            {
                return new DataCreationResultDTO { IsError = true, Message = "User is already existing in the Role" };
            }
            else
            {
                UserRoleAssignments userRoleAssignments = new UserRoleAssignments
                {
                    UserID = userId,
                    RoleID = roleId
                };
                var addResult = await context.Repositories.UserRoleAssignmentsRepository.InsertAsync(userRoleAssignments);
                if (addResult > 0)
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { Id = userRoleAssignments.ID, Message = "User has been assigned to the Role" };
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Addition Faild" };
                }
            }
        }

        public async Task<DataCreationResultDTO> RemoveUserFromRole(Guid roleId, Guid userId)
        {
            if (roleId == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid RoleID" };
            if (userId == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid UserID" };

            using var context = _unitOfWork.Create;
            var result = await context.Repositories.UserRoleAssignmentsRepository.GetCountByUserIdRoleId(userId, roleId);
            if (result > 0)
            {
                var deleteResult = await context.Repositories.UserRoleAssignmentsRepository.RemoveRoleAssignmentByUserId(userId, roleId);
                if (deleteResult > 0)
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "User has been Deleted Successfully!" };
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Delete Failed!" };
                }
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "UserToRole Assignment doesn't exists!" };
            }
        }

        public async Task<DataCreationResultDTO> AddRole(FormCreateRoleDTO formData)
        {
            if (formData == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid data to add!" };
            if (formData.Name == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid Role Name!" };
            using var context = _unitOfWork.Create;
            //check if the role is existing with same name or not
            var isRoleExists = await context.Repositories.UserRolesRepository.FindByStringDataPropertyAsync("Name", formData.Name);
            if (isRoleExists != null)
            {
                //if yes then throw error
                return new DataCreationResultDTO { IsError = true, Message = "Role already exists!" };
            }
            else
            {
                //if not then update the UserRoles table
                UserRoles userRoles = new UserRoles
                {
                    Name = formData.Name,
                    Description = formData.Description,
                    Hidden = formData.Hidden,
                    ThirdParty = formData.ThirdParty
                };
                int roleInsertCount = await context.Repositories.UserRolesRepository.InsertAsync(userRoles);
                //check if insert is successfull
                if (roleInsertCount > 0)
                {
                    //check if the insert data is having claims or not
                    if (formData.Claims.Count > 0)
                    {
                        //get the inserted role details by name
                        var newRole = await context.Repositories.UserRolesRepository.FindByStringDataPropertyAsync("Name", userRoles.Name);
                        for (int i = 0; i < formData.Claims.Count; i++)
                        {
                            UserRoleClaims userRoleClaims = new UserRoleClaims
                            {
                                RoleID = newRole.ID,
                                ClaimID = formData.Claims[i].ID
                            };
                            //insert the role claim mapping in UserRoleClaims table
                            await context.Repositories.UserRoleClaimsRepository.InsertAsync(userRoleClaims);
                        }
                    }
                    //save all changes
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Role has been created!!" };
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Role insert has been failed" };
                }
            }
        }

        public async Task<DataCreationResultDTO> UpdateRole(Guid roleId, FormCreateRoleDTO formData)
        {
            if (roleId == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid RoleID!" };
            if (formData == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid data to add!" };
            if (formData.Name == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid Role Name!" };
            using var context = _unitOfWork.Create;
            // Get the role details for which updation is executing
            var isRoleExists = await context.Repositories.UserRolesRepository.FindByIdAsync(roleId);
            if (isRoleExists != null)
            {
                //assign all the updated values
                isRoleExists.Name = formData.Name;
                isRoleExists.Description = formData.Description;
                isRoleExists.Hidden = formData.Hidden;
                isRoleExists.ThirdParty = formData.ThirdParty;
                int roleUpdateCount = await context.Repositories.UserRolesRepository.UpdateAsync(isRoleExists);
                //check if UserRoles table updation done
                if (roleUpdateCount > 0)
                {
                    //check if the updation data is having claims or not
                    if (formData.Claims.Count > 0)
                    {
                            
                            var allRoleClaimMap1 = (List<UserClaims>)await context.Repositories.UserClaimsRepository.GetClaimsByRoleId(roleId);
                            for (int j = 0; j < allRoleClaimMap1.Count; j++)
                            {
                                IEnumerable<UserRoleClaimsDetail> roleClaims = await context.Repositories.UserRoleClaimsRepository.GetUserRoleClaims(roleId, allRoleClaimMap1[j].ID);
                                await context.Repositories.UserRoleClaimsRepository.DeleteAsync(roleClaims.First());
                            }
                         
                             for (int j = 0; j < formData.Claims.Count; j++)
                            {
                                    UserRoleClaims userRoleClaims = new UserRoleClaims
                                {
                                  RoleID = roleId,
                                   ClaimID = formData.Claims[j].ID
                                };
                                this.SetScopeValueForType(formData.Claims[j].ScopeType, formData.Claims[j].ScopeValue, userRoleClaims);

                                await context.Repositories.UserRoleClaimsRepository.InsertAsync(userRoleClaims);
                            }

                    }else
                    {
                        //if formData.claim has 0 values then all the claims has been removed by the user, hence delet all 
                        var allRoleClaimMap = (List<UserClaims>)await context.Repositories.UserClaimsRepository.GetClaimsByRoleId(roleId);
                        for (int j = 0; j < allRoleClaimMap.Count; j++)
                        {
                            IEnumerable<UserRoleClaimsDetail> roleClaims = await context.Repositories.UserRoleClaimsRepository.GetUserRoleClaims(roleId, allRoleClaimMap[j].ID);
                            await context.Repositories.UserRoleClaimsRepository.DeleteAsync(roleClaims.First());
                        }
                     

                    }
                    //save all the changes
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Role has been created!!" };
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Role insert has been failed" };
                }
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "Role doesn't exists!" };
            }
        }

        private void SetScopeValueForType(string scopeType,string scopValue, UserRoleClaims roleClaim)
        {
            switch (scopeType)
            {
                case "Operator":
                    roleClaim.OperatorID = scopValue == "" ||scopValue == null ? Guid.Empty : new Guid(scopValue);
                    break;

                case "Aircraft":
                   roleClaim.AircraftID = scopValue == "" || scopValue == null ? Guid.Empty : new Guid(scopValue);
                    break;

                case "ProductType":
                case "Product Type":
                case "Configuration":
                case "Configuration Definition":
                    {
                        if(scopValue == "" || scopValue == null)
                        {
                            roleClaim.ConfigurationDefinitionID = null;
                            break;
                        }
                        roleClaim.ConfigurationDefinitionID = Int32.Parse(scopValue);
                    }
                    break;

                case "Role":
                case "User Role":
                    roleClaim.UserRoleID = scopValue == "" || scopValue == null ? Guid.Empty : new Guid(scopValue);
                    break;
                default:
                    Console.WriteLine("Nothing");
                    break;
            }
        }

        public async Task<DataCreationResultDTO> RemoveRole(Guid roleId)
        {
            if (roleId == null) return new DataCreationResultDTO { IsError = true, Message = "Invalid RoleID!" };
            using var context = _unitOfWork.Create;
            // Get the role details for which delete is executing
            var isRoleExists = await context.Repositories.UserRolesRepository.FindByIdAsync(roleId);
            if (isRoleExists != null)
            {
                //set the flag to true
                isRoleExists.Hidden = true;
                //update the UserRoles table
                int updateResult = await context.Repositories.UserRolesRepository.UpdateAsync(isRoleExists);
                if (updateResult > 0)
                {
                    //save changes if update is successfull
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Role has been deleted" };
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Delete operation has been failed!" };
                }
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "Role Not Found!" };
            }
        }
    }
}

