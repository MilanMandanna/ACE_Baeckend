using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblMakkah")]
    public class ConfigMakkah
    {
        [DataProperty(PrimaryKey = true)]
        public int MakkahID { get; set; }

        [DataProperty]
        public string Makkah { get; set; }
    }
}
