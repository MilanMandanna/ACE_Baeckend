using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbfontmarker")]
    public class ASXInfoFontMarker
    {
        [DataProperty(PrimaryKey = true)]
        public int MarkerId { get; set; }

        [DataProperty] public string Filename { get; set; }
    }
}
