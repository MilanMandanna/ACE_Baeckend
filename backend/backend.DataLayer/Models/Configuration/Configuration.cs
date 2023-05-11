using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblConfigurations")]
    public class Configuration 
    {
        [DataProperty(PrimaryKey = true)]
        public int ConfigurationId { get; set; }

        [DataProperty] public int ConfigurationDefinitionId { get; set; }
        [DataProperty] public int Version { get; set; }
        [DataProperty] public bool Locked { get; set; }
        [DataProperty] public string Description { get; set; }
        [DataProperty] public string LockComment { get; set; }
        [DataProperty] public DateTimeOffset LockDate { get; set; }


    }
    public class ConfigurationName :Configuration
    {
        public string ProductName { get; set; }
        public string PlatFormName { get; set; }
        public string TailNumber { get; set; }
    }


}
