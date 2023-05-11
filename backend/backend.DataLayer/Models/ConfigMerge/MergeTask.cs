using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.ConfigMerge
{
    public class MergeTask
    {
        public Guid TaskId { get; set; }
        public int ParentConfigId { get; set; }
        public int ChildConfigId { get; set; }
    }
}
