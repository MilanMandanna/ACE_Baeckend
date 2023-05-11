using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblSpelling")]
    public class Spelling
    {
        [DataProperty(PrimaryKey = true)]
        public int SpellingID { get; set; }
        [DataProperty]
        public int GeoRefID { get; set; }
        [DataProperty]
        public int LanguageID { get; set; }
        [DataProperty]
        public string UnicodeStr { get; set; }
        [DataProperty]
        public string POISpelling { get; set; }
        [DataProperty]
        public int FontID { get; set; }
        [DataProperty]
        public int SphereMapFontID { get; set; }
        [DataProperty]
        public int DataSourceID { get; set; }
        [DataProperty]
        public DateTime TimeStampModified { get; set; }
        [DataProperty]
        public DateTime SourceDate { get; set; }
        [DataProperty]
        public bool DoSpellCheck { get; set; }
    }
}
