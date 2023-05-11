using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblFontDefaultCategory")]
    public class FontDefaultCategory
    {
        [DataProperty(PrimaryKey = true)]
        public int FontDefaultCategoryID { get; set; }

        [DataProperty] public int GeoRefIdCatTypeID { get; set; }
        [DataProperty] public int FontID { get; set; }
        [DataProperty] public int MarkerID { get; set; }
        [DataProperty] public int Resolution { get; set; }
        [DataProperty] public int SphereFontId { get; set; }
        [DataProperty] public int AtlasMarkerId { get; set; }
        [DataProperty] public int SphereMarkerId { get; set; }
    }
}
