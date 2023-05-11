using System.Collections.Generic;

namespace backend.DataLayer.Models.Configuration
{
    public class ModListJsonData
    {

        public class ModListPOI
        {
            public POI POI { get; set; }
        }

        public class POI
        {
            public List<ModListJSON> Cities { get; set; }
            public List<ModListJSON> LandFeatures { get; set; }
            public List<ModListJSON> WaterFeatures { get; set; }
            public List<ModListJSON> Airports { get; set; }
        }

        public class ModListJSON
        {
            public int Id { get; set; }
            public float Lat { get; set; }
            public float Lon { get; set; }
            public int Pri { get; set; }
            public int IPOI { get; set; }
            public int Cat { get; set; }
            public string Name { get; set; }
        }
    }
}
