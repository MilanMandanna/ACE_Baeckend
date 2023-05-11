using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;

namespace backend.DataLayer.Repository.SqlServer
{
    public class RegionRepository : Repository, IRegionRepository
    {
        public RegionRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public RegionRepository()
        {
        }

        public virtual async Task<IEnumerable<Region>> GetAllRegions(int configurationId)
        {
            IEnumerable<Region> regions;

            var command = CreateCommand("dbo.SP_Region_GetAll");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);

            using (var reader = await command.ExecuteReaderAsync())
            {
                regions = await DatabaseMapper.Instance.FromReaderAsync<Region>(reader);
            }

            return regions;
        }

        public virtual async Task<RegionInfo> GetRegionInfo(int configurationId, int regionId)
        {
            RegionInfo regionInfo = new RegionInfo();
            var names = new List<RegionNameInfo>();

            var command = CreateCommand("dbo.SP_Region_GetDetails");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@regionId", regionId);
            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    regionInfo.RegionID = reader.GetInt32(0);
                    RegionNameInfo name = new RegionNameInfo();
                    name.SpellingID = reader.GetInt32(1);
                    name.LanguageID = reader.GetInt32(2);
                    name.Language = reader.GetString(3).ToLower();
                    name.RegionName = reader.GetString(4);
                    names.Add(name);
                }
                regionInfo.names = names;
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return regionInfo;
        }

        public virtual async Task<int> UpdateRegion(int configurationId, int regionId, int languageId, string regionName)
        {
            var command = CreateCommand("[dbo].[SP_Region_UpdateDetails]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@regionId", regionId);
            command.Parameters.AddWithValue("@languageId", languageId);
            command.Parameters.AddWithValue("@regionName", regionName);

            int result = await command.ExecuteNonQueryAsync();
            return result > 0 ? 1 : 0;
        }

        public virtual async Task<int> AddRegion(int configurationId, string regionName)
        {
            var command = CreateCommand("[dbo].[SP_Region_Add]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@regionName", regionName);

            int result = -1;
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result = reader.GetInt32(0);
                }
            }
            return result;
        }

        public virtual async Task<int> AddRegionDetails(int configurationId, int regionId,int languageId, string regionName)
        {
            var command = CreateCommand("[dbo].[SP_Region_AddRegionDetails]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@regionId", regionId);
            command.Parameters.AddWithValue("@languageId", languageId);
            command.Parameters.AddWithValue("@regionName", regionName);

            int result = -1;
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result = reader.GetInt32(0);
                }
            }
            return result;
        }
    }
}
