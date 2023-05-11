using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblCategoryType")]
    public class GeoRefCategoryType
    {
        [DataProperty(PrimaryKey = true)]
        public int CategoryTypeID { get; set; }

        [DataProperty] public int GeoRefCategoryTypeID { get; set; }
        [DataProperty] public int GeoRefCategoryTypeID_ASXIAndroid { get; set; }
        [DataProperty] public string Description { get; set; }
    }
}
