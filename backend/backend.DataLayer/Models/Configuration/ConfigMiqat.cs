using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblMiqat")]
    public class ConfigMiqat
    {
        [DataProperty(PrimaryKey = true)]
        public int MiqatID { get; set; }

        [DataProperty] public string Miqat { get; set; }

    }
}
