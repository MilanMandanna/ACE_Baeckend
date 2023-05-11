using System.Collections.Generic;

namespace backend.DataLayer.Models.Configuration
{
    public class PlatformConfigurationData
    {
        public IEnumerable<Platform> PlatformList { get; set; }
        public IEnumerable<InstallationTypes> InstallationTypes { get; set; }
        public IEnumerable<OutputTypes> OutputTypes { get; set; }
    }
}
