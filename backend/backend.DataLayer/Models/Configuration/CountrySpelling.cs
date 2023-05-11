using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblCountrySpelling")]
    public class CountrySpelling
    {
        [DataProperty(PrimaryKey = true)]
        public int CountrySpellingID { get; set; }

        [DataProperty] public int CountryID { get; set; }
        [DataProperty] public string CountryName { get; set; }
        [DataProperty] public int LanguageID { get; set; }
        [DataProperty] public bool doSpellCheck { get; set; }

    }
}
