using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class ConfigurationDefinitionDTO
    {
        public int ConfigurationDefinitionID { get; set; }
        public int ParentConfigurationDefinitionID { get; set; }
        public string Name { get; set; }
        public string ConfigurationDefinitionType { get; set; }
        public string Description { get; set; }
        public int OutputTypeId { get; set; }
        public int PartNumberCollectionID { get; set; }
        public string TopLevelPartnumber { get; set; }
    }
}
