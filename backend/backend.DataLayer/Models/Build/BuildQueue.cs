using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Build
{
    public class BuildQueue
    {
        public int ConfigurationId { get; set; }
        public string LockComments { get; set; }
        public Guid StartedByUserId { get; set; }
        public Guid TaskId { get; set; }
        public int ConfigurationDefinitionID { get; set; }
    }
}
