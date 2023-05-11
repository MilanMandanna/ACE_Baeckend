namespace backend.DataLayer.Models.Configuration
{
    public class PlatformConfiguration
    {
        public int ConfigurationDefinitionID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public int PlatformId { get; set; }
        public string InstallationTypeID { get; set; } 
    }
}
