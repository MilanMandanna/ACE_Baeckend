using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblwgimage")]
    public class WorldGuideImage
    {
        [DataProperty(PrimaryKey = true)]
        public int ID { get; set; }
        [DataProperty] public int ImageID { get; set; }
        [DataProperty] public string FileName { get; set; }
       
    }
}
