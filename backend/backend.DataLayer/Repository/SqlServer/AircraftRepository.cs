using Ace.DataLayer.Models;
using backend.DataLayer.Helpers;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.Contracts.Actions;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using System.Reflection;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models;
using backend.DataLayer.Repository.Extensions;
using System.Data;
using backend.DataLayer.Models.CustomContent;

namespace backend.DataLayer.Repository.SqlServer
{
    public class AircraftRepository : SimpleRepository<Aircraft>, IAircraftRepository
    {
        public AircraftRepository(SqlConnection context, SqlTransaction transaction)
            : base(context, transaction)
        { }

        public AircraftRepository() { }
        private Aircraft FromReader(SqlDataReader reader)
        {
            var aircraft = new Aircraft
            {
                Id = (Guid)reader["Id"],
                DateCreated = DbHelper.DateFromDb(reader["DateCreated"]),
                DateModified = DbHelper.DateFromDb(reader["DateModified"]),
                Password = reader["Password"].ToString(),
                LastPasswordChange = DbHelper.DateFromDb(reader["LastPasswordChange"]),
                IsDeleted = (bool)reader["IsDeleted"],
                TailNumber = reader["TailNumber"].ToString(),
                SerialNumber = reader["SerialNumber"].ToString(),
                ConnectivityTypes = reader["ConnectivityTypes"].ToString(),
                LastManifestCreatedDate = DbHelper.DateFromDb(reader["LastManifestCreatedDate"]),
                Manufacturer = reader["Manufacturer"].ToString(),
                Model = reader["Model"].ToString(),
                ModifiedBy = reader["ModifiedBy"].ToString(),
                OperatorId = DbHelper.GuidFromDb(reader["OperatorId"])
            };
            return aircraft;
        }

        public virtual Aircraft Find(String id)
        {
            var command = CreateCommand("[dbo].[SP_Aircraft_Find]");
            command.CommandType = CommandType.StoredProcedure;
            command.CommandTimeout = 0;
            command.Parameters.Add(new SqlParameter("@parameterType", "id"));
            command.Parameters.Add(new SqlParameter("@parameter", id));
            using (var reader = command.ExecuteReader())
            {
                if (reader.Read())
                {
                    return FromReader(reader);
                }
                return null;
            }
        }

        public virtual Aircraft FindByTailNumber(String tailNumber)
        {
            var command = CreateCommand("[dbo].[SP_Aircraft_Find]");
            command.CommandType = CommandType.StoredProcedure;
            command.CommandTimeout = 0;
            command.Parameters.Add(new SqlParameter("@parameterType", "tailNumber"));
            command.Parameters.Add(new SqlParameter("@parameter", tailNumber));
            using (var reader = command.ExecuteReader())
            {
                if (reader.Read())
                {
                    return FromReader(reader);
                }
                return null;
            }
        }

