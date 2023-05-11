using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using Microsoft.AspNetCore.Mvc;

namespace backend.DataLayer.Repository.SqlServer
{
    public class TriggerConfigurationRepository : Repository, ITriggerConfigurationRepository
    {
        public TriggerConfigurationRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public TriggerConfigurationRepository()
        {
        }

        public virtual async Task<IEnumerable<Trigger>> GetAllTriggers(int configurationId)
        {
            IEnumerable<Trigger> triggers;

            var command = CreateCommand("cust.SP_Trigger_GetAll", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);

            using (var reader = await command.ExecuteReaderAsync())
            {
                triggers = await DatabaseMapper.Instance.FromReaderAsync<Trigger>(reader);
            }

            return triggers;

        }

        public virtual async Task<int> RemoveTrigger(int configurationId, string triggerId)
        {
            var command = CreateCommand("cust.SP_Trigger_Delete", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@triggerId", int.Parse(triggerId));
            int result = await command.ExecuteNonQueryAsync();
            return result > 0 ? 1 : 0;
        }

        public virtual async Task<IEnumerable<Trigger>> GetTrigger(int configurationId, string triggerId)
        {
            var command = CreateCommand("cust.SP_Trigger_Get", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@triggerId", triggerId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                return await DatabaseMapper.Instance.FromReaderAsync<Trigger>(reader);
            }
        }

        public virtual async Task<int> AddTriggerItem(int configurationId, Trigger triggerData)
        {
            var command = CreateCommand("cust.SP_Trigger_Add", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@name", triggerData.Name);
            command.Parameters.AddWithValue("@type", triggerData.Type);
            command.Parameters.AddWithValue("@condition", triggerData.Condition);
            command.Parameters.AddWithValue("@default", triggerData.IsDefault);

            int result = await command.ExecuteNonQueryAsync();
            return result > 0 ? 1 : 0;
        }
    }
}
