using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.Repository.SqlServer.Queries;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ModesConfigurationRepository : Repository, IModesConfigurationRepository
    {
        public ModesConfigurationRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public ModesConfigurationRepository()
        {

        }
        public virtual async Task<IEnumerable<Mode>> GetAllModes(int configurationId)
        {
            IEnumerable<Mode> modes;


            var command = CreateCommand("[dbo].[sp_mode_getallmodes]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                modes = await DatabaseMapper.Instance.FromReaderAsync<Mode>(reader);
            }

            return modes;
        }

        public virtual async Task<IEnumerable<Mode>> GetMode(int configurationId, string modeId)
        {

            var command = CreateCommand("[dbo].[sp_mode_getmode]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@modeid", modeId);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                return await DatabaseMapper.Instance.FromReaderAsync<Mode>(reader);
            }
        }

        public virtual async Task<int> AddModeItem(int configurationId, Mode modeData)
        {
            try
            {
                var command = CreateCommand("[dbo].[sp_mode_addmodeitem]", System.Data.CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@modeId", modeData.Id);
                command.Parameters.AddWithValue("@name", modeData.Name);
                command.Parameters.AddWithValue("@scriptId", modeData.ScriptId);
                command.Parameters.AddWithValue("@configurationId", configurationId);
                int result = await command.ExecuteNonQueryAsync();
                return result > 0 ? 1 : 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<(int , string)> AddMode(int configurationId, Mode modeData)
        {
            try
            {
                var command = CreateCommand("[dbo].[sp_mode_getmodeitemcount]", System.Data.CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@configurationId", configurationId);
                int modeItemsCount = (int)await command.ExecuteScalarAsync();
                if (modeItemsCount > 0)
                {
                    IEnumerable<Mode> modes;
                    command = CreateCommand("[dbo].[sp_mode_getmode]", System.Data.CommandType.StoredProcedure);
                    command.Parameters.AddWithValue("@modeid", modeData.Id);
                    command.Parameters.AddWithValue("@configurationId", configurationId);
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        modes = await DatabaseMapper.Instance.FromReaderAsync<Mode>(reader);
                    }
                    if (modes.Count() > 0)
                    {
                        return (0, "Mode with given id already exist");
                    }
                    else
                    {
                        command = CreateCommand("[dbo].[sp_mode_addmodeitem]", System.Data.CommandType.StoredProcedure);
                        command.Parameters.AddWithValue("@modeId", modeData.Id);
                        command.Parameters.AddWithValue("@name", modeData.Name);
                        command.Parameters.AddWithValue("@scriptId", modeData.ScriptId);
                      
                    }
                }
                else
                {

                    command = CreateCommand("[dbo].[sp_mode_addmode]", System.Data.CommandType.StoredProcedure);
                    command.Parameters.AddWithValue("@modeId", modeData.Id);
                    command.Parameters.AddWithValue("@name", modeData.Name);
                    command.Parameters.AddWithValue("@scriptId", modeData.ScriptId);

                }
                command.Parameters.AddWithValue("@configurationId", configurationId);
                int result = await command.ExecuteNonQueryAsync();
                if (result > 0)
                {
                    return (1, "Mode added successfully");
                }
                else
                {
                    return (0, "error adding mode");

                }
            }
            catch(Exception ex)
            {
                throw ex;
            }

        }

        public virtual async Task<int> GetNextModeDefID()
        {
            var command = CreateCommand("[dbo].[sp_mode_getmaxmodeid]", System.Data.CommandType.StoredProcedure);
            var maxModeDefId = await command.ExecuteScalarAsync();
            return (int)maxModeDefId;
        }

        public virtual async Task<int> RemoveMode(int configurationId, string modeId)
        {
            try
            {
                var command = CreateCommand("[dbo].[sp_mode_removemode]", System.Data.CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@modeId", modeId);
                command.Parameters.AddWithValue("@configurationId", configurationId);
             
                int result = await command.ExecuteNonQueryAsync();
                return result > 0 ? 1 : 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> GetMaxModeDefID(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_mode_getmaxmodedefid]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            int maxModeId = (int)await command.ExecuteScalarAsync();
            return maxModeId;
        }

        string CreateModeItemNode(Mode modeData)
        {
            var modeNode = " <mode id = \"" + modeData.Id + "\" name = \"" + modeData.Name + "\"> " +
                                    "<mode_item channel=\"1\" scriptidref= \"" + modeData.ScriptId + "\"  type=\"analog\" />" +
                                    "<mode_item channel=\"1\" scriptidref= \"" + modeData.ScriptId + "\"  type=\"digital3d\" />" +
                                    "<mode_item channel=\"2\" scriptidref= \"" + modeData.ScriptId + "\"  type=\"analog\" />" +
                              " </mode >";


            return modeNode;
        }

         string CreateModeNode(Mode modeData)
        {
            var modeNode = "<mode_defs> " +
                              " <mode id = \"" + modeData.Id + "\" name = \"" + modeData.Name + "\"> " +
                                    "<mode_item channel=\"1\" scriptidref= \"" + modeData.ScriptId + "\"  type=\"analog\" />" +
                                    "<mode_item channel=\"1\" scriptidref= \"" + modeData.ScriptId + "\"  type=\"digital3d\" />" +
                                    "<mode_item channel=\"2\" scriptidref= \"" + modeData.ScriptId + "\"  type=\"analog\" />" +
                              " </mode > " +
                           "</mode_defs> ";


            return modeNode;
        }

        public virtual async Task<int> InsetNewMode(Mode modeData)
        {

            var command = CreateCommand("[dbo].[sp_mode_insertmode]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@modeId", modeData.Id);
            command.Parameters.AddWithValue("@name", modeData.Name);
            command.Parameters.AddWithValue("@scriptId", modeData.ScriptId);
            int result = await command.ExecuteNonQueryAsync();
            return result > 0 ? 1 : 0;
        }
    }
}
