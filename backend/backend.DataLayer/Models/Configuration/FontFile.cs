using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{

    [DataProperty(TableName = "dbo.tblFontFiles")]
    public class FontFile
    {
        [DataProperty(PrimaryKey = true)]
        public int FontFileID { get; set; }

        [DataProperty] public string Description { get; set; }
        [DataProperty] public string Name { get; set; }
        [DataProperty] public int IsSelected { get; set; }

    }
}
