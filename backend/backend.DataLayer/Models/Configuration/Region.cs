using System;
using System.Collections.Generic;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    public class Region
    {
        [DataProperty] public int RegionID { get; set; }
        [DataProperty] public string RegionName { get; set; }

    }

    public class RegionInfo
    {
        [DataProperty] public int RegionID { get; set; }
        public List<RegionNameInfo> names { get; set; }
    }

    public class RegionNameInfo
    {
        [DataProperty] public int SpellingID { get; set; }
        [DataProperty] public int LanguageID { get; set; }
        [DataProperty] public string Language { get; set; }
        [DataProperty] public string RegionName { get; set; }

    }
}
