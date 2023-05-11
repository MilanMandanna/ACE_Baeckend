using System;
using System.Collections.Generic;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.CustomContent
{
    public class Airport
    {
        [DataProperty]
        public int AirportInfoID { get; set; }
        [DataProperty] public string FourLetID { get; set; }
        [DataProperty] public string ThreeLetID { get; set; }
        [DataProperty] public decimal Lat { get; set; }
        [DataProperty] public decimal Lon { get; set; }
        [DataProperty] public int GeoRefID { get; set; }
        [DataProperty] public string CityName { get; set; }
        [DataProperty] public string Country { get; set; }

        
    }

    public class CityInfo
    {
        [DataProperty]
        public int GeoRefId { get; set; }
        [DataProperty]
        public string Name { get; set; }
        [DataProperty]
        public string Country { get; set; }
    }

    public class  ListModlistInfo : Airport
    {
        public List<ModlistInfo> ModlistInfoArray { get; set; }

    }

    public class ModlistInfo
    {
        public double Row { get; set; }
        public double Column { get; set; }
        public double Resolution { get; set; } 
    }


}
