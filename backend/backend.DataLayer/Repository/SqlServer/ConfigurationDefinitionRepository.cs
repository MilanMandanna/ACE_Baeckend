using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models;
using Ace.DataLayer.Models;
using System.Data;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Build;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ConfigurationDefinitionRepository :
        SimpleRepository<ConfigurationDefinition>,
        IConfigurationDefinitionRepository

    {
        public ConfigurationDefinitionRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }

        public ConfigurationDefinitionRepository()
        {

        }

        public virtual async  Task<IEnumerable<ConfigurationDefinition>> GetProductConfigurationDefinitions()
        {
            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetDefinitions]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@definitionType", "products");
            using (var reader = await command.ExecuteReaderAsync())
            {
                return await DatabaseMapper.Instance.FromReaderAsync<ConfigurationDefinition>(reader);
            }
        }

        public virtual async Task<IEnumerable<ConfigurationDefinition>> GetPlatformConfigurationDefinitions()
        {
            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetDefinitions]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@definitionType", "platforms");
            using (var reader = await command.ExecuteReaderAsync())
            {
                return await DatabaseMapper.Instance.FromReaderAsync<ConfigurationDefinition>(reader);
            }
        }

        public virtual async Task<IEnumerable<ConfigurationDefinition>> GetGlobalConfigurationDefinitions()
        {
            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetDefinitions]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@definitionType", "global");
            using (var reader = await command.ExecuteReaderAsync())
            {
                return await DatabaseMapper.Instance.FromReaderAsync<ConfigurationDefinition>(reader);
            }
        }

        public virtual async Task<Product> GetProduct(int configurationDefinitionId)
        {
            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetDefinition]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@definitionType", "product");
            command.Parameters.AddWithValue("@definitionId", configurationDefinitionId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    Product product = new Product();
                    DatabaseMapper.Instance.FromReader(reader, product);
                    return product;
                }
            }

            return null;
        }

        public  virtual async Task<Platform> GetPlatform(int configurationDefinitionId)
        {
            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetDefinition]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@definitionType", "platform");
            command.Parameters.AddWithValue("@definitionId", configurationDefinitionId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    Platform platform = new Platform();
                    DatabaseMapper.Instance.FromReader(reader, platform);
                    return platform;
                }
            }

            return null;
        }

        public  virtual async Task<Global> GetGlobal(int configurationDefinitionId)
        {
            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetDefinition]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@definitionType", "global");
            command.Parameters.AddWithValue("@definitionId", configurationDefinitionId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    Global global = new Global();
                    DatabaseMapper.Instance.FromReader(reader, global);
                    return global;
                }
            }

            return null;
        }

        public async Task<int> MaxConfigurationDefinitionID()
        {
            var command = CreateCommand("[dbo].[SP_Configuration_Utility]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@type", "configuration definition"));
            return (int) await command.ExecuteScalarAsync();
        }

        public virtual async Task<IEnumerable<UserConfigurationDefinition>> GetConfigurationDefinitionsForUser(Guid userId)
        {

            IEnumerable<UserConfigurationDefinition> configurationDefinitions;
            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetAll]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@userId", userId);
            using var reader = await command.ExecuteReaderAsync();
             configurationDefinitions = await DatabaseMapper.Instance.FromReaderAsync<UserConfigurationDefinition>(reader);
            return configurationDefinitions;

        }

        public  virtual async Task<IEnumerable<Operator>> GetOperatorsWithConfigurationDefinitionForUser(Guid userId, int configurationDefinitionId, string operatorType)
        {
            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetOperators]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@userId", userId);
            command.Parameters.AddWithValue("@configurationDefinitionID", configurationDefinitionId);
            command.Parameters.AddWithValue("@operatorType", operatorType);
            using var reader = await command.ExecuteReaderAsync();
            var result = await DatabaseMapper.Instance.FromReaderAsync<Operator>(reader);
            return result;
        }

        public  virtual async Task<IEnumerable<AircraftConfiguration>> GetAircraftsWithConfigurationDefinitionForOperator(Guid operatorId, Guid userId)
        {

            var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetAircrafts]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@operatorId", operatorId);
            command.Parameters.AddWithValue("@userId", userId);
            using var reader = await command.ExecuteReaderAsync();
            var result = await DatabaseMapper.Instance.FromReaderAsync<AircraftConfiguration>(reader);
            return result;
        }

        public virtual async Task<IEnumerable<ConfigurationDefinitionDetails>> GetConfigurationInfoByConfigurationId(int configurationId)
        {
            var command = CreateCommand("[dbo].[SP_Configuration_DefinitionInfo]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            using var reader = await command.ExecuteReaderAsync();
            var result = await DatabaseMapper.Instance.FromReaderAsync<ConfigurationDefinitionDetails>(reader);
            return result;
        }


        public virtual async Task<IEnumerable<Platform>> GetPlatforms(int configurationDefinitionId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetDefinition]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@definitionType", "child platform");
                command.Parameters.AddWithValue("@definitionId", configurationDefinitionId);

                using var reader = await command.ExecuteReaderAsync();
                var platforms = await DatabaseMapper.Instance.FromReaderAsync<Platform>(reader);

                return platforms;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> UpdatePlatformData(Platform platformData, Guid userId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_UpdatePlatformData]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@name", platformData.Name));
                command.Parameters.Add(new SqlParameter("@description", platformData.Description));
                command.Parameters.Add(new SqlParameter("@platformId", platformData.PlatformID));
                command.Parameters.Add(new SqlParameter("@type", "edit"));
                command.Parameters.Add(new SqlParameter("@userID", userId));
                return await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> SaveProductConfigurationData(ProductConfigurationData productConfigurationData, Guid userId, DataTable platformDataTable)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_SaveProductConfigurationData]");
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 0;
                command.Parameters.Add(new SqlParameter("@productName", productConfigurationData.ProductName));
                command.Parameters.Add(new SqlParameter("@productDescription", productConfigurationData.ProductDescription));
                command.Parameters.Add(new SqlParameter("@configurationDefinitionId", productConfigurationData.ConfigurationDefinitionId));
                command.Parameters.Add(new SqlParameter("@userID", userId));
                command.Parameters.Add(new SqlParameter("@outputTypeID", productConfigurationData.OutputTypeID));
                command.Parameters.Add(new SqlParameter("@TopLevelPartnumber", productConfigurationData.TopLevelPartNumber));
                command.Parameters.Add("@platformData", SqlDbType.Structured).Value = platformDataTable;

                return await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<IEnumerable<InstallationTypes>> GetInstallationTypes()
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@type", "installation"));

                using var reader = await command.ExecuteReaderAsync();
                var installationTypes = await DatabaseMapper.Instance.FromReaderAsync<InstallationTypes>(reader);

                return installationTypes;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<IEnumerable<OutputTypes>> GetOutputTypes()
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_ConfigurationDefinition_GetInstallationTypesOrOutputTypes]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@type", "outputtypes"));

                using var reader = await command.ExecuteReaderAsync();
                var outputTypes = await DatabaseMapper.Instance.FromReaderAsync<OutputTypes>(reader);

                return outputTypes;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> SaveProducts(ProductConfigurationData productConfigurationData, Guid userId)
        {
            int configurationDefinitionId = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_SaveProductData]");
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 0;
                command.Parameters.Add(new SqlParameter("@productName", productConfigurationData.ProductName));
                command.Parameters.Add(new SqlParameter("@productDescription", productConfigurationData.ProductDescription));
                command.Parameters.Add(new SqlParameter("@configurationDefinitionId", DBNull.Value));
                command.Parameters.Add(new SqlParameter("@userID", userId));
                command.Parameters.Add(new SqlParameter("@outputTypeID", productConfigurationData.OutputTypeID));
                command.Parameters.Add(new SqlParameter("@topLevelPartNumber", productConfigurationData.TopLevelPartNumber));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    configurationDefinitionId = DbHelper.DBValueToInt(reader["ConfigurationDefinitionID"]);
             
                }
                return configurationDefinitionId;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<AllFeatureSetData> GetAllFeatureSet(int configurationDefinitionId)
        {
            try
            {
                AllFeatureSetData allFeatureSetData = new AllFeatureSetData();
                
                var command = CreateCommand("[dbo].[SP_GetAllFeatureSet]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationDefinitionId", configurationDefinitionId));

                allFeatureSetData.DistinctFeatureSet = new List<FeatureSetValues>();

                using var reader = await command.ExecuteReaderAsync();
                {
                    while (await reader.ReadAsync())
                    {
                        FeatureSetValues featureSetValues = new FeatureSetValues();
                        featureSetValues.FeatureSetName = DbHelper.DBValueToString(reader["distinctFeatureSetName"]);
                        featureSetValues.IsSelected = DbHelper.BoolFromDb(reader["selectedValue"]);
                        featureSetValues.FeatureSetId = DbHelper.IntFromDb(reader["featureSetId"]).Value;
                        featureSetValues.Value = DbHelper.DBValueToString(reader["value"]);
                        featureSetValues.InputType = DbHelper.DBValueToString(reader["inputtype"]);
                        allFeatureSetData.DistinctFeatureSet.Add(featureSetValues);
                    }
                }
                return allFeatureSetData;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<FeatureSetDataList> FeatureSetDataList(int configurationDefinitionId)
        {
            try
            {
                FeatureSetDataList featureSetDataList = new FeatureSetDataList();
                featureSetDataList.DistinctFeatureSet = new List<FeatureSetValues>();
                featureSetDataList.SelectedFeatureSetList = new List<FeatureSetValues>();

                var command = CreateCommand("[dbo].[SP_GetAllFeatureSet]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationDefinitionId", configurationDefinitionId));

                using var reader = await command.ExecuteReaderAsync();
                {
                    while (await reader.ReadAsync())
                    {
                        FeatureSetValues featureSetValues = new FeatureSetValues();
                        featureSetValues.FeatureSetName = DbHelper.DBValueToString(reader["distinctFeatureSetName"]);
                        featureSetValues.IsSelected = DbHelper.BoolFromDb(reader["selectedValue"]);
                        featureSetValues.FeatureSetId = DbHelper.IntFromDb(reader["featureSetId"]).Value;
                        featureSetValues.Value = DbHelper.DBValueToString(reader["value"]);
                        featureSetValues.InputType = DbHelper.DBValueToString(reader["inputtype"]);
                        featureSetDataList.DistinctFeatureSet.Add(featureSetValues);
                    }

                    reader.NextResult();

                    while (await reader.ReadAsync())
                    {
                        FeatureSetValues featureSetValues = new FeatureSetValues();
                        featureSetValues.FeatureSetName = DbHelper.DBValueToString(reader["featureSetName"]);
                        featureSetValues.IsSelected = DbHelper.BoolFromDb(reader["selectedValue"]);
                        featureSetValues.FeatureSetId = DbHelper.IntFromDb(reader["featureSetId"]).Value;
                        featureSetValues.Value = DbHelper.DBValueToString(reader["value"]);
                        featureSetValues.InputType = DbHelper.DBValueToString(reader["inputtype"]);
                        featureSetValues.UniqueValues = DbHelper.DBValueToString(reader["uniqueList"]);
                        featureSetDataList.SelectedFeatureSetList.Add(featureSetValues);
                    }
                }
                return featureSetDataList;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> SaveFeatureSet(SaveFeatureSetData saveFeatureSetData)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_SaveFeatureSet]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@selectedFeatureSetName", string.Join(",", saveFeatureSetData.SelectedFeatureSetName)));
                command.Parameters.Add(new SqlParameter("@isAdded", Convert.ToInt32(saveFeatureSetData.IsAdded)));
                command.Parameters.Add(new SqlParameter("@configurationDefinitionId", saveFeatureSetData.ConfigurationDefinitionId));
                command.Parameters.Add(new SqlParameter("@featureSetId", saveFeatureSetData.FeatureSetId));
                command.Parameters.Add(new SqlParameter("@featureSetName", saveFeatureSetData.SelectedFeatureSetData.name));
                command.Parameters.Add(new SqlParameter("@featureSetValue", saveFeatureSetData.SelectedFeatureSetData.value));

                return await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public async Task<Configuration> GetLatestConfiguration(int configurationDefinitionId)
        {
            var command = CreateCommand("sp_GetLatestConfiguration", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationDefinitionId", configurationDefinitionId);

            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    var into = DatabaseMapper.Instance.Create<Configuration>();
                    DatabaseMapper.Instance.FromReader(reader, into);
                    return into;
                }
            }

            return null;
        }
        public virtual async Task<int> GetPartNumberCollection(int outputTypeID)
        {
            int PartNumberCollectionID = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_GetPartNumberCollection]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@outputTypeID", outputTypeID));
                

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    PartNumberCollectionID = DbHelper.DBValueToInt(reader["PartNumberCollectionID"]);

                }
                return PartNumberCollectionID;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public virtual async Task<TopLevelPartNumber> GetTopLevelPartNumber(int configurationdefinitionID)
        {
            List<string> TopLevelPartNumberList = new List<string>();
            TopLevelPartNumber tp = new TopLevelPartNumber();
            try
            {
                var command = CreateCommand("[dbo].[SP_GetToplevelPartNumber]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationDefnitionID", configurationdefinitionID));


                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    tp.TopLevelPartnumber = DbHelper.DBValueToString(reader["TopLevelPartnumber"]);

                }
                return tp;


            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public virtual async Task<BuildTask> GetProductPlatformAircraftStatus(string TaskTypeID ,Guid userId)
        {
            try
            {
                BuildTask task = new BuildTask();
                {
                    var command = CreateCommand("[dbo].[SP_GetTask_Status]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@TaskTypeID", TaskTypeID));
                    command.Parameters.Add(new SqlParameter("@userId", userId));

                    using var reader = await command.ExecuteReaderAsync();
                    while (await reader.ReadAsync())
                    {

                        task.TaskTypeID = DbHelper.GuidFromDb(reader["TaskTypeID"]);
                        task.TaskStatusID = DbHelper.DBValueToInt(reader["TaskStatusID"]);
                        task.TaskDataJSON = DbHelper.StringFromDb(reader["TaskDataJSON"]);
                        task.PercentageComplete = DbHelper.DBValueToInt(reader["PercentageComplete"]);
                        task.ID = DbHelper.GuidFromDb(reader["ID"]);
                        task.DetailedStatus = DbHelper.StringFromDb(reader["DetailedStatus"]);
                        task.DateStarted = DbHelper.DateTimeFromDb(reader["DateStarted"]);
                        task.DateLastUpdated = DbHelper.DateTimeFromDb(reader["DateLastUpdated"]);
                        task.ConfigurationID = DbHelper.DBValueToInt(reader["ConfigurationID"]);
                        task.ConfigurationDefinitionID = DbHelper.DBValueToInt(reader["ConfigurationDefinitionID"]);
                        task.AzureBuildID = DbHelper.DBValueToInt(reader["AzureBuildID"]);
                        task.AircraftID = DbHelper.GuidFromDb(reader["AircraftID"]);
                        task.Cancelled = DbHelper.BoolFromDb(reader["Cancelled"]);
                        task.ErrorLog = DbHelper.StringFromDb(reader["ErrorLog"]);

                    }
                    return task;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

    }
}
