using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblRegionSpelling")]
    public class RegionSpelling
    {
        [DataProperty(PrimaryKey = true)]
        public int SpelllingID { get; set; }

        [DataProperty] public int RegionID { get; set; }
        [DataProperty] public string RegionName { get; set; }
        [DataProperty] public int LanguageId { get; set; }
    }
}
