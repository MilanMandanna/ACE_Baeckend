using System;
namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class ConfigurationDefinitionVersionDTO
    {
        public int ConfigurationId { get; set; }
        public int Version { get; set; }
        public string Description { get; set; }
        public string LockComment { get; set; }
        public bool Locked { get; set; }
        public string LockDate { get; set; }
        public string ProductName { get; set; }
        public string PlatFormName { get; set; }
        public string TailNumber { get; set; }
    }
}
