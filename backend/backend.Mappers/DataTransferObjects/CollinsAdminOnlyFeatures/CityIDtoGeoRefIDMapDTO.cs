using CsvHelper.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class CityIDtoGeoRefID
    {
        public int CityID { get; set; }
        public int? GeoRefID { get; set; }
    }
    public class CityIDtoGeoRefIDMap : ClassMap<CityIDtoGeoRefID>
    {
        public CityIDtoGeoRefIDMap()
        {
            //CsvHelper.TypeConversion.NullableConverter intNullableConverter = new CsvHelper.TypeConversion.NullableConverter(typeof(int?));
            Map(m => m.CityID).Name("city_id");
            Map(m => m.GeoRefID).Name("georefid");

        }
    }
}
