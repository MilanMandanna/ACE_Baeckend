using System;
namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class AircraftConfigurationDTO
    {
        public Guid Id { get; set; }
        public int ConfigurationDefinitionId { get; set; }
        public string SerialNumber { get; set; }
        public string TailNumber { get; set; }
        public int ConfigurationID { get; set; }
    }
}