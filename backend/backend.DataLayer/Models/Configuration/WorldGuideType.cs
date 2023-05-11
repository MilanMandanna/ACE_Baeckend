using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblwgtype")]
    public class WorldGuideType
    {
        [DataProperty(PrimaryKey = true)]
        public int WGTypeID { get; set; }
        [DataProperty] public int TypeID { get; set; }
        [DataProperty] public string Description { get; set; }
        [DataProperty] public int Layout { get; set; }
        [DataProperty] public int ImageWidth { get; set; }
        [DataProperty] public int ImageHeight { get; set; }


    }
}
