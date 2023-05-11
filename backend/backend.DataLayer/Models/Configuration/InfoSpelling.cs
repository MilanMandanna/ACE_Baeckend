using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblInfoSpellling")]
    public class InfoSpelling
    {
        [DataProperty(PrimaryKey = true)]
        public int InfoSpellingId { get; set; }

        [DataProperty] public int InfoId { get; set; }

        [DataProperty] public int LanguageId { get; set; }

        [DataProperty] public string Spelling { get; set; }
    }
}
