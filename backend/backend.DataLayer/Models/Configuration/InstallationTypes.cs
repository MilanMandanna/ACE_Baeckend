using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    public class InstallationTypes
    {
        [DataProperty(PrimaryKey = true)]
        public Guid ID {get;set;}

        [DataProperty]
        public string InstallationTypeValue { get; set; }

        [DataProperty]
        public string SupportedConnectionType { get; set; }

        [DataProperty]
        public Guid StageClientTypeId { get; set; }

        [DataProperty]
        public long MediaStorageSize { get; set; }

    }
}
