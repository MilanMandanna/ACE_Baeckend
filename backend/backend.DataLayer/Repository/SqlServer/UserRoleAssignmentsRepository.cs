using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models;
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
    public class UserRoleAssignmentsRepository : SimpleRepository<UserRoleAssignments>, IUserRoleAssignmentsRepository
    {
        public UserRoleAssignmentsRepository()
        {

        }
        public UserRoleAssignmentsRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }

        public virtual async Task<int> GetCountByUserIdRoleId(Guid userId, Guid roleId)
        {
            var command = CreateCommand("[dbo].[SP_GetCountbyuser_RoleId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@userId", userId);
            command.Parameters.AddWithValue("@roleId", roleId);

            return (int)await command.ExecuteScalarAsync();
        }
        public async Task<int> RemoveRoleAssignmentByUserId(Guid userId, Guid? manageRoleId, Guid? viewRoleId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_RemoveRole_Userid]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@userId", userId);
                command.Parameters.AddWithValue("@manageRoleId", manageRoleId);
                command.Parameters.AddWithValue("@viewRoleId", viewRoleId);

                return await command.ExecuteNonQueryAsync();
            }
            catch(Exception ex)
            {
                throw ex;
            }
           
        }

        public  virtual async Task<int> RemoveRoleAssignmentByUserId(Guid userId, Guid roleId)
        {
            var command = CreateCommand("[dbo].[SP_RemoveRoleAssignment_Userid]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@userId", userId);
            command.Parameters.AddWithValue("@roleId", roleId);

            return await command.ExecuteNonQueryAsync();
        }
        public virtual async Task<IEnumerable<User>> GetUsersByRoleId(Guid roleId)
        { 
            var command = CreateCommand("[dbo].[SP_GetUserByRoleId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@roleId", roleId);
            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<User>(reader);
        }
    }
}
