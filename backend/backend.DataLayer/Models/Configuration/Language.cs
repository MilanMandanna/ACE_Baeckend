using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataMapping(DataPrimaryKey = "LanguageID", MappingTable = "dbo.tblLanguagesMap", MappingPrimaryKey = "LanguageID")]
    [DataProperty(TableName = "dbo.tblLanguages")]
    public class Language
    {
        [DataProperty(PrimaryKey = true)]
        public int ID { get; set; }

        [DataProperty] public int LanguageID { get; set; }
        [DataProperty] public string Name { get; set; }
        [DataProperty] public string NativeName { get; set; }
        [DataProperty] public string Description { get; set; }
        [DataProperty] public bool ISLatinScript { get; set; }
        [DataProperty] public int Tier { get; set; }

        [DataProperty(FieldName = "2LetterID_4xxx")]
        public string TwoLetterID_4xxx { get; set; }

        [DataProperty(FieldName = "3LetterID_4xxx")]   
        public string ThreeLetterID_4xxx { get; set; }

        [DataProperty(FieldName = "2LetterID_ASXi")]
        public string TwoLetterID_ASXi { get; set; }

        [DataProperty(FieldName ="3LetterID_ASXi")]
        public string ThreeLetterID_ASXi { get; set; }

        [DataProperty] public int HorizontalOrder { get; set; }
        [DataProperty] public int HorizontalScroll { get; set; }
        [DataProperty] public int VerticalOrder { get; set; }
        [DataProperty] public int VerticalScroll { get; set; }
    }
}
