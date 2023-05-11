using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblScreenSize")]
    public class ScreenSize
    {
        [DataProperty(PrimaryKey = true)]
        public int ScreenSizeID { get; set; }

        [DataProperty]
        public string Description { get; set; }
    }
}
