using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbfontfamily")]
    public class ASXInfoFontFamily
    {
        [DataProperty(PrimaryKey = true)]
        public int FontFaceId { get; set; }

        [DataProperty] public string FaceName { get; set; }

        [DataProperty] public string FileName { get; set; }
    }
}
