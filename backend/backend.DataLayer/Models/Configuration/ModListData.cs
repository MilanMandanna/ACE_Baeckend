using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblModList")]
    public class ModListData
    {
        [DataProperty] public int ModlistID { get; set; }
        [DataProperty] public string FileJSON { get; set; }
        [DataProperty] public double Row { get; set; }
        [DataProperty] public double Col { get; set; }
        [DataProperty] public int Resolution { get; set; }
        [DataProperty] public bool isDirty { get; set; }
    }
}
