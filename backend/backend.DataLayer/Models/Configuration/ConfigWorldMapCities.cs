using System;
using System.Collections.Generic;
using System.Text;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblWorldMapCities")]
    public class ConfigWorldMapCities
    {
        [DataProperty(PrimaryKey = true)]
        public int WorldMapCityID { get; set; }

        [DataProperty]
        public string WorldMapCities { get; set; }
    }
}
