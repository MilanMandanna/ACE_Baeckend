using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXSwg
{
    [DataProperty(TableName = "tbwgimage")]
    public class ASXIWorlguideImage
    {
        [DataProperty] public string ImageID { get; set; }
        [DataProperty] public string FileName { get; set; }
    }
}
