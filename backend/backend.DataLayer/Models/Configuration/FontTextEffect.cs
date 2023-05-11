using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblFontTextEffect")]
    public class FontTextEffect
    {
        [DataProperty(PrimaryKey = true)]
        public int FontTextEffectID { get; set; }

        [DataProperty] public string Name { get; set; }
    }
}
