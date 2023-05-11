using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXSwg
{
    [DataProperty(TableName = "tblwgtype")]
    public class ASXIWorldGuideType
    {
       
        [DataProperty] public int TypeID { get; set; }
        [DataProperty] public string Description { get; set; }
        [DataProperty] public int Layout { get; set; }
        [DataProperty] public int ImageWidth { get; set; }
        [DataProperty] public int ImageHeight { get; set; }


    }
}
