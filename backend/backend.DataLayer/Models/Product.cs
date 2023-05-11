using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models
{
    [DataProperty(TableName = "dbo.tblProducts")]
    public class Product
    {
        [DataProperty(PrimaryKey = true)]
        public int ProductID { get; set; }
        
        [DataProperty]
        public string Name { get; set; }

        [DataProperty] 
        public string Description { get; set; }

        [DataProperty] 
        public string LastModifiedBy { get; set; }

        [DataProperty]
        public int ConfigurationDefinitionID { get; set; }

       

    }
    public class TopLevelPartNumber
    {
        public string TopLevelPartnumber { get; set; }
    }

}
