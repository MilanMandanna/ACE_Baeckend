using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Helpers;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ASXiInsetRepository :
        SimpleRepository<ASXiInset>,
        IASXiInsetRepository
    {
        public ASXiInsetRepository(SqlConnection context, SqlTransaction transaction) :
        base(context, transaction)
        { }

        /// <summary>
        /// 1. The procedure is used to add new mapinsets to tblASXiInset
        /// 2. execute SP_AddNewInsets 'Beijing', 3.75, 'test/Beijing.zip','LandSat7',364,369,1432,1437,38.12211,37.69572,23.74508,24.17147,false,'<![CDATA[
        ///FC 00 00 00 FC 00 00 00 FC 00 00 00 F8 00 00 00 3C 00 00 00 A4 00 00 00]]>';
        /// </summary>
        public async Task<int> AddASXiInset(int configurationId, ASXiInset mapInset, Guid userId)
        {
            string returnValue = string.Empty;
            var command = CreateCommand("SP_Insets_Add");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@ConfigurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@MapInsetName", mapInset.InsetName));
            command.Parameters.Add(new SqlParameter("@ZoomLevel", mapInset.Zoom));
            command.Parameters.Add(new SqlParameter("@MapInsetsPath", mapInset.Path));
            command.Parameters.Add(new SqlParameter("@MapPackageType", mapInset.MapPackageType));
            command.Parameters.Add(new SqlParameter("@RowStart", mapInset.RowStart));
            command.Parameters.Add(new SqlParameter("@RowEnd", mapInset.RowEnd));
            command.Parameters.Add(new SqlParameter("@ColStart", mapInset.ColStart));
            command.Parameters.Add(new SqlParameter("@ColEnd", mapInset.ColEnd));
            command.Parameters.Add(new SqlParameter("@LatStart", mapInset.LatStart));
            command.Parameters.Add(new SqlParameter("@LatEnd", mapInset.LatEnd));
            command.Parameters.Add(new SqlParameter("@LongStart", mapInset.LongStart));
            command.Parameters.Add(new SqlParameter("@LongEnd", mapInset.LongEnd));
            command.Parameters.Add(new SqlParameter("@IsHf", mapInset.IsHf));
            command.Parameters.Add(new SqlParameter("@Cdata", mapInset.Cdata));
            command.Parameters.Add(new SqlParameter("@userId", userId.ToString()));
            command.Parameters.Add(new SqlParameter("@IsUhf", mapInset.IsUHf));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (reader.Read())
                {
                    returnValue =(reader["message"].ToString());
                }
                if (string.IsNullOrWhiteSpace(returnValue) || returnValue.ToLower() == "failure")
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

        public async Task<List<ASXiInset>> GetASXiInsets(int configurationID)
        {
            List<ASXiInset> insets = new List<ASXiInset>();
            var command = CreateCommand("[dbo].[SP_GetASXiInsets]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationID", configurationID);
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (reader.HasRows)
                {
                    while (await reader.ReadAsync())
                    {
                        ASXiInset inset = new ASXiInset();

                        inset.InsetName = DbHelper.DBValueToString(reader["InsetName"]);
                        inset.Zoom = DbHelper.DoubleFromDB(reader["Zoom"]);
                        inset.Path = DbHelper.DBValueToString(reader["Path"]);
                        inset.RowStart = DbHelper.DBValueToInt(reader["RowStart"]);
                        inset.RowEnd = DbHelper.DBValueToInt(reader["RowEnd"]);
                        inset.ColStart = DbHelper.DBValueToInt(reader["ColStart"]);
                        inset.ColEnd = DbHelper.DBValueToInt(reader["ColEnd"]);
                        inset.LatStart = DbHelper.DoubleFromDB(reader["LatStart"]);
                        inset.LatEnd = DbHelper.DoubleFromDB(reader["LatEnd"]);
                        inset.LongStart = DbHelper.DoubleFromDB(reader["LongStart"]);
                        inset.LongEnd = DbHelper.DoubleFromDB(reader["LongEnd"]);
                        inset.IsHf = DbHelper.BoolFromDb(reader["IsHf"]);
                        inset.PartNumber = DbHelper.DBValueToInt(reader["PartNumber"]);
                        inset.Cdata = DbHelper.DBValueToString(reader["Cdata"]);
                        insets.Add(inset);
                    }
                }
            }

            return insets;
        }
    }
}
