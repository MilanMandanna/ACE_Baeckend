using CsvHelper.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
    public  class FontCategoryDTO
    {
        
        public int GeoRefIdCatTypeID { get; set; }
        public int LanguageID { get; set; }
        public int FontID { get; set; }
        public int MarkerID { get; set; }
        public int IMarkerID { get; set; }

    }
    public class FontCategoryDTOMap : ClassMap<FontCategoryDTO>
    {
        public FontCategoryDTOMap()
        {
            //CsvHelper.TypeConversion.NullableConverter intNullableConverter = new CsvHelper.TypeConversion.NullableConverter(typeof(int?));
           
            Map(m => m.GeoRefIdCatTypeID).Name("GeoRefIdCatTypeId");
            Map(m => m.LanguageID).Name("LanguageId");
            Map(m => m.FontID).Name("FontId");
            Map(m => m.MarkerID).Name("MarkerId");
            Map(m => m.IMarkerID).Name("IMarkerId");
           


        }
    }
}
