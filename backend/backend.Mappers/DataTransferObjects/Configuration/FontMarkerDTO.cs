using CsvHelper.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
     public  class FontMarkerDTO
     {
       
        public int MarkerID { get; set; }
        public string Filename { get; set; }
     }
    public class FontMarkerDTOMap : ClassMap<FontMarkerDTO>
    {
        public FontMarkerDTOMap()
        {
            //CsvHelper.TypeConversion.NullableConverter intNullableConverter = new CsvHelper.TypeConversion.NullableConverter(typeof(int?));
            Map(m => m.MarkerID).Name("MarkerId");
            Map(m => m.Filename).Name("Filename");
           



        }
    }
}
