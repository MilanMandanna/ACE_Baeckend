using CsvHelper.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
     public class FontFamilyDTO
     {
        public int FontFamilyID { get; set; }
        public int FontFaceID { get; set; }
        public string FaceName { get; set; }
        public string FileName { get; set; }
    }
    public class FontFamilyDTOMap : ClassMap<FontFamilyDTO>
    {
        public FontFamilyDTOMap()
        {
            //CsvHelper.TypeConversion.NullableConverter intNullableConverter = new CsvHelper.TypeConversion.NullableConverter(typeof(int?));
            Map(m => m.FontFaceID).Name("FontFaceId");
            Map(m => m.FaceName).Name("FaceName");
            Map(m => m.FileName).Name("FileName");
           


        }
    }
}
