using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class WGDetailedFlightInfoDTO
    {
        public int CityId { get; set; }
        public int GeoRefID { get; set; }
        public string CityName { get; set; }
        public Cityguide[] CityGuides { get; set; }
        public string[] ImageFileNames { get; set; }
        public string[] ImageCaptions { get; set; }
        public string ImagesFileName { get; set; }
        public string ImagesCaption { get; set; }

        //gen_intro
        public string Sights { get; set; }
        public string Overview { get; set; }

        //entertainment
        public string Features { get; set; }

        // fun_facts
        public string Stats { get; set; }
        public string Country { get; set; }
        public string Population { get; set; }
        public string Elevation { get; set; }
        public string State { get; set; }

    }

    public class Cityguide
    {
        public string cityguide { get; set; }

        public string cityguideType { get; set; }
    }
}
