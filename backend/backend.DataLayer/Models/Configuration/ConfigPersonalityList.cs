using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblPersonalityList")]
    public class ConfigPersonalityList
    {
        [DataProperty(PrimaryKey = true)]
        public int PersonalityListID { get; set; }

        [DataProperty]
        public string Personality { get; set; }
    }
}
