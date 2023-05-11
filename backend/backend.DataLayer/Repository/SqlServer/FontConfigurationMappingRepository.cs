using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Data;
using System.Collections.Generic;
using backend.DataLayer.Helpers;

namespace backend.DataLayer.Repository.SqlServer
{
    public class FontConfigurationMappingRepository :
          SimpleRepository<FontConfigurationMapping>,
        IFontConfigurationMappingRepository
    {
        public FontConfigurationMappingRepository() { }

        public FontConfigurationMappingRepository(SqlConnection context, SqlTransaction transaction) :
           base(context, transaction)
        { }
        public virtual async Task<FontFileSelection> GetFontSelectionIdForFont(int fontFileId)
        {
            FontFileSelection fontFileSelection = null;
            
            var command = CreateCommand("[dbo].[SP_GetFontSelectionIdForFont]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@fontFileId", fontFileId);

            using var reader = await command.ExecuteReaderAsync();
            var selection = await DatabaseMapper.Instance.FromReaderAsync<FontFileSelection>(reader);

            if (selection.Count() > 0)
                return selection.First();
            else 
                return fontFileSelection;
        }

        public virtual async Task<int> GetFontSelectionMappingCountForConfiguration(int configurationId)
        {

            var command = CreateCommand("[dbo].[SP_GetFontSelectionMappingCount]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);

            return (int)await command.ExecuteScalarAsync();
           
        }

        public async Task<int> UpdateFontSelectionMapping(int configurationId, FontConfigurationMapping updateData)
        {
          
            var command = CreateCommand("[dbo].[SP_UpdateFontSelectionMapping]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@previousFontFileSelectionID", updateData.PreviousFontFileSelectionID);
            command.Parameters.AddWithValue("@fontFileSelectionID", updateData.FontFileSelectionID);
            command.Parameters.AddWithValue("@lastModifiedBy", updateData.LastModifiedBy);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            var result = await command.ExecuteNonQueryAsync();
            return result;

        }

        public async Task<List<FontInfo>> GetFontInfoForLangugaeId(int languageId,int geoRefCatTypeId,int resolution)
        {
            var command = CreateCommand("[dbo].[SP_GetFontInfoForLangugaeId]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@languageId", languageId);
            command.Parameters.AddWithValue("@geoRefCatTypeId", geoRefCatTypeId);
            command.Parameters.AddWithValue("@resolution", resolution);
            var reader = await command.ExecuteReaderAsync();
            List<FontInfo> lstFontInfo = new List<FontInfo>();
            FontInfo fontInfo;
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    fontInfo = new FontInfo();
                    fontInfo.FontID = DbHelper.DBValueToInt(reader["fontId"]);
                    fontInfo.FontMarkerIdID = DbHelper.DBValueToInt(reader["MarkerID"]);
                    fontInfo.FaceName = DbHelper.DBValueToString(reader["FaceName"]);
                    fontInfo.Size = DbHelper.DBValueToString(reader["Size"]);
                    fontInfo.Color = DbHelper.DBValueToString(reader["Color"]);
                    fontInfo.ShadowColor = DbHelper.DBValueToString(reader["ShadowColor"]);
                    fontInfo.FontStyle = DbHelper.DBValueToString(reader["FontStyle"]);
                    lstFontInfo.Add(fontInfo);
                }
            }
            reader.Close();
            return lstFontInfo;
        }
    }
}
