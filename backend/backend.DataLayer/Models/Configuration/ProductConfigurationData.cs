using System.Collections.Generic;

namespace backend.DataLayer.Models.Configuration
{
    public class ProductConfigurationData
    {
        public int ConfigurationDefinitionId { get; set; }
        public int OutputTypeID { get; set; }
        public string ProductName { get; set; }
        public string ProductDescription { get; set; }
        public List<PlatformConfiguration> PlatformConfiguration { get; set; }
        public string TopLevelPartNumber { get; set; }
        public string Type { get; set; }
    }
}
