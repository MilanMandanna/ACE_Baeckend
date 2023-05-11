using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblWebMain")]
    public class ConfigWebMain
    {
        [DataProperty(PrimaryKey = true)]
        public int WebMainID { get; set; }

        [DataProperty]
        public string WebMainItems { get; set; }

        [DataProperty]
        public string InfoItems { get; set; }
    }
}
