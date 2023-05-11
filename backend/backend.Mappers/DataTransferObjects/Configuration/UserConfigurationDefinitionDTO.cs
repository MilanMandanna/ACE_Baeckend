using System;
namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class UserConfigurationDefinitionDTO
    {
        
        public int ConfigurationDefinitionID { get; set; }
        public int ConfigurationDefinitionParentID { get; set; }
        public string Name { get; set; }
        public string ConfigurationDefinitionType { get; set; }
        public int Updates { get; set; }
        public int Editable { get; set; }

    }
}
