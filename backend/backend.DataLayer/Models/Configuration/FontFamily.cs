using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "tblFontFamily")]
    public class FontFamily
    {
        [DataProperty(PrimaryKey = true)]
        public int FontFamilyID { get; set; }

        [DataProperty] public int FontFaceID { get; set; }
        [DataProperty] public string FaceName { get; set; }
        [DataProperty] public string FileName { get; set; }
        
    }
}
