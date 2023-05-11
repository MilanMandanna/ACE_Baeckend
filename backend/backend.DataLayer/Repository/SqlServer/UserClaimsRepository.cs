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
    public class UserClaimsRepository : SimpleRepository<UserClaims>, IUserClaimsRepository
    {
        public UserClaimsRepository()
        {

        }
        public UserClaimsRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }

        public virtual async Task<IEnumerable<UserClaims>> GetClaimsByRoleId(Guid roleId)
        {
            var command = CreateCommand("[dbo].[SP_GetClaims_RoleId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@roleId", roleId);
            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<UserClaims>(reader);
        }

        public async Task<IEnumerable<UserClaims>> GetClaimsByUserId(Guid userId)
        {
            var command = CreateCommand("[dbo].[SP_GetClaims_UserId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@userId", userId);

            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<UserClaims>(reader);
        }
    }
}
