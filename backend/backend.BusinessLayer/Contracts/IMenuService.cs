using backend.DataLayer.Models;
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
    public interface IMenuService
    {
        Task<List<UserMenu>> GetMenusByUserId(Guid userId);
    }
}
