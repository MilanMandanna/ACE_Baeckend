using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblGlobals")]
    public class Global
    {
        [DataProperty(PrimaryKey = true)]
        public int GlobalID { get; set; }

        [DataProperty]
        public string Name { get; set; }

        [DataProperty]
        public string Description { get; set; }

    }
}