using backend.DataLayer.Helpers.Database;
using System;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblPlatforms")]
    public class Platform
    {
        [DataProperty(PrimaryKey = true)]
        public int PlatformID { get; set; }

        [DataProperty]
        public string Name { get; set; }

        [DataProperty]
        public string Description { get; set; }

        [DataProperty]
        public int ConfigurationDefinitionID { get; set; }

        [DataProperty]
        public Guid InstallationTypeID { get; set; }

       
    }
}