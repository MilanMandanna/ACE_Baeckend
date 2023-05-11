using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblConfigurationDefinitions")]
    public class ConfigurationDefinition
    {
        [DataProperty(PrimaryKey = true)]
        public int ConfigurationDefinitionID { get; set; }

        [DataProperty]
        public int ConfigurationDefinitionParentID { get; set; }

        [DataProperty]
        public int ConfigurationTypeID { get; set; }

        [DataProperty]
        public int OutputTypeID { get; set; }

        [DataProperty]
        public bool Active { get; set; }

        [DataProperty]
        public int AutoLock { get; set; }

        [DataProperty]
        public int AutoDeploy { get; set; }

        [DataProperty]
        public int? AutoMerge { get; set; }

        [DataProperty]
        public int? FeatureSetID { get; set; }
        [DataProperty]
        public int? UpdatedUpToVersion { get; set; }
    }
}
