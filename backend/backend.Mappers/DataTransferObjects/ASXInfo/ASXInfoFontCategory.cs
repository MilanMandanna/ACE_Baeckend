using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbfontcategory")]
    public class ASXInfoFontCategory
    {
        [DataProperty] public int GeoRefIdCatTypeId { get; set; }
        [DataProperty] public int LanguageId { get; set; }
        [DataProperty] public int FontId { get; set; }
        [DataProperty] public int MarkerId { get; set; }
        [DataProperty] public int IMarkerId { get; set; }
    }
}
