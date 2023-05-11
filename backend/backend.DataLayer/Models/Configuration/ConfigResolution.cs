using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblResolution")]
    public class ConfigResolution
    {
        [DataProperty(PrimaryKey = true)]
        public int ResolutionId { get; set; }

        [DataProperty]
        public string Resolution { get; set; }
    }
}
