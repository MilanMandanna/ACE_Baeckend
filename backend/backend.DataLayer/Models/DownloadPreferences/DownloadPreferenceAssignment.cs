using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.DownloadPreferences
{
    /**
     * Class that is bound to the DownloadPreferenceAssignment table in the database
     **/ 
    [DataProperty(TableName = "dbo.DownloadPreferenceAssignment")]
    public class DownloadPreferenceAssignment
    {
        [DataProperty(PrimaryKey = true)]
        public Guid Id { get; set; }

        [DataProperty]
        public Guid DownloadPreferenceId { get; set; }

        [DataProperty]
        public string PreferenceList { get; set; }

        [DataProperty]
        public Guid AircraftId { get; set; }
    }
}
