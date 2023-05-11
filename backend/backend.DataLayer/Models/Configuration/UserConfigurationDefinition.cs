using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
   
        [DataProperty(TableName = "dbo.tblConfigurationDefinitions")]
        public class UserConfigurationDefinition : ConfigurationDefinition
        {
            [DataProperty]
            public String Name { get; set; }

            [DataProperty]
            public String ConfigurationDefinitionType { get; set; }

            [DataProperty]
            public int Editable { get; set; }

        public int Updates { get; set; }
    
        }


    public class ConfigurationDefinitionDetails
    {
        [DataProperty]
        public int ConfigurationDefinitionID { get; set; }

        [DataProperty]
        public int ConfigurationDefinitionTypeID { get; set; }

        [DataProperty]
        public String ConfigurationDefinitionType { get; set; }
    }

}
