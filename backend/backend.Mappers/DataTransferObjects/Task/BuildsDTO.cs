using System;
namespace backend.Mappers.DataTransferObjects.Task
{
    public class BuildsDTO
    {
        public Guid ID { get; set; }
        public string DefinitionName { get; set; }
        public string BuildStatus { get; set; }
        public double PercentageComplete { get; set; }
        public string ConfigurationVersion { get; set; }
        public int ConfigurationID { get; set; }
        public int ConfigurationDefinitionID { get; set; }
        public string DateStarted { get; set; }
        public string TaskTypeName { get; set; }


    }
}
