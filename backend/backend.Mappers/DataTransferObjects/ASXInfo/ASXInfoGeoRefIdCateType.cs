using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbgeorefidcategorytype")]
    public class ASXInfoGeoRefIdCateType
    {
        [DataProperty(PrimaryKey = true)]
        public int GeoRefIdCatTypeId { get; set; }

        [DataProperty] public string Description { get; set; }
    }
}
