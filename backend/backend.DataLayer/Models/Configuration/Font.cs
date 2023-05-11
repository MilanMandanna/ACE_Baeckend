using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblFont")]
    public class Font
    {
        [DataProperty(PrimaryKey = true)]
        public int FontID { get; set; }

        [DataProperty] public string Description { get; set; }
        [DataProperty] public int Size { get; set; }
        [DataProperty] public string Color { get; set; }
        [DataProperty] public string ShadowColor { get; set; }
        [DataProperty] public int FontFaceId { get; set; }
        [DataProperty] public int FontStyle { get; set; }
        [DataProperty] public int PxSize { get; set; }
        [DataProperty] public int TextEffectId { get; set; }
    }

    public class FontInfo
    {
        public int FontID { get; set; }
        public int FontMarkerIdID { get; set; }
        public string FaceName { get; set; }
        public string Size { get; set; }
        public string Color { get; set; }
        public string ShadowColor { get; set; }
        public string FontStyle { get; set; }
    }
}
