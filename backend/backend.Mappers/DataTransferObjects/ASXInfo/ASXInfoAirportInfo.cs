using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbairportinfo")]
    public class ASXInfoAirportInfo
    {
        [DataProperty] public string FourLetId { get; set; }
        [DataProperty] public string ThreeLetId { get; set; }
        [DataProperty] public decimal Lat { get; set; }
        [DataProperty] public decimal Lon { get; set; }
        [DataProperty] public int PointGeoRefId { get; set; }
        [DataProperty] public int AirportGeoRefId { get; set; }
    }
}
