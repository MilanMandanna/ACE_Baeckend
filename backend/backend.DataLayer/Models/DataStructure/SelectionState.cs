using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.DataStructure
{
    /**
     * Enumeration for represented the selected state of a feature
     **/ 
    public enum SelectionState
    {
        NotSelected = 0,
        PartiallySelected = 1,
        NotSubscribed = 3,
        Selected = 4,
        LimitExceeded = 5
    }
}
