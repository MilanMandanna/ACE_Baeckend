using System;

namespace backend.DataLayer.Helpers
{
    public class DbHelper
    {
        public static Guid GuidFromDb(object value)
        {
            if (value is System.DBNull) return Guid.Empty;
            return (Guid)value;
        }

        public static DateTimeOffset DateFromDb(object value)
        {
            if (value is System.DBNull) return DateTimeOffset.UnixEpoch;
            return (DateTimeOffset)value;
        }

        public static DateTime DateTimeFromDb(object value)
        {
            if (value is System.DBNull) return DateTime.UnixEpoch;
            return (DateTime)value;
        }

        public static string StringFromDb(object value)
        {
            if (value is System.DBNull) return null;
            return (string)value;
        }
        public static int? IntFromDb(object value)
        {
            if (value is System.DBNull) return null;
            return Convert.ToInt32(value);
        }

        public static string FormatSqlString(string value)
        {
            return $"'{value.ToString().Replace("'", "''")}'";
        }

        public static string DbValueToSqlString(object value)
        {
            if (value is System.DBNull) return "NULL";
            if (value == null) return "NULL";
            return FormatSqlString(value.ToString()); 
        }

        public static bool BoolFromDb(object value)
        {
            if (value is System.DBNull) return false;
            return Convert.ToBoolean(value);
        }

        public static string DBValueToString(object value)
        {
            if (value is System.DBNull) return null;
            return Convert.ToString(value);
        }

        public static int DBValueToInt(object value)
        {
            if (value is System.DBNull) return 0;
            return Convert.ToInt32(value);
        }
        public static float FloatFromDB(object value)
        {
            if (value is System.DBNull) return 0;
            return Convert.ToSingle(value);
        }

        public static double DoubleFromDB (object value)
        {
            if (value is System.DBNull) return 0;
            return Convert.ToDouble(value);
        }
        public static long LongFromDB(object value)
        {
            if (value is System.DBNull) return 0;
            return Convert.ToInt64(value);
        }
        public static DateTime DBValueToDateTime(object value)
        {
            if (value is System.DBNull) return DateTime.UnixEpoch;
            return (DateTime)value;
        }

        public static string DBValueToStringWithEmpty(object value)
        {
            if (value is System.DBNull) return string.Empty;
            return Convert.ToString(value);
        }
    }
}
