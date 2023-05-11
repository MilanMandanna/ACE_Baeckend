using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace backend.DataLayer.Helpers.Database
{
    /**
     * Class that stores the plan information related to a single field on an object / in the database
     **/ 
    public class DatabaseFieldPlan
    {
        public string FieldName;
        public object NullValue;

        public PropertyInfo Property;
        public DataProperty DataProperty;

        // todo: make these into a single enumeration
        public bool IsGuid;
        public bool IsDateTimeOffset;
        public bool IsString;
        public bool IsInt;
        public bool IsDateTime;

    }
}
