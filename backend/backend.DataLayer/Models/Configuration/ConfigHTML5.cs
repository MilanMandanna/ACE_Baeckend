using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblHtml5")]
    public class ConfigHTML5
    {
        [DataProperty(PrimaryKey = true)]
        public int Html5ID { get; set; }

        [DataProperty]
        public string Category { get; set; }

        [DataProperty]
        public string InfoItems { get; set; }
    }
}
