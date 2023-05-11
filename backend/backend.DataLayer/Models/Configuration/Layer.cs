using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    public class Layer
    {
        [DataProperty]
        public string Name { get; set; }
        [DataProperty]
        public string Enabled { get; set; }
        [DataProperty]
        public string Active { get; set; }
        public string DisplayName { get; set; }

    }
}
