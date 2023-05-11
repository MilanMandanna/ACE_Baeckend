using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblMaps")]
    public class ConfigMaps
    {
        [DataProperty(PrimaryKey = true)]
        public int MapID { get; set; }

        [DataProperty] public string MapItems { get; set; }

        [DataProperty] public string HardwareCaps { get; set; }

        [DataProperty] public string Borders { get; set; }

        [DataProperty] public string BroadCastBorders { get; set; }

    }
}
