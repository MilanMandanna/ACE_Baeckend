using System.Collections.Generic;

namespace backend.DataLayer.Models.Configuration
{
    public class FeatureSetValues
    {
        public string FeatureSetName { get; set; }
        public string Value { get; set; }
        public bool IsSelected { get; set; }
        public int FeatureSetId { get; set; }
        public string InputType { get; set; }
        public string UniqueValues { get; set; }
    }

    public class AllFeatureSetData
    {
        public List<FeatureSetValues> DistinctFeatureSet { get; set; }
    }

    public class FeatureSetDataList
    {
        public List<FeatureSetValues> DistinctFeatureSet { get; set; }
        public List<FeatureSetValues> SelectedFeatureSetList { get; set; }
    }
}
