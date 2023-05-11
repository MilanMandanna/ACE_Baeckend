using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    public class AdminOnlyDownloadDetails
    {
        public string Author { get; set; }
        public DateTime Date { get; set; }
        public int Revision { get; set; }
        public string TaskId { get; set; }
        public int ConfigurationId { get; set; }
        public int ConfigurationDefinitionId { get; set; }
    }
}
