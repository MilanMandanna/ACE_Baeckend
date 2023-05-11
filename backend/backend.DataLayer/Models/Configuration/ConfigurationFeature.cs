using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    public class ConfigurationFeature
    {
        [DataProperty]
        public string Name { get; set; }
        [DataProperty]
        public string Value { get; set; }
    }
}
