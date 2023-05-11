using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblwgwcities")]
    public class WorldGuideCities
    {
        [DataProperty(PrimaryKey = true)]
        public int city_id { get; set; }
        [DataProperty] 
        public int georefid { get; set; }
       
    }
}
