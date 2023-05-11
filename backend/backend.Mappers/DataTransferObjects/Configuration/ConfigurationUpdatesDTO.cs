using System;
using System.Collections.Generic;

namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class ConfigurationUpdatesDTO
    {
        public IDictionary<string, UpdatesDTO> ConfigurationUpdates { get; set; }

    }
}
