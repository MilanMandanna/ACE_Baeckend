using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{

    public enum OutputTypeEnum
    {
    
        AS4XXX,
        CES,
        Thales2D,
        PAC3D,
        VenueNext,
        VenueHybrid
    }

    [DataProperty(TableName = "dbo.tblOutputTypes")]
    public class OutputType
    {
        [DataProperty(PrimaryKey = true)]
        public int OutputTypeID { get; set; }
        [DataProperty]
        public string OutputTypeName { get; set; }
        [DataProperty]
        public int PartNumberCollectionID { get; set; }
    }

}
