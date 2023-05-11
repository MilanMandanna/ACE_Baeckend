using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbinfospelling")]
    public class ASXInfoInfoSpelling
    {
        [DataProperty(PrimaryKey = true)]
        public int InfoId { get; set; }
    }
}
