using backend.DataLayer.Models;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IOperatorService
    {
        Task<IEnumerable<OperatorListDTO>> FindAllOperators();
        Task<OperatorListDTO> FindOperatorById(Guid operatorId);
        Task<IEnumerable<OperatorDTO>> GetOperatorsByUserRights(Guid roleId);
        Task<IEnumerable<UserListDTO>> GetUsersByOperatorRights(Guid operatorId);
        Task<DataCreationResultDTO> AddUserToOperatorGroup(Guid operatorId, Guid userId, Guid claimId);
        Task<DataCreationResultDTO> RemoveUserFromOperatorGroup(Guid operatorId, Guid userId);
        Task<DataCreationResultDTO> UpdateUserRightsToManageOrViewOperator(Guid operatorId, Guid userId, Guid claimId);

        Task<DataCreationResultDTO> AddOperator(string name, UserListDTO currentUser);
        Task<DataCreationResultDTO> UpdateOperator(string operatorId, string name);
        Task<DataCreationResultDTO> DeleteOperator(string operatorId);
    }
}
