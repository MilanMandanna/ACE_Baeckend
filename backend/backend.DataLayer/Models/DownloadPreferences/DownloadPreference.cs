using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.DownloadPreferences
{
    /**
     * Class that is bound to the DownloadPreference table in the database
     **/ 
    [DataProperty(TableName = "dbo.DownloadPreference")]
    public class DownloadPreference
    {
        [DataProperty(PrimaryKey = true)]
        public Guid Id { get; set; }

        [DataProperty]
        public int AssetType { get; set; }

        [DataProperty]
        public string Name { get; set; }

        [DataProperty]
        public string Title { get; set; }
    }
}
