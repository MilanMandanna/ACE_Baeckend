using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblAppearance")]
    public class Appearance
    {
        [DataProperty(PrimaryKey = true)]
        public int AppearanceID { get; set; }
        [DataProperty] public int GeoRefID { get; set; }
        [DataProperty] public int Resolution { get; set; }
        [DataProperty] public int ResolutionMpp { get; set; }
        [DataProperty] public bool Exclude { get; set; }
        [DataProperty] public bool SphereMapExclude { get; set; }
        [DataProperty] public int CustomChangeBitMask { get; set; }
    }
}
