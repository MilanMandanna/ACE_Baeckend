using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblAirportInfo")]
    public class AirportInfo
    {
        [DataProperty(PrimaryKey = true)]
        public int AirportInfoID { get; set; }

        [DataProperty] public string FourLetID { get; set; }
        [DataProperty] public string ThreeLetID { get; set; }
        [DataProperty] public decimal Lat { get; set; }
        [DataProperty] public decimal Lon { get; set; }
        [DataProperty] public int GeoRefID { get; set; }
        [DataProperty] public string CityName { get; set; }
        [DataProperty] public int DataSourceID { get; set; }

    }
}
