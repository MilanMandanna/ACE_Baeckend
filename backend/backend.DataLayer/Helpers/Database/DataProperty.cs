using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Helpers.Database { 
    /**
     * Attribute that can be attached to a class to allow it to interface with the DatabaseMapper class. Allowing for the 
     * generation of sql statements for a given class
     **/ 
    public class DataProperty : Attribute
    {
        public string TableName = null;
        public Boolean PrimaryKey = false;
        public object NullValue = null;
        public string FieldName = null;
    }
}
