using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class ConfigurationAccessHintDTO
    {
        public bool GlobalConfiguration { get; set; }
        public bool ProductConfiguration { get; set; }
        public bool PlatformConfiguration { get; set; }
        public bool Operators { get; set; }
        public bool Operator { get; set; }
        public Guid OperatorID { get; set; }
        public bool Aircraft { get; set; }
        public Guid AircraftId { get; set; }
        public int AircraftConfigurationdefintionId { get; set; }

    }
}
