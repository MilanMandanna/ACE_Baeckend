using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class WGCityFlightInfoDTO
    {
        public int geoRefID { get; set; }
        public string[] PoiDetails { get; set; }

        public string PoiID { get; set; }
        public string CityID { get; set; }
        public string Imagefilename { get; set; }
        public string[] Captions { get; set; }
        public string CaptionsString { get; set; }
        public string[] CaptionLanguages { get; set; }
        public string CaptionLanguagesString { get; set; }
    }
}
