using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbcountry")]
    public class ASXInfoCountry
    {
        [DataProperty(PrimaryKey = true)]
        public int CountryID { get; set; }
    }
}