        public async Task<IEnumerable<Aircraft>> FindByIds(Guid[] guids)
        {
            var result = new List<Aircraft>();
            // Convert guids to comma seperated string enclosed in single quotes
            var ids = String.Join("','", guids);
            var command = CreateCommand("[dbo].[SP_Aircraft_Find]");
            command.CommandType = CommandType.StoredProcedure;
            command.CommandTimeout = 0;
            command.Parameters.Add(new SqlParameter("@parameterType", "ids"));
            command.Parameters.Add(new SqlParameter("@parameter", ids));
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(FromReader(reader));
                }
            }
            return result;
        }

        public virtual async Task<IEnumerable<Aircraft>> FindAll()
        {
            var result = new List<Aircraft>();
            var command = CreateCommand("[dbo].[SP_Aircraft_Find]");
            command.CommandType = CommandType.StoredProcedure;
            command.CommandTimeout = 0;
            command.Parameters.Add(new SqlParameter("@parameterType", "all"));
            command.Parameters.Add(new SqlParameter("@parameter", ""));
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    Aircraft aircraft = new Aircraft();
                    aircraft.CreatedByUserId = DbHelper.GuidFromDb(reader["CreatedByUserId"]);
                    aircraft.Id = DbHelper.GuidFromDb(reader["Id"]);
                    aircraft.InstallationTypeID = DbHelper.GuidFromDb(reader["InstallationTypeID"]);
                    aircraft.IsDeleted = DbHelper.BoolFromDb(reader["IsDeleted"]);
                    aircraft.Manufacturer = DbHelper.DBValueToString(reader["Manufacturer"]);
                    aircraft.Model = DbHelper.DBValueToString(reader["Model"]);
                    aircraft.OperatorId = DbHelper.GuidFromDb(reader["OperatorId"]);
                    aircraft.Password = DbHelper.DBValueToString(reader["Password"]);
                    aircraft.SelectedAssetsCount = DbHelper.LongFromDB(reader["SelectedAssetsCount"]);
                    aircraft.SelectedAssetsSize = DbHelper.LongFromDB(reader["SelectedAssetsSize"]);
                    aircraft.TailNumber = DbHelper.DBValueToString(reader["TailNumber"]);
                    aircraft.SerialNumber = DbHelper.DBValueToString(reader["SerialNumber"]);
                    aircraft.ThirdPartyRoleID = DbHelper.GuidFromDb(reader["ThirdPartyRoleID"]);
                    aircraft.ConnectivityTypes = DbHelper.DBValueToString(reader["ConnectivityTypes"]);
                    aircraft.ContentDiskSpace = DbHelper.DBValueToInt(reader["ContentDiskSpace"]);
                    aircraft.DateCreated = DbHelper.DateFromDb(reader["DateCreated"]);
                    aircraft.DateModified = DbHelper.DateFromDb(reader["DateModified"]);
                    aircraft.LastManifestCreatedDate = DbHelper.DateFromDb(reader["LastManifestCreatedDate"]);
                    aircraft.LastPasswordChange = DbHelper.DateFromDb(reader["LastPasswordChange"]);
                    aircraft.ModifiedBy = DbHelper.DBValueToString(reader["ModifiedBy"]);
                    result.Add(aircraft);
                }
            }
            return result;
        }

        public void Update(Aircraft aircraft)
        {
            var command = CreateCommand();
            DatabaseMapper.Instance.PrepareUpdate(aircraft, command);
            int records = command.ExecuteNonQuery();
        }

        public async Task<IEnumerable<Operator>> GetOperators(Guid[] airaftIds)
        {
            if (airaftIds == null || airaftIds.Length == 0) return new List<Operator>();
            var ids = String.Join("','", airaftIds);
            var command = CreateCommand("[dbo].[SP_Aircraft_GetOperators]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@aircraftIds", ids));

            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<Operator>(reader);
        }

        public virtual async Task<IEnumerable<Aircraft>> GetAircraftByConfigurationId(int configurationId)
        {
            var command = CreateCommand("[dbo].[SP_Configuration_GetAircrafts]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<Aircraft>(reader);
        }

        public virtual async Task<IEnumerable<Product>> GetAircraftsProduct(Guid aircraftID)
        {

            var command = CreateCommand("[dbo].[SP_Aircraft_GetProducts]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@aircraftId", aircraftID);
            using var reader = await command.ExecuteReaderAsync();
            return await DatabaseMapper.Instance.FromReaderAsync<Product>(reader);
        }

        public virtual async Task<List<BuildDefaultPartnumber>> ConfigurationDefinitionPartNumber(int configurationDefinitionId, int partNumberCollectionId, string tailNumber)
        {
            try
            {
                List<BuildDefaultPartnumber> listbuildDefaultPartnumbers = new List<BuildDefaultPartnumber>();
                var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_PartNumber]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationDefinitionId", configurationDefinitionId);
                command.Parameters.AddWithValue("@partNumberCollectionId", partNumberCollectionId);
                command.Parameters.AddWithValue("@TailNumber", tailNumber);
                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        BuildDefaultPartnumber buildDefaultPartnumber = new BuildDefaultPartnumber();
                        buildDefaultPartnumber.PartNumberID = DbHelper.DBValueToInt(reader["PartNumberID"]);
                        buildDefaultPartnumber.Name = DbHelper.DBValueToString(reader["Name"]);
                        buildDefaultPartnumber.PartNumberCollectionID = DbHelper.DBValueToInt(reader["PartNumberCollectionID"]);
                        buildDefaultPartnumber.Description = DbHelper.DBValueToString(reader["Description"]);
                        buildDefaultPartnumber.DefaultPartNumber = DbHelper.DBValueToString(reader["DefaultPartNumber"]);

                        listbuildDefaultPartnumbers.Add(buildDefaultPartnumber);
                    }
                }

                return listbuildDefaultPartnumbers;
            }
            catch (Exception ex)
            {

                throw ex;

            }
        }





        public virtual async Task<int> ConfigurationDefinitionUpdatePartNumber(PartNumber partNumberInfo)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_UpdatePartNumber]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationDefinitionID", partNumberInfo.ConfigurationDefinitionID);
                command.Parameters.AddWithValue("@partNumberID", partNumberInfo.PartNumberID);
                command.Parameters.AddWithValue("@value", partNumberInfo.Value);
                command.Parameters.AddWithValue("@tailNumber", partNumberInfo.TailNumber);
                return await command.ExecuteNonQueryAsync();
            }

            catch (Exception ex)
            {

                throw ex;

            }
        }

        public virtual async Task<int> GetPartNumberCollectionId(int configurationDefnitionID)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_GetPartNumberCollectionId]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationDefinitionID", configurationDefnitionID);
                int partNumberCollectionId = 0;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        partNumberCollectionId = reader.GetInt32(0);
                    }
                }
                return partNumberCollectionId;
            }

            catch (Exception ex)
            {
                throw ex;

            }
        }


        public virtual async Task<int> SetTopLevelPartnumber(string copyFileName, int configurationDefinitionID)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_SetTopLevelPartnumber]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@copyFileName", copyFileName);
                command.Parameters.AddWithValue("@configurationDefinitionID", configurationDefinitionID);
                return await command.ExecuteNonQueryAsync();
            }

            catch (Exception ex)
            {

                throw ex;

            }
        }

        public virtual async Task<int> GetPartnumberId(string name)
        {
            try
            {
                int result = 0;
                var command = CreateCommand("[dbo].[SP_GetPartnumberId]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@name", name);
                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        result = reader.GetInt32(0);
                    }
                }
                return result;

            }

            catch (Exception ex)
            {

                throw ex;

            }
        }

        public virtual async Task<int> SaveExtractedPartnumber(int configurationDefinitionID, int partNumberId, string partNumber)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_SaveExtractedPartnumber]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationDefinitionID", configurationDefinitionID);
                command.Parameters.AddWithValue("@partNumberID", partNumberId);
                command.Parameters.AddWithValue("@partNumber", partNumber);
                return await command.ExecuteNonQueryAsync();
            }

            catch (Exception ex)
            {

                throw ex;

            }
        }
        public virtual async Task<List<BuildDefaultPartnumber>> GetDefaultPartNumber(int outputTypeID)
        {
            try
            {
                List<BuildDefaultPartnumber> listbuildDefaultPartnumbers = new List<BuildDefaultPartnumber>();
                var command = CreateCommand("[dbo].[SP_Default_PartNumber]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@outputTypeID", outputTypeID);
                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        BuildDefaultPartnumber buildDefaultPartnumber = new BuildDefaultPartnumber();
                        buildDefaultPartnumber.PartNumberID = DbHelper.DBValueToInt(reader["PartNumberID"]);
                        buildDefaultPartnumber.Name = DbHelper.DBValueToString(reader["Name"]);
                        buildDefaultPartnumber.PartNumberCollectionID = DbHelper.DBValueToInt(reader["PartNumberCollectionID"]);
                        buildDefaultPartnumber.Description = DbHelper.DBValueToString(reader["Description"]);
                        buildDefaultPartnumber.DefaultPartNumber = DbHelper.DBValueToString(reader["DefaultPartNumber"]);

                        listbuildDefaultPartnumbers.Add(buildDefaultPartnumber);
                    }
                }

                return listbuildDefaultPartnumbers;
            }
            catch (Exception ex)
            {

                throw ex;

            }


        }
    }

}
