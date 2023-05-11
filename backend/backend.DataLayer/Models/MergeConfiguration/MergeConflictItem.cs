using System.Collections.Generic;

namespace backend.DataLayer.Models.MergeConfiguration
{
    public class MergeConflictItem
    {
        public int ItemId { get; set; }
        public string Description { get; set; }
        public List<int> ConflictIds { get; set; }
        public Dictionary<string, string> CollinsBuild { get; set; }
        public Dictionary<string, string> ChildBuild { get; set; }
        public MergeBuildType SelectedBuild { get; set; }
    }
}
