using System;
using System.Collections.Generic;
using System.Text;
using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.CustomContent
{
    public class PartNumber
    {
        [DataProperty]
        public int ConfigurationDefinitionID { get; set; }

        [DataProperty]
        public int PartNumberID { get; set; }

        [DataProperty]
        public string Value { get; set; }
        [DataProperty]
        public string TailNumber { get; set; }


    }
}
