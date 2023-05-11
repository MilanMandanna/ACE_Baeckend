using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    public class RegionSpellingRepository :
        SimpleRepository<RegionSpelling>,
        IRegionSpellingRepository
    {
        public RegionSpellingRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }

        public async Task<SqlDataReader> GetExportASXI3dRegionSpelling(int configurationId,List<Language> languages)
        {
            string languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));

            var command = CreateCommand("[dbo].[sp_GetExportASXI3dRegionSpelling]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@languages", languageCodes);

            command.CommandTimeout = 0;
            var reader = await command.ExecuteReaderAsync();
            return reader;
        }

        public async Task<SqlDataReader> GetExportASXInfoRegionSpellings(int configurationId, List<Language> languages)
        {
            string languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));
            string sql = "";
            sql += "select * from( ";
            sql += "select regionid, regionname as name, tbllanguages.[2LetterID_ASXi] as code ";
            sql += "from tblregionspelling ";
            sql += "inner join tblregionspellingmap on tblregionspellingmap.spellingid = tblregionspelling.spellingid ";
            sql += "inner join tbllanguages on tblregionspelling.languageid = tbllanguages.languageid ";
            sql += "inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.id ";
            sql += "where tbllanguagesmap.configurationid = @configurationId ";
            sql += "and tblregionspellingmap.configurationid = @configurationId ";
            sql += ") as sourcetable ";
            sql += "pivot( ";
            sql += "max(name) ";
            sql += $"for code in ({languageCodes}) ";
            sql += ") as pivottable ";
            sql += "order by regionid";
            var command = CreateCommand(sql);
            command.Parameters.AddWithValue("@configurationId", configurationId);
			command.CommandTimeout = 0;
            return await command.ExecuteReaderAsync();
        }
    }
}
