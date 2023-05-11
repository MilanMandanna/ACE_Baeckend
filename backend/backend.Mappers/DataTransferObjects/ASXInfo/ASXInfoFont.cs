using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbfont")]
    public class ASXInfoFont
    {
        [DataProperty(PrimaryKey = true)]
        public int FontId { get; set; }

        [DataProperty] public string Description { get; set; }

        [DataProperty] public int Size { get; set; }
        [DataProperty] public string Color { get; set; }
        [DataProperty] public string ShadowColor { get; set; }
        [DataProperty] public int FontFaceId { get; set; }
        [DataProperty] public int FontStyle { get; set; }
    }
}
