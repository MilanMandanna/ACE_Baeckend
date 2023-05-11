using AutoMapper;
using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services
{
    public class OperatorService : IOperatorService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public OperatorService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task<IEnumerable<OperatorListDTO>> FindAllOperators()
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.OperatorRepository.FilterAsync("IsDeleted", false);

            return _mapper.Map<List<Operator>, List<OperatorListDTO>>(result);
        }

        public async Task<OperatorListDTO> FindOperatorById(Guid operatorId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.OperatorRepository.FindByIdAsync(operatorId);

            return _mapper.Map<Operator, OperatorListDTO>(result);
        }
        /// <summary>
        /// Method to return the list or single operator based on particular role id and manage operator clai
        /// </summary>
        /// <param name="roleId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<OperatorDTO>> GetOperatorsByUserRights(Guid roleId)
        {
            using var context = _unitOfWork.Create;
            List<OperatorDTO> operatorList = new List<OperatorDTO>();
            //Get the manage operator claims details
            var claims = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageOperator);
            //Get all the records from UserRoleClaims table based on user's role and manage operator claim where operator can be
            //assigned with a operator id or can contain null(Guid.Empty) value
            IEnumerable<UserRoleClaims> result = await context.Repositories.UserRoleClaimsRepository.GetUserRoleClaims(roleId, claims.ID);
            //Check if record exists
            if (result.Count() > 0)
            {
                //loop through all the records
                foreach (var item in result)
                {
                    //if OperatorID is empty and user is having the manage operator right then return all the active operators
                    if (item.OperatorID == Guid.Empty)
                    {
                        var operatorData = await context.Repositories.OperatorRepository.FilterAsync("IsDeleted", false);
                        operatorList = _mapper.Map<List<Operator>, List<OperatorDTO>>(operatorData);
                        return operatorList;
                    }
                    //else get the operator details for each record and add to the output operator list
                    else
                    {
                        var operatorData = await context.Repositories.OperatorRepository.FindByIdAsync(item.OperatorID);
                        operatorList.Add(_mapper.Map<Operator, OperatorDTO>(operatorData));
                    }
                }
            }
            return operatorList;
        }

        public async Task<IEnumerable<UserListDTO>> GetUsersByOperatorRights(Guid operatorId)
        {
            using var context = _unitOfWork.Create;
            List<UserListDTO> users = new List<UserListDTO>();
            var manageOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageOperator);
            var viewOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ViewOperator);
            var result = await context.Repositories.UserRepository.GetUsersByObjectType(operatorId, manageOperatorClaim.ID, viewOperatorClaim.ID, DataLayer.Repository.Contracts.ObjectType.Operator);
            if (result.Count() > 0)
            {
                users = RemoveDuplicates.RemoveDuplicateItems(_mapper.Map<List<User>, List<UserListDTO>>(result.ToList()));
            }
            return users;
        }
        public async Task<DataCreationResultDTO> AddUserToOperatorGroup(Guid operatorId, Guid userId, Guid claimId)
        {
            if (operatorId == null) return new DataCreationResultDTO { IsError = true, Message = "invalid operatorid" };
            if (userId == null) return new DataCreationResultDTO { IsError = true, Message = "invalid userid" };
            if (claimId == null) return new DataCreationResultDTO { IsError = true, Message = "invalid claimId" };

            using var context = _unitOfWork.Create;
            var operatorData = await context.Repositories.OperatorRepository.FindByIdAsync(operatorId);
            var manageOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageOperator);
            var viewOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ViewOperator);
            if (operatorData != null)
            {
                if (manageOperatorClaim.ID == claimId)
                {
                    return await AddUserToOperator(operatorData.ManageRoleID, userId, claimId);
                }
                else if (viewOperatorClaim.ID == claimId)
                {
                    return await AddUserToOperator(operatorData.ViewRoleID, userId, claimId);
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Invalid ClaimID" };
                }
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "Operator Not Found" };
            }
        }
        public async Task<DataCreationResultDTO> RemoveUserFromOperatorGroup(Guid operatorId, Guid userId)
        {
            if (operatorId == null) return new DataCreationResultDTO { IsError = true, Message = "invalid operatorid" };
            if (userId == null) return new DataCreationResultDTO { IsError = true, Message = "invalid userid" };
            using var context = _unitOfWork.Create;
            var operatorData = await context.Repositories.OperatorRepository.FindByIdAsync(operatorId);
            if (operatorData != null)
            {
                var result = await context.Repositories.UserRoleAssignmentsRepository.RemoveRoleAssignmentByUserId(userId, operatorData.ManageRoleID, operatorData.ViewRoleID);
                if (result > 0)
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Role Assignment has been Deleted!" };
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Unable to Perform Delete!" };
                }
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "Invalid Operator!!" };
            }
        }

        public async Task<DataCreationResultDTO> UpdateUserRightsToManageOrViewOperator(Guid operatorId, Guid userId, Guid claimId)
        {
            if (operatorId == null) return new DataCreationResultDTO { IsError = true, Message = "invalid operatorid" };
            if (userId == null) return new DataCreationResultDTO { IsError = true, Message = "invalid userid" };
            if (claimId == null) return new DataCreationResultDTO { IsError = true, Message = "invalid claimId" };

            using var context = _unitOfWork.Create;
            var operatorData = await context.Repositories.OperatorRepository.FindByIdAsync(operatorId);
            var manageOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageOperator);
            var viewOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ViewOperator);
            if (operatorData != null)
            {
                bool isManage = false;
                bool isView = false;
                if (manageOperatorClaim.ID == claimId)
                {
                    isManage = true;
                    return await UpdateUserRightsForOperator(userId, operatorData, isManage, isView);
                }
                else if (viewOperatorClaim.ID == claimId)
                {
                    isView = true;
                    return await UpdateUserRightsForOperator(userId, operatorData, isManage, isView);
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Invalid ClaimID" };
                }
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "Operator Not Found" };
            }
        }

        private async Task<DataCreationResultDTO> AddUserToOperator(Guid roleId, Guid userId, Guid claimId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.UserRoleClaimsRepository.GetRoleClaimMapByUserIdOperatorRoleIdClaimId(roleId, userId, claimId);
            if (result > 0)
            {
                return new DataCreationResultDTO { IsError = true, Message = "User already exists in the specified group" };
            }
            else
            {
                UserRoleClaims roleClaimsMap = new UserRoleClaims
                {
                    RoleID = roleId,
                    ClaimID = claimId,

                };
                await context.Repositories.UserRoleClaimsRepository.InsertAsync(roleClaimsMap);
                var data = await context.Repositories.UserRoleAssignmentsRepository.GetCountByUserIdRoleId(userId, roleId);
                if (data > 0)
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { Id = roleClaimsMap.ID };
                }
                else
                {
                    UserRoleAssignments userRoleAssignmentsMap = new UserRoleAssignments
                    {
                        UserID = userId,
                        RoleID = roleId
                    };
                    await context.Repositories.UserRoleAssignmentsRepository.InsertAsync(userRoleAssignmentsMap);
                    await context.SaveChanges();
                    return new DataCreationResultDTO { Id = userRoleAssignmentsMap.ID };
                }
            }
        }

        private async Task<DataCreationResultDTO> UpdateUserRightsForOperator(Guid userId, Operator operatorData, bool isManage, bool isView)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.UserRoleAssignmentsRepository.RemoveRoleAssignmentByUserId(userId,
                isManage ? operatorData.ViewRoleID : isView ? operatorData.ManageRoleID : Guid.Empty);

            if (result == 0 || result > 0)
            {
                await context.SaveChanges();
                var isUserRoleMapExists = await context.Repositories.UserRoleAssignmentsRepository.
                    GetCountByUserIdRoleId(userId, isManage ? operatorData.ManageRoleID : isView ? operatorData.ViewRoleID : Guid.Empty);
                if (isUserRoleMapExists == 0)
                {
                    UserRoleAssignments userRoleAssignments = new UserRoleAssignments
                    {
                        UserID = userId,
                        RoleID = isManage ? operatorData.ManageRoleID : isView ? operatorData.ViewRoleID : Guid.Empty
                    };
                    var data = await context.Repositories.UserRoleAssignmentsRepository.InsertAsync(userRoleAssignments);
                    if (data > 0)
                    {
                        await context.SaveChanges();
                        return new DataCreationResultDTO { Id = userRoleAssignments.ID };
                    }
                    else
                    {
                        return new DataCreationResultDTO { IsError = true, Message = "Role Assignment Falied!" };
                    }
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Role Assignment already exists!" };
                }
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "Role Removal Falied!" };
            }
        }

        /**
         * Creates a new operator in the database. This function is also responsible for creating
         * the two roles dedicated for the operator, the manage role and view role, along with the necessary
         * claims associated with the roles
         **/
        public async Task<DataCreationResultDTO> AddOperator(string name, UserListDTO currentUser)
        {
            using var context = _unitOfWork.Create;
            // verify an operator with the same name does not already exist
            var oper = (await context.Repositories.OperatorRepository.FilterAsync("Name", name)).FirstOrDefault();
            if (oper != null) return new DataCreationResultDTO { IsError = true, Message = "operator already exists" };

            // get the claim types to associate with the new roles
            var manageOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageOperator);
            var viewOperatorClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ViewOperator);
            if (manageOperatorClaim == null || viewOperatorClaim == null) return new DataCreationResultDTO { IsError = true, Message = "failed to find claims" };

            // create the operator, the two new roles, and the claims associated with the roles
            oper = new Operator
            {
                Name = name,
                Id = Guid.NewGuid(),
                CreatedByUserId = currentUser.Id,
                DateCreated = DateTimeOffset.Now,
                Salutation = 0,
                IsTest = false,
                ManageRoleID = Guid.NewGuid(),
                ViewRoleID = Guid.NewGuid()
            };

            UserRoles manageRole = new UserRoles
            {
                ID = oper.ManageRoleID,
                Name = $"{oper.Id.ToString()}-Manage",
                Hidden = true,
                ThirdParty = false,
                Description = $"Automatically built manage operator role"
            };

            UserRoles viewRole = new UserRoles
            {
                ID = oper.ViewRoleID,
                Name = $"{oper.Id.ToString()}-View",
                Hidden = true,
                ThirdParty = false,
                Description = $"Automatically built view operator role"
            };

            UserRoleClaims manageClaim = new UserRoleClaims
            {
                ID = Guid.NewGuid(),
                ClaimID = manageOperatorClaim.ID,
                OperatorID = oper.Id,
                RoleID = manageRole.ID
            };

            UserRoleClaims viewClaim = new UserRoleClaims
            {
                ID = Guid.NewGuid(),
                ClaimID = viewOperatorClaim.ID,
                OperatorID = oper.Id,
                RoleID = viewRole.ID
            };

            // save everything
            await context.Repositories.OperatorRepository.InsertAsync(oper);
            await context.Repositories.UserRolesRepository.InsertAsync(manageRole);
            await context.Repositories.UserRolesRepository.InsertAsync(viewRole);
            await context.Repositories.UserRoleClaimsRepository.InsertAsync(manageClaim);
            await context.Repositories.UserRoleClaimsRepository.InsertAsync(viewClaim);
            await context.SaveChanges();

            return new DataCreationResultDTO { Id = oper.Id };
        }

        /**
         * Updates the stored name for the operator, at this point we are only exposing the name to be updated
         * so the function is simple for the time being
         **/
        public async Task<DataCreationResultDTO> UpdateOperator(string operatorId, string name)
        {
            using var context = _unitOfWork.Create;
            // get the operator and validate they exist
            Guid operId = Guid.Parse(operatorId);
            var oper = await context.Repositories.OperatorRepository.FindByIdAsync(operId);
            if (oper == null) return new DataCreationResultDTO { IsError = true, Message = "invalid operator" };

            // update the operator record
            oper.DateModified = DateTimeOffset.Now;
            oper.Name = name;

            // save everything
            await context.Repositories.OperatorRepository.UpdateAsync(oper);
            await context.SaveChanges();

            return new DataCreationResultDTO { Id = oper.Id };
        }

        /**
         * Flags an operator as deleted in the database. The roles are kept in place
         **/
        public async Task<DataCreationResultDTO> DeleteOperator(string operatorId)
        {
            using var context = _unitOfWork.Create;
            // get the operator and validate they exist
            Guid operId = Guid.Parse(operatorId);
            var oper = await context.Repositories.OperatorRepository.FindByIdAsync(operId);
            if (oper == null) return new DataCreationResultDTO { IsError = true, Message = "invalid operator" };

            // set the deleted flag
            oper.IsDeleted = true;
            oper.DateModified = DateTimeOffset.Now;

            // save everything
            await context.Repositories.OperatorRepository.UpdateAsync(oper);
            await context.SaveChanges();

            return new DataCreationResultDTO { Id = oper.Id };
        }
    }
}
