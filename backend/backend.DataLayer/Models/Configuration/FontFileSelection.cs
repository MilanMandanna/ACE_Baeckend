using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblFontFileSelection")]
    public class FontFileSelection
    {
        [DataProperty(PrimaryKey = true)]
        public int FontFileSelectionID { get; set; }
        [DataProperty]
        public int FontFileID { get; set; }
    }
}
