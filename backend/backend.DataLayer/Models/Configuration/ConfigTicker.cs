using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblTicker")]
    public class ConfigTicker
    {
        [DataProperty(PrimaryKey = true)]
        public int TickerID { get; set; }

        [DataProperty]
        public string Ticker { get; set; }
    }
}
