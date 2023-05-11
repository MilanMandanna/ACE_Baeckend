using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblScriptDefs")]
    public class ConfigScriptDefs
    {
        [DataProperty(PrimaryKey = true)]
        public int ScriptDefID { get; set; }

        [DataProperty]
        public string ScriptDefs { get; set; }
    }
}
