using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblModeDefs")]
    public class ConfigModeDefs
    {
        [DataProperty(PrimaryKey = true)]
        public int ModeDefID { get; set; }

        [DataProperty]
        public string ModeDefs { get; set; }
    }
}
