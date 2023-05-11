using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    public class ConfigAvailableLocationsDTO
    {
        public List<CityDetails> Cities { get; set; }
    }
    public class CityDetails
    {
        public int GeoRefid { get; set; }
        public string Name { get; set; }
        public string State { get; set; }
        public string Country { get; set; }
        public string GmtOffset { get; set; }
    }

    public class CompassLocationsDTO
    {
        public List<LocationDetails> LocationDetails { get; set; }
    }
    public class LocationDetails
    {
        public int Index { get; set; }
        public CityDetails Location { get; set; }
    }

    public class TimezoneLocationDTO
    {
        public List<CityDetails> TimeZoneLocations { get; set; }
    }

    public class WorldClockLocationsDTO
    {
        public List<CityDetails> WorldclockLocations { get; set; }
    }

    public class AirplaneTypes
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public class AirplaneData
    {
        public List<AirplaneTypes> AirplaneList { get; set; }
    }

    public class MakkahLocations
    {
        public List<CityDetails> AvailableMakkahLocations { get; set; }
    }

    public class FlightInfoParams
    {
        public string Name { get; set; }
        public string DisplayName { get; set; }
    }
}
