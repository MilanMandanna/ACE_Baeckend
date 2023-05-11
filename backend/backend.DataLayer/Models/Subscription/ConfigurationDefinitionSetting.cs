using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Subscription
{
    [DataProperty(TableName = "dbo.tblConfigurationDefinitions")]
    public class ConfigurationDefinitionSetting
    {
        [DataProperty]
        public int ConfigurationTypeID { get; set; }
        [DataProperty] 
        public int AutoLock { get; set; }
        [DataProperty] 
        public int AutoDeploy { get; set; }
        [DataProperty]
        public int AutoMerge { get; set; }
    }

    public class ConfigurationSettings
    {
        public string Name { get; set; }
        public bool Value { get; set; }
    }
}
