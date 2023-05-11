using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    public class CreateProductorPlatformData
    {
        public int ParentConfigurationDefinitionID { get; set; }
        public string Description { get; set; }
        public string Name { get; set; }
        public string CreationType { get; set; }
    }
}
