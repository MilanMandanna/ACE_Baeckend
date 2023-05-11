using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using backend.DataLayer.Models.Fleet;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Helpers;
using System.Data;

namespace backend.DataLayer.Repository.SqlServer
{
    class MsuConfiguratonRepository : Repository, IMsuConfigurationRepository
    {

        public MsuConfiguratonRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        private MsuConfiguration FromReader(SqlDataReader reader)
        {
            var msuconfiguration = new MsuConfiguration()
            {
                Id = (Guid)reader["Id"],
                TailNumber = reader["TailNumber"].ToString(),
                FileName = reader["FileName"].ToString(),
                ConfigurationBody = reader["ConfigurationBody"].ToString(),
                DateCreated = DbHelper.DateFromDb(reader["DateCreated"]),

            };
            return msuconfiguration;
        }


        public virtual MsuConfiguration Find(String id)
        {
            
            var command = CreateCommand("[dbo].[SP_MsuFind]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@id", id);
            using (var reader = command.ExecuteReader())
            {
                if (reader.Read())
                {
                    return FromReader(reader);
                }
                return null;
            }
        }

        public async Task<IEnumerable<MsuConfiguration>> FindAll()
        {
            var result = new List<MsuConfiguration>();
           
            var command = CreateCommand("[dbo].[SP_MsuFindAll]");
            command.CommandType = CommandType.StoredProcedure;
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(FromReader(reader));
                }
            }
            return result;
        }

        public MsuConfiguration GetActive(string aircraft_id)
        {
            throw new NotImplementedException();
        }

        public virtual async Task<List<MsuConfiguration>> GetAll(string aircraft_id)
        {
            var result = new List<MsuConfiguration>();
          
            var command = CreateCommand("[dbo].[SP_MsuGetAll]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@aircraftid",aircraft_id );
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(FromReader(reader));
                }
            }
            return result;
        }
    }
}
