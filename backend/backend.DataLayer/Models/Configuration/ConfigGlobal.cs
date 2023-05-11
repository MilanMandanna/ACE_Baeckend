using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblGlobal")]
    public class ConfigGlobal
    {
        [DataProperty(PrimaryKey = true)]
        public int CustomID { get; set; }

        [DataProperty] public string Global { get; set; }
        [DataProperty] public string AirportLanguage { get; set; }
    }
}
