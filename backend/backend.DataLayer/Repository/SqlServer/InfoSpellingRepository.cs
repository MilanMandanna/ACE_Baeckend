using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    public class InfoSpellingRepository :
        SimpleRepository<InfoSpelling>,
        IInfoSpellingRepository
    {
        public InfoSpellingRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }

        public async Task<SqlDataReader> GetExportSpellingsForConfig(int configurationId, List<Language> languages)
        {
            // todo need to account for the configuration id
            string languageCodes = string.Join(", ", languages.Select(x => $"[{x.TwoLetterID_ASXi}]"));
            string sql = "";
            sql += "select * from ( ";
            sql += "select infoid, spelling, tbllanguages.[2LetterID_ASXi] as code ";
            sql += "from tblinfospelling ";
            sql += "inner join tblinfospellingmap on tblinfospellingmap.infospellingid = tblinfospelling.infospellingid ";
            sql += "inner join tbllanguages on tbllanguages.languageid = tblinfospelling.languageid ";
            sql += "inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.ID ";
            sql += "where tblinfospellingmap.configurationid = @configurationId ";
            sql += "and tbllanguagesmap.configurationid = @configurationId ";
            sql += ") as sourcetable ";
            sql += "pivot ( ";
            sql += "max(spelling) ";
            sql +=$"for code in ({languageCodes}) ";
            sql += ") as pivottable ";
            sql += "order by infoid";
            var command = CreateCommand(sql);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await command.ExecuteReaderAsync();
        }
    }
}
