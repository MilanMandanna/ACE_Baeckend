using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models
{
    public class BuildDefaultPartnumber
    {
        public int PartNumberID { get; set; }
        public string Name { get; set; }
        public int PartNumberCollectionID { get; set; }

        public string Description { get; set; }

        public string DefaultPartNumber { get; set; }
    }
}
