using System.Collections.Generic;

namespace backend.DataLayer.Models.Configuration
{
    public class SaveFeatureSetData
    {
        public List<string> SelectedFeatureSetName { get; set; }
        public bool IsAdded { get; set; } 
        public int FeatureSetId { get; set; }
        public int ConfigurationDefinitionId { get; set; }
        public FeatureSetData SelectedFeatureSetData { get; set; }
    }

    public class FeatureSetData
    {
        public string name { get; set; }
        public string value { get; set; }
    }
}
