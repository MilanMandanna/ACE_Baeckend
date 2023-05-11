using Ace.DataLayer.Models.DataStructures;
using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.DownloadPreferences;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace backend.DataLayer.Repository.SqlServer
{
    /**
     * Provides database access for the download preferences for aircrafts as well as access
     * to the global list of download preferences
     **/
    public class DownloadPreferenceRepository : Repository, IDownloadPreferenceRepository
    {
        public DownloadPreferenceRepository()
            {
            }
        public DownloadPreferenceRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        /**
         * Helper routine to build a download preference class from a single record
         **/
        private DownloadPreference DownloadPreferenceFromReader(SqlDataReader reader)
        {
            var preference = new DownloadPreference
            {
                Id = (Guid) reader["Id"],
                AssetType = (int) reader["AssetType"],
                Name = reader["Name"].ToString(),
                Title = reader["Title"].ToString()

            };
            return preference;
        }

        /**
         * Helper routine to build a download preference assignment from a single record
         **/
        private DownloadPreferenceAssignment DownloadPreferenceAssignmentFromReader(SqlDataReader reader)
        {
            var assignment = new DownloadPreferenceAssignment
            {
                Id = (Guid)reader["Id"],
                DownloadPreferenceId = DbHelper.GuidFromDb(reader["DownloadPreferenceId"]),
                PreferenceList = reader["PreferenceList"].ToString(),
                AircraftId = DbHelper.GuidFromDb(reader["AircraftId"])
            };
            return assignment;
        }

        /**
         * Gets the full list of global download preferences
         **/
        public virtual async Task<List<DownloadPreference>> GetAll()
        {
            var result = new List<DownloadPreference>();

            var command = CreateCommand("[dbo].[SP_GetAllDownloadPreference]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@assetType", AssetType.AirshowConfig);
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(DownloadPreferenceFromReader(reader));
                }
            }
            return result;
        }

         /**
         * Returns list downloadPreference based on the installationType
         **/
        public async Task<List<DownloadPreference>> GetDownloadPreferencesOfType(Guid installationTypeID)
        {
            var result = new List<DownloadPreference>();
           
            var command = CreateCommand("[dbo].[SP_GetDownloadPreferencesOfType]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@installationtypeID", installationTypeID);
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(DownloadPreferenceFromReader(reader));
                }
            }
            return result;
        }

        /**
         * Returns list of connectivity types from the associated aircrafs of the installationType
         **/
        public async Task <List<String>> getConnectivityTypes(Guid installationTypeID)
        {
            var result = new List<String>();
           
            var command = CreateCommand("[dbo].[SP_GetConnectivityTypes]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@installationtypeID", installationTypeID);

            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(reader.GetString(1));
                }
            }

            return result;
        }


        /**
         * Gets the full list of download preference assignments for a single aircraft. Currently t his list is filter to
         * only provide the airshow config asset (e.g. the Stage related assets are not included
         **/
        public virtual async Task<List<DownloadPreferenceAssignment>> GetAircraftDownloadPreferences(string tailNumber)
        {
            var result = new List<DownloadPreferenceAssignment>();
           
            var command = CreateCommand("[dbo].[SP_GetAircraftDownloadPreferences]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@tailNumber", tailNumber);
            command.Parameters.AddWithValue("@assetType", AssetType.AirshowConfig);

            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(DownloadPreferenceAssignmentFromReader(reader));
                }
            }
            return result;
        }

        /**
         * Returns a global download preference with the given name
         **/ 
        public virtual async Task<DownloadPreference> GetByName(string name)
        {
           
            var command = CreateCommand("[dbo].[SP_GetByNameForDownloadPreference]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@name", name);
            using (var reader = await command.ExecuteReaderAsync()) {

                if (await reader.ReadAsync())
                    return DownloadPreferenceFromReader(reader);
            }
            return null;
        }

        /**
         * Returns the download preference assignment for a single aircraft with the specified preference id. There should only
         * be one record per aircraft per download preference
         **/ 
        public virtual async Task<DownloadPreferenceAssignment> GetAircraftDownloadPreference(string tailNumber, Guid downloadPreferenceId)
        {
            
            var command = CreateCommand("[dbo].[SP_GetAircraftDownloadPreferenceId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@tailNumber", tailNumber);
            command.Parameters.AddWithValue("@downloadPreferenceId", downloadPreferenceId);
            using (var reader = await command.ExecuteReaderAsync()) {
                if (await reader.ReadAsync())
                    return DownloadPreferenceAssignmentFromReader(reader);
            }
            return null;
        }

        /**
         * Commits an updated assignment
         **/ 
        public async Task Update(DownloadPreferenceAssignment assignment)
        {
            var command = CreateCommand();
            DatabaseMapper.Instance.PrepareUpdate(assignment, command);
            await command.ExecuteNonQueryAsync();
        }

        /**
         * Inserts a new assignment
         **/ 
        public async Task Insert(DownloadPreferenceAssignment assignment)
        {
            var command = CreateCommand();
            DatabaseMapper.Instance.PrepareInsert(assignment, command);
            int results = await command.ExecuteNonQueryAsync();
        }
    }
}
