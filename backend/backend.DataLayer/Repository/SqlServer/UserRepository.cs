using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Authorization;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Data;

namespace backend.DataLayer.Repository.SqlServer
{
    public class UserRepository : SimpleRepository<User>, IUserRepository
    {

       
        public UserRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {

        }


        /// <summary>
        /// Returns the Users associated with the objects and its claim ids.
        /// </summary>
        /// <param name="objectID"> ID of operator, aircraft, configuration or Product type </param>
        /// <param name="manageClaimId"></param>
        /// <param name="viewClaimId"></param>
        /// <param name="objectType"> Type of the object associated with</param>
        /// <returns></returns>
        public async Task<IEnumerable<User>> GetUsersByObjectType(Guid objectID, Guid manageClaimId, Guid viewClaimId, ObjectType objectType)
        {
            String objectIDFieldName = "OperatorID";
            switch (objectType)
            {
                case ObjectType.Aircraft:
                    objectIDFieldName = "AircraftID";
                    break;
                case ObjectType.Configuration:
                    objectIDFieldName = "ConfigurationID";
                    break;
                case ObjectType.ProductType:
                    objectIDFieldName = "ProductID";
                    break;
            }
            
                var command = CreateCommand("[dbo].[SP_Getuserby_Object]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@objectID", objectID);
                command.Parameters.AddWithValue("@manageClaimId", manageClaimId);
                command.Parameters.AddWithValue("@viewClaimId", viewClaimId);
                command.Parameters.AddWithValue("@objectIDFieldName", objectIDFieldName);

                using var reader = await command.ExecuteReaderAsync();
                return await DatabaseMapper.Instance.FromReaderAsync<User>(reader);
            
           
            
        }
    }
}
