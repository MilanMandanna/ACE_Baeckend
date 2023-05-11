using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ConfigurationComponentsRepository : 
        SimpleRepository<ConfigurationComponents>,
        IConfigurationComponentsRepository
    {
        public ConfigurationComponentsRepository(SqlConnection context, SqlTransaction transaction) :
                base(context, transaction)
        { }
        /// <summary>
        /// 1. add new custom content component to tblConfigurationComponents
        /// 2. The inputs are ConfigCompPath,ConfigCompTypeID and ConfigCompName
        /// 3. execute SP_AddNewConfigurationComponent  '/Customcontent/Flightdata.zip', 2, 'Flightdata.zip';
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="views"></param>
        /// <returns></returns>
        public async Task<int> AddConfigurationComponent(string azurePath, int configCompTypeID, string configCompName)
        {
            List<string> returnValue = new List<string>();
            var command = CreateCommand("SP_AddNewConfigurationComponent");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@ConfigCompPath", azurePath));
            command.Parameters.Add(new SqlParameter("@ConfigCompTypeID", configCompTypeID));
            command.Parameters.Add(new SqlParameter("@ConfigCompName", configCompName));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (reader.Read())
                {
                    returnValue.Add(reader["message"].ToString());
                }
                if (returnValue.Contains("Failure"))
                {
                    return 0;
                }
                else
                {
                    return 1;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<IEnumerable<ConfigurationComponents>> GetCofigurationComponentsArtifacts(int configurationID)
        {
            IEnumerable<ConfigurationComponents> returnValue;
            var command = CreateCommand("[dbo].[SP_getConfigComponentsArtifacts]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationID));

            try
            {
                using (var reader = await command.ExecuteReaderAsync())
                {
                    returnValue = await DatabaseMapper.Instance.FromReaderAsync<ConfigurationComponents>(reader);
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }

            return returnValue;
        }
    }
}
