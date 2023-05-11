using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.CustomContent
{
    public class City
    {
        public int ASXiInsetID { get; set; }
        public string InsetName { get; set; }
        public bool IsHf { get; set; }
        public bool IsUHf { get; set; }

    }

    public class CityData
    {
        public int GeoRefId { get; set; }
        public int LanguageId { get; set; }
        public string Lon { get; set; }
        public string Lat { get; set; }
        public string PlaceName { get; set; }
    }


}
