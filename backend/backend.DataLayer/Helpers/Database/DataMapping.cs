using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Helpers.Database
{
    /**
     * Attribute that is used to help the database mapper map  certain mapping tables. Useful in cases where the primary keys between the data table and its mapping table may
     * be inconsistent for one reason or another
     */
    public class DataMapping : Attribute
    {
        public string DataPrimaryKey = "";
        public string MappingTable = null;
        public string MappingPrimaryKey = "";
    }
}
