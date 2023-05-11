using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblProductType")]
    public class ProductType
    {
        [DataProperty(PrimaryKey = true)]
        public int ProductTypeID { get; set; }

        [DataProperty]
        public string Name { get; set; }
    }
}
