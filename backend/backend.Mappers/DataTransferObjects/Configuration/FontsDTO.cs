using CsvHelper.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
   public  class FontsDTO
    {
       
            public int FontId { get; set; }

            public string Description { get; set; }

            public int Size { get; set; }

            public string Color { get; set; }

            public string FontFaceId { get; set; }

            public string FontStyle { get; set; }
            public string ShadowColor { get; set; }


    }
    public class FontsDTOMap : ClassMap<FontsDTO>
    {
        public FontsDTOMap()
        {
            //CsvHelper.TypeConversion.NullableConverter intNullableConverter = new CsvHelper.TypeConversion.NullableConverter(typeof(int?));
            Map(m => m.FontId).Name("FontId");
            Map(m => m.FontFaceId).Name("FontFaceId");
            Map(m => m.Description).Name("Description");
            Map(m => m.FontStyle).Name("FontStyle");
            Map(m => m.ShadowColor).Name("ShadowColor");
            Map(m => m.Size).Name("Size");
            Map(m => m.Color).Name("Color");
            

        }
    }
}
