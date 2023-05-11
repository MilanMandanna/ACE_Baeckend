using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    public class OutputTypes
    {
        [DataProperty(PrimaryKey = true)]
        public int OutputTypeID { get; set; }

        [DataProperty]
        public string OutputTypeName { get; set; }

        [DataProperty]
        public int PartNumberCollectionID { get; set; }
    }
}
