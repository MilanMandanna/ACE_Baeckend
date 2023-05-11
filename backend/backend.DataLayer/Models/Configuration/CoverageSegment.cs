using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblCoverageSegment")]
    public class CoverageSegment
    {
        [DataProperty(PrimaryKey = true)]
        public int ID { get; set; }
        [DataProperty]
        public int GeoRefID { get; set; }
        [DataProperty]
        public int SegmentID { get; set; }
        [DataProperty]
        public decimal Lat1 { get; set; }
        [DataProperty]
        public decimal Lon1 { get; set; }
        [DataProperty]
        public decimal Lat2 { get; set; }
        [DataProperty]
        public decimal Lon2 { get; set; }
        [DataProperty]
        public int DataSourceID { get; set; }
        
        public System.Byte[] LastModifiedTime { get; set; }
        
        public DateTime SourceDate { get; set; }
        [DataProperty]
        public int CustomChangeBitMask { get; set; }
    }
}
