using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXSwg
{
    [DataProperty(TableName = "tbwgcontent")]
    public class ASXIWorldGuideContent
    {
        [DataProperty] public int WGContentID { get; set; }
        [DataProperty] public int GeoRefID { get; set; }
        [DataProperty] public int TypeID { get; set; }
        [DataProperty] public int ImageID { get; set; }
        [DataProperty] public int TextID { get; set; }
        

    }

}