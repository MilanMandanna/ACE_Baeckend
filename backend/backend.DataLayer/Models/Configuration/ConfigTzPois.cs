using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblTzPois")]
    public class ConfigTzPois
    {
        [DataProperty(PrimaryKey = true)]
        public int TzPoisID { get; set; }

        [DataProperty]
        public string TZPois { get; set; }
    }
}
