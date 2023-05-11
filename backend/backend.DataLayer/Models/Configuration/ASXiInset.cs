using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblASXiInset")]
    public class ASXiInset
    {
        [DataProperty]
        public int ASXiInsetID { get; set; }

        [DataProperty]
        public string InsetName { get; set; }

        [DataProperty]
        public double Zoom { get; set; }

        [DataProperty]
        public string Path { get; set; }

        [DataProperty]
        public string MapPackageType { get; set; }

        [DataProperty]
        public int RowStart { get; set; }

        [DataProperty]
        public int RowEnd { get; set; }
        [DataProperty]
        public int ColStart { get; set; }
        [DataProperty]
        public int ColEnd { get; set; }
        [DataProperty]
        public double LatStart { get; set; }
        [DataProperty]
        public double LatEnd { get; set; }
        [DataProperty]
        public double LongStart { get; set; }
        [DataProperty]
        public double LongEnd { get; set; }
        [DataProperty]
        public bool IsHf { get; set; }
        [DataProperty]
        public int PartNumber { get; set; }
        [DataProperty]
        public string Cdata { get; set; }
        [DataProperty]
        public bool IsUHf { get; set; }
    }
}
