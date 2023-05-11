using CsvHelper.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class PoiIDtoGeoRefID
    {
        public int PoiID { get; set; }
        public int GeoRefID { get; set; }
    }
    public class PoiIDtoGeoRefIDMap : ClassMap<PoiIDtoGeoRefID>
    {
        public PoiIDtoGeoRefIDMap()
        {
            Map(m => m.PoiID).Name("poiid");
            Map(m => m.GeoRefID).Name("georefid");
        }
    }
}
