using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IMenuRepository
    {
        Task<List<UserMenu>> GetMenusByUserId(Guid userId);
    }
}