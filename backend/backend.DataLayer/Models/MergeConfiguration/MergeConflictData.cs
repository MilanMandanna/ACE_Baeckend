using System.Collections.Generic;

namespace backend.DataLayer.Models.MergeConfiguration
{
    public class MergeConflictData
    {
        public string ConflictSection { get; set; }
        public List<MergeConflictItem> ConflictItems { get; set; }
    }
}
