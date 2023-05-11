using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblTimeZoneGlobePlaceNames")]
    public class ConfigTimeZoneGlobePlaceNames
    {
        [DataProperty(PrimaryKey = true)]
        public int PlaceNameID { get; set; }

        [DataProperty]
        public string PlaceNames { get; set; }
    }
}
