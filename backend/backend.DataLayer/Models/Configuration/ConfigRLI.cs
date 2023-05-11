using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblRli")]
    public class ConfigRLI
    {
        [DataProperty(PrimaryKey = true)]
        public int RLIID { get; set; }

        [DataProperty]
        public string Rli { get; set; }
    }
}
