using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IBuildTaskRepository
    {
        Task<List<BuildTask>> GetProductExports(int configurationId);
    }
}