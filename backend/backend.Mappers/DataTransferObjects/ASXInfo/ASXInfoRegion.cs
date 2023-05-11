using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbregion")]
    public class ASXInfoRegion
    {
        [DataProperty(PrimaryKey = true)]
        public int RegionId { get; set; }
    }
}
