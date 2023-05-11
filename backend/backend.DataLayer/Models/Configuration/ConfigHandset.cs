using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblHandSet")]
    public class ConfigHandset
    {
        [DataProperty(PrimaryKey = true)]
        public int HandSetID { get; set; }

        [DataProperty]
        public string HandSet { get; set; }
    }
}
