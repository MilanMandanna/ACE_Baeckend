using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace backend.DataLayer.Repository.SqlServer
{
   
    public class UserRolesRepository : SimpleRepository<UserRoles>, IUserRolesRepository
    {
        public UserRolesRepository()
        {

        }
        public UserRolesRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }

        public async Task<IEnumerable<UserRoles>> GetRolesByUserId(Guid userId)
        {
            var command = CreateCommand("[dbo].[SP_GetRolesByUserId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@userId", userId);

            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<UserRoles>(reader);
        }
    }
}
