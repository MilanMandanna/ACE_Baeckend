using System;
using System.Collections.Generic;
using System.Text;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblConfigurationComponentsMap")]
    public class ConfigurationComponentMapping
    {
        [DataProperty]
        public int ConfigurationComponentID { get; set; }
        [DataProperty]
        public int ConfigurationID { get; set; }
        [DataProperty]
        public int? PreviousConfigurationComponentID { get; set; }
        [DataProperty]
        public bool IsDeleted { get; set; }
        [DataProperty]
        public string LastModifiedBy { get; set; }
        [DataProperty]
        public string Action { get; set; }
        [DataProperty]
        public int TimeStampModified { get; set; }
    }
}
