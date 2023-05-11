using backend.DataLayer.Helpers.Database;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tblASXiInset")]
    public class ASXInfoCity
    {

        [DataProperty(PrimaryKey = true)]
        public int ASXiInsetID { get; set; }
        [DataProperty] public string InsetName { get; set; }
        [DataProperty] public float Zoom { get; set; }
        [DataProperty] public string Path { get; set; }
        [DataProperty] public string MapPackageType { get; set; }
        [DataProperty] public int RowStart { get; set; }
        [DataProperty] public int RowEnd { get; set; }
        [DataProperty] public int ColStart { get; set; }
        [DataProperty] public int ColEnd { get; set; }
        [DataProperty] public float LatStart { get; set; }
        [DataProperty] public float LatEnd { get; set; }
        [DataProperty] public float LongStart { get; set; }
        [DataProperty] public float LongEnd { get; set; }
        [DataProperty] public bool IsHf { get; set; }
        [DataProperty] public int PartNumber { get; set; }
        [DataProperty] public string Cdata { get; set; }
    }
}
