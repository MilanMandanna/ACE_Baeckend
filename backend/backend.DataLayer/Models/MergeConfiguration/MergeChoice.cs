using System.Collections.Generic;

namespace backend.DataLayer.Models.MergeConfiguration
{
    public enum MergeChoice
    {
        Merged = 1,
        Conflicted = 2,
        Resolved = 3,
        SelectedParent = 4,
        SelectedChild = 5
    }
}
