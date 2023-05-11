using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblCountry")]
    public class Country
    {
        [DataProperty(PrimaryKey = true)]
        public int CountryID { get; set; }

        [DataProperty] public string Description { get; set; }
        [DataProperty] public string CountryCode { get; set; }
        [DataProperty] public string ISO3166Code { get; set; }
        [DataProperty] public int RegionID { get; set; }

    }


    public class CountryInfo
    {
        [DataProperty] public int CountryID { get; set; }
        [DataProperty] public string Description { get; set; }
        [DataProperty] public int RegionID { get; set; }
        public List<CountryNameInfo> names { get; set; }

    }

    public class CountryNameInfo
    {
        [DataProperty] public int CountrySpellingID { get; set; }
        [DataProperty] public int LanguageID { get; set; }
        [DataProperty] public string Language { get; set; }
        [DataProperty] public string CountryName { get; set; }

    }
}
