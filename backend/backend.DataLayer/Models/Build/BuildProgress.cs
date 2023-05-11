using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Build
{
    public class BuildProgress
    {
    
        [DataProperty]
        public Guid ID { get; set; }
        [DataProperty]
        public double PercentageComplete { get; set; }
        [DataProperty] public string DetailedStatus { get; set; }
        [DataProperty] public string DateStarted { get; set; }
        public string Version { get; set; }
        
    }
}
