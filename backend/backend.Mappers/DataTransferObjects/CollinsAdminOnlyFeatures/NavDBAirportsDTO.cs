using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class NavDBAirportsDTO
    {
        public string FourLetId { get; set; }

        public string ThreeLetId { get; set; }

        public string Lat { get; set; }
        public string Long { get; set; }
        public string Description { get; set; }
        public string City { get; set; }
        public int SN { get; set; }
        public int existingGeorefId { get; set; }

    }
}

