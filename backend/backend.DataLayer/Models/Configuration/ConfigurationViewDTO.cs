using System.Collections.Generic;

namespace backend.DataLayer.Models.Configuration
{
    public class ConfigurationViewDTO
    {
        public List<Views> ConfigurationData { get; set; }
    }

    public class Views
    {
        public string Name { get; set; }
        public bool Preset { get; set; }
    }
}
