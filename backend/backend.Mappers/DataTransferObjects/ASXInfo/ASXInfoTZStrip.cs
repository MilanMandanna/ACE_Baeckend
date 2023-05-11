using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbtzstrip")]
    public class ASXInfoTZStrip
    {
        [DataProperty] public int GeoRefId { get; set; }

        [DataProperty] public int TimeZoneStrip { get; set; }
    }
}
