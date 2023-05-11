using backend.DataLayer.Models.Task;
using System;

namespace backend.DataLayer.Models.MergeConfiguration
{
    public class MergeConfigurationUpdateDetails
    {
        public string ReleaseNotes { get; set; }
        public string VersionDate { get; set; }
        public int VersionNumber { get; set; }
        public int ConfigurationId { get; set; }
    }

    public class MergeConfigurationAvailable
    {
        public bool IsUpdatesAvailable { get; set; }
        public string UpdateType { get; set; }
    }

    public class MergeTaskInfo
    {
        public Guid TaskId { get; set; }
        public int TaskStatus { get; set; }
        public string TasKName { get; set; }
    }
}
