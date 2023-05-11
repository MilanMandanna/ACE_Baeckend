using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tblanguage")]
    public class ASXInfoLanguage
    {
        [DataProperty(PrimaryKey = true)]
        public int LanguageID { get; set; }

        [DataProperty] public string Name { get; set; }
        [DataProperty] public string TwoLetterID { get; set; }
        [DataProperty] public string ThreeLetterID { get; set; }
        [DataProperty] public int HorizontalOrder { get; set; }
        [DataProperty] public int HorizontalScroll { get; set; }
        [DataProperty] public int VerticalOrder { get; set; }
        [DataProperty] public int VerticalScroll { get; set; }
    }
}
