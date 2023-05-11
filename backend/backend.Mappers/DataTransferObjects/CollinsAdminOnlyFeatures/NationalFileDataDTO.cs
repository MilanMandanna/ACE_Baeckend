using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class NationalFileDataDTO
    {
        public string Lat { get; set; } 
        public string Long { get; set; }

        public string CityName { get; set; }
    }
}
