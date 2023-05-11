using System.Collections.Generic;

namespace backend.DataLayer.Models.Configuration
{
    public class MakkahData
    {
        public List<CityDetails> Cities { get; set; }
        public string PrayerTimeCaluculation { get; set; }
        public List<string> MakkahValues { get; set; }
    }
}
