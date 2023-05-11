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


    public class UserRoleClaimsRepository : SimpleRepository<UserRoleClaims>, IUserRoleClaimsRepository
    {
        public UserRoleClaimsRepository()
        {

        }
        public UserRoleClaimsRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }       

        public  virtual async Task<int> GetClaimsCountByRoleId(Guid roleId, Guid claimId)
        {
            var command = CreateCommand("[dbo].[SP_GetClaimsCountByRoleId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@roleId", roleId);
            command.Parameters.AddWithValue("@claimId", claimId);

            return (int)await command.ExecuteScalarAsync();
        }
        public virtual async Task<IEnumerable<UserRoleClaimsDetail>> GetUserRoleClaims(Guid roleId, Guid claimId)
        {
            var command = CreateCommand("[dbo].[SP_GetUserRoleClaims]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@roleId", roleId);
            command.Parameters.AddWithValue("@claimId", claimId);

            using var reader = await command.ExecuteReaderAsync(); 
           
            return await DatabaseMapper.Instance.FromReaderAsync<UserRoleClaimsDetail>(reader);
        }

         public async Task<int> GetRoleClaimMapByUserIdOperatorRoleIdClaimId(Guid operatorManageOrViewRoleId, Guid userId, Guid claimId)
        {
             var command = CreateCommand("[dbo].[SP_GetUserRoleClaimsby_RoleclaimId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@roleId", operatorManageOrViewRoleId);
            command.Parameters.AddWithValue("@userId", userId);
            command.Parameters.AddWithValue("@claimId", claimId);

            return (int)await command.ExecuteScalarAsync();
        }
        public virtual async Task<List<object>> GetScopeValueForClaim(Guid roleId, Guid claimId, string scopeType)
        {
            string param = string.Empty;
            switch (scopeType)
            {

                case "Operator":
                    param = "OperatorID";
                    break;

                case "Aircraft":
                    param = "AircraftID";
                    break;

                case "ProductType":
                case "Product Type":
                case "Configuration":
                case "Configuration Definition":
                    param = "ConfigurationDefinitionID";
                    break;

                case "Role":
                case "User Role":
                    param = "UserRoleID";
                    break;

                default:
                    return null;
            }
            var command = CreateCommand("[dbo].[SP_Getscopevalue_Claims]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@roleId", roleId);
            command.Parameters.AddWithValue("@claimId", claimId);
            command.Parameters.AddWithValue("@param", param);
            var result = new List<object>();

            using (var reader = await command.ExecuteReaderAsync())
            {

                while (await reader.ReadAsync())
                {
                    result.Add (reader.GetValue(0));
                }
            }

            return result;

        }

        public async Task<List<object>> GetScopeValueForUser(Guid userId, Guid claimId, string scopeType)
        {
            var command = CreateCommand("[dbo].[SP_GetScopeValueForUser]");
            command.CommandType = CommandType.StoredProcedure;
            using var sqlreader = await command.ExecuteReaderAsync();
            var allowedScopes = new List<string>();

            while (await sqlreader.ReadAsync())
            {
                allowedScopes.Add(sqlreader.GetString(0).ToLower());
            }
            allowedScopes.RemoveRange(0, 3);
            if (!allowedScopes.Contains(scopeType.ToLower()))
            {
                Console.WriteLine("InValid scope type");
                return null;
            }
            sqlreader.Close();
            var command1 = CreateCommand("[dbo].[SP_GetScopeValueForUserinput]");
            command1.CommandType = CommandType.StoredProcedure;
            command1.Parameters.AddWithValue("@userId", userId);
            command1.Parameters.AddWithValue("@claimId", claimId);
            var result = new List<object>();

            using (var reader = await command1.ExecuteReaderAsync())
            {

                while (await reader.ReadAsync())
                {
                    result.Add(reader.GetValue(0));
                }
            }

            return result;
        }

 
        public async Task<IEnumerable<UserRoleClaims>> GetClaimsForUserWithAircraftsConfigurations(Guid userId)
        {
            var command = CreateCommand("[dbo].[SP_GetClaimsforuser_Aircraftconfig]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@userId", userId);
            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<UserRoleClaims>(reader);
        }

        public void InsertAsync()
        {
            throw new NotImplementedException();
        }
    }
}
