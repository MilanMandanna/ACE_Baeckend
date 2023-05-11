using backend.Helpers.Portal;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

namespace backend.Helpers.Fleet
{
    public class FleetConfigurationSection : ConfigurationSection
    {
        [ConfigurationProperty("aircraftConnectivityTypes")]
        public TypeCollection AircraftConnectivityTypes => this["aircraftConnectivityTypes"] as TypeCollection;

        [ConfigurationProperty("aircraftModels")]
        public TypeCollection Models => this["aircraftModels"] as TypeCollection;
    }
}
