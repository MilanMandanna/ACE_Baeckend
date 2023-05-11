using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblMenu")]
    public class ConfigMenu
    {
        [DataProperty(PrimaryKey = true)]
        public int MenuId { get; set; }

        [DataProperty] public string Perspective { get; set; }

        [DataProperty] public string Layers { get; set; }

        [DataProperty] public bool IsHTML5 { get; set; }
    }
}
