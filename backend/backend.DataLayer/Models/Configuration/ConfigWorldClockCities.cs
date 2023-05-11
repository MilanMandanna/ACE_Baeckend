using System;
using System.Collections.Generic;
using System.Text;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblWorldClockCities")]
    public class ConfigWorldClockCities
    {
        [DataProperty(PrimaryKey = true)]
        public int WorldClockCityID { get; set; }

        [DataProperty]
        public string WorldClockCities { get; set; }
    }
}
