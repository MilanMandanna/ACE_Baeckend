using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblFontMarker")]
    public class FontMarker
    {
        [DataProperty(PrimaryKey = true)]
        public int FontMarkerId { get; set; }

        [DataProperty] public int MarkerID { get; set; }

        [DataProperty] public string Filename { get; set; }
    }
}
