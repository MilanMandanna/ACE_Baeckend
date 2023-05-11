using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{

    [DataProperty(TableName = "dbo.tblFontFileSelectionMap")]
    public class FontConfigurationMapping
    {
        [DataProperty]
        public int ConfigurationID { get; set; }
        [DataProperty]
        public int FontFileSelectionID { get; set; }
        [DataProperty]
        public int? PreviousFontFileSelectionID { get; set; }
        [DataProperty]
        public bool IsDeleted { get; set; }
        [DataProperty]
        public string LastModifiedBy { get; set; }
        [DataProperty]
        public string Action { get; set; }
    }
}
