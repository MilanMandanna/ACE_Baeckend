using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Helpers.Database
{
    /**
     * Utility class that provides methods to generate select, update and insert statements for a data class.
     * A static instance is provided. The first time a new class is encountered a plan is built for that class
     * based on the DataProperty attributes attached to the class. This information allows a plan for generating
     * insert, select and update sql statements quickly during runtime
     **/
    public class DatabaseMapper
    {
        public static DatabaseMapper Instance = new DatabaseMapper();

        private Dictionary<Type, DatabaseClassPlan> _plans = new Dictionary<Type, DatabaseClassPlan>();

        /**
         * Creates and caches a plan for the specified type
         **/
        public bool CreatePlan(Type type)
        {
            lock (_plans)
            {
                if (_plans.ContainsKey(type)) return true;

                DatabaseClassPlan plan = new DatabaseClassPlan();

                plan.FromType(type);
                lock (_plans)
                {
                    _plans.Add(type, plan);
                }

                return true;
            }
        }

        /**
         * Prepares the sql command object with the necessary sql statement and parameter bindings to
         * update the specified object into the database
         **/
        public bool PrepareUpdate(object from, SqlCommand command)
        {
            String sql = GenerateUpdate(from);
            if (sql == null) return false;
            command.CommandText = sql;

            return BindUpdate(from, command);
        }

        /**
         * Prepares the sql command object with the necessary sql statement and parameter bindings to
         * insert the specified object into the database.
         **/
        public bool PrepareInsert(object from, SqlCommand command)
        {
            String sql = GenerateInsert(from);
            if (sql == null) return false;
            command.CommandText = sql;

            return BindInsert(from, command);
        }

        /**
         * Helper function that will try to generate a plan for the specified type, returns true if the plan exists
         * otherwise false
         **/
        public bool EnsurePlan(Type type)
        {
            if (!_plans.ContainsKey(type) && !CreatePlan(type)) return false;
            return true;
        }

        /**
         * Generates a delete statement for the provided object, should include the necessary primary keys
         */
        public string GenerateDelete(object toDelete)
        {
            Type forType = toDelete.GetType();
            if (!_plans.ContainsKey(forType) && !CreatePlan(forType))
            {
                return null;
            }

            DatabaseClassPlan plan = _plans[forType];
            string primaryKeySql = string.Join(" AND ", plan.PrimaryKeys.Select(x => $"{x.FieldName} = @{x.FieldName}"));
            return $"DELETE FROM {plan.TableName} WHERE {primaryKeySql}";
        }

        /**
         * Binds the parameters on a sql command to delete the specified object
         **/
        public bool BindDelete(object toDelete, SqlCommand command)
        {
            Type type = toDelete.GetType();
            if (!_plans.ContainsKey(type))
            {
                return false;
            }

            DatabaseClassPlan plan = _plans[type];
            foreach (var field in plan.PrimaryKeys)
            {
                var value = field.Property.GetValue(toDelete);
                command.Parameters.AddWithValue(field.FieldName, value);
            }

            return true;
        }

        /**
         * Sets up the provided command to delete the provided object
         */
        public bool PrepareDelete(object toDelete, SqlCommand command)
        {
            string sql = GenerateDelete(toDelete);
            if (sql == null) return false;
            command.CommandText = sql;

            return BindDelete(toDelete, command);
        }

        /**
         * Generates the sql to query for data from a data table and its associated mapping table
         * If the data class has a data mapping attribute then the settings from that are used
         * for the stored procedure invocation.
         */
        public string GenerateMappedStoredProcedure(Type forType)
        {
            if (!_plans.ContainsKey(forType) && !CreatePlan(forType))
            {
                return null;
            }

            DatabaseClassPlan plan = _plans[forType];

            if (plan.dataMapping == null)
            {
                DatabaseFieldPlan primaryKey = plan.PrimaryKeys.FirstOrDefault();
                if (primaryKey == null) return null;

                return $"execute SP_GetMappedConfigurationRecords @configurationId, '{plan.TableName}', '{primaryKey.FieldName}'";
            }
            else
            {
                return $"execute SP_GetMappedConfigurationRecords @configurationId, '{plan.TableName}', '{plan.dataMapping.DataPrimaryKey}'";
            }
        }

        /**
         * Generates a select * statement for the given type
         **/
        public string GenerateSelectAll(Type forType)
        {
            if (!_plans.ContainsKey(forType) && !CreatePlan(forType))
            {
                return null;
            }

            DatabaseClassPlan plan = _plans[forType];
            return $"SELECT {plan.TableName}.* FROM {plan.TableName}";
        }

        /**
         * Helper function that returns a List of the given type as extracted from
         * a reader
         **/
        public async Task<IEnumerable<T>> FromReaderAsync<T>(SqlDataReader reader)
        {
            Type type = typeof(T);
            if (!_plans.ContainsKey(type) && !CreatePlan(type))
            {
                return null;
            }

            DatabaseClassPlan plan = _plans[type];
            List<T> results = new List<T>();
            while (await reader.ReadAsync())
            {
                var into = (T)plan.Generator.Invoke();
                FromReader(reader, into);
                results.Add(into);
            }

            return results;
        }

        /**
         * Helper function to read a record from a reader into the specified object
         * @todo: consider creating a reusable function that also takes the plan as a parameter
         *   to save on the lookup for the plan
         **/
        public bool FromReader(SqlDataReader reader, object into)
        {
            Type type = into.GetType();
            if (!_plans.ContainsKey(type) && !CreatePlan(type))
            {
                return false;
            }

            DatabaseClassPlan plan = _plans[type];
            foreach (var field in plan.Fields)
            {
                if (field.IsGuid)
                {
                    field.Property.SetValue(into, DbHelper.GuidFromDb(reader[field.FieldName]));
                }
                else if (field.IsDateTimeOffset)
                {
                    field.Property.SetValue(into, DbHelper.DateFromDb(reader[field.FieldName]));
                }
                else if (field.IsDateTime)
                {
                    field.Property.SetValue(into, DbHelper.DBValueToDateTime(reader[field.FieldName]));
                }
                else if (field.IsString)
                {
                    field.Property.SetValue(into, DbHelper.StringFromDb(reader[field.FieldName]));
                }
                else if (field.IsInt)
                {
                    field.Property.SetValue(into, DbHelper.IntFromDb(reader[field.FieldName]));
                }
                else
                {
                    field.Property.SetValue(into, reader[field.FieldName]);
                }
            }

            foreach (var field in plan.PrimaryKeys)
            {
                if (field.IsGuid)
                {
                    field.Property.SetValue(into, DbHelper.GuidFromDb(reader[field.FieldName]));
                }
                else if (field.IsDateTimeOffset)
                {
                    field.Property.SetValue(into, DbHelper.DateFromDb(reader[field.FieldName]));
                }
                else if (field.IsDateTime)
                {
                    field.Property.SetValue(into, DbHelper.DBValueToDateTime(reader[field.FieldName]));
                }
                else
                {
                    field.Property.SetValue(into, reader[field.FieldName]);
                }
            }

            return true;
        }

        /**
         * Helper function for generating string values to be used in sql string statements
         */
        public string FormatSqlString(string value)
        {
            return $"'{value.ToString().Replace("'", "''")}'";
        }

        /**
         * Helper function for formatting a value from an object according to a field plan
         */
        private string FormatSql(DatabaseFieldPlan fieldPlan, object from)
        {
            var value = fieldPlan.Property.GetValue(from);
            if (value == null) return "NULL";
            if (value.Equals(fieldPlan.NullValue)) return "NULL";
            if (fieldPlan.IsString)
            {
                return $"'{value.ToString().Replace("'", "''")}'";
            }
            //todo: probably need to handle datetime differently, but honestly, I don't think we have any in the sqlite database this function is used for
            return value.ToString();
        }

        /**
         * Helper function that generates a list of column names to be used in an insert statement according to the provided plan
         */
        public string GenerateInsertColumns(DatabaseClassPlan plan)
        {
            string columnsSql = string.Join(", ", plan.Fields.Select(x => x.FieldName).ToList());
            if (plan.PrimaryKeys.Count > 0)
            {
                if (columnsSql != "")
                {
                    columnsSql = string.Join(", ", columnsSql, string.Join(", ", plan.PrimaryKeys.Select(x => x.FieldName).ToList()));
                }

                // tables that only consist of primary keys
                else
                {
                    columnsSql = string.Join(", ", plan.PrimaryKeys.Select(x => x.FieldName));
                }
            }

            return columnsSql;
        }

        /**
         * Helper function to get the table associated with a dataclass
         */
        public string GetTableName(object from)
        {
            Type type = from.GetType();
            if (!_plans.ContainsKey(type) && !CreatePlan(type))
            {
                return null;
            }
            DatabaseClassPlan plan = _plans[type];
            return plan.TableName;
        }

        /**
         * Generates the insert columns for a dataclass as a sql string
         */
        public string GenerateInsertColumns(object from)
        {
            Type type = from.GetType();
            if (!_plans.ContainsKey(type) && !CreatePlan(type))
            {
                return null;
            }
            DatabaseClassPlan plan = _plans[type];
            return GenerateInsertColumns(plan);
        }

        /**
         * Generates the insert values for a dataclass as a sql string
         */
        public string GenerateInsertValues(DatabaseClassPlan plan, object from)
        {
            string valuesSql = string.Join(", ", plan.Fields.Select(x => FormatSql(x, from)).ToList());
            if (plan.PrimaryKeys.Count > 0)
            {
                if (valuesSql != "")
                {
                    valuesSql = string.Join(", ", valuesSql, string.Join(", ", plan.PrimaryKeys.Select(x => FormatSql(x, from)).ToList()));
                }

                // tables that only consist of primary keys
                else
                {
                    valuesSql = string.Join(", ", plan.PrimaryKeys.Select(x => FormatSql(x, from)));
                }
            }
            return valuesSql;
        }

        /**
         * Generates the sql string for the values portion of an insert statement for the given dataclass
         */
        public string GenerateInsertValues(object from)
        {
            Type type = from.GetType();
            if (!_plans.ContainsKey(type) && !CreatePlan(type))
            {
                return null;
            }
            DatabaseClassPlan plan = _plans[type];
            return GenerateInsertValues(plan, from);
        }

        /**
         * Generates an insert statement for the provided object
         **/
        public string GenerateInsert(object from)
        {
            Type type = from.GetType();
            if (!_plans.ContainsKey(type) && !CreatePlan(type))
            {
                return null;
            }

            DatabaseClassPlan plan = _plans[type];
            string columnsSql = string.Join(", ", plan.Fields.Select(x => x.FieldName).ToList());
            string valuesSql = string.Join(", ", plan.Fields.Select(x => $"@{x.FieldName}").ToList());
            if (plan.PrimaryKeys.Count > 0)
            {
                if (columnsSql != "")
                {
                    columnsSql = string.Join(", ", columnsSql, string.Join(", ", plan.PrimaryKeys.Select(x => x.FieldName).ToList()));
                    valuesSql = string.Join(", ", valuesSql, string.Join(", ", plan.PrimaryKeys.Select(x => $"@{x.FieldName}").ToList()));
                }

                // tables that only consist of primary keys
                else
                {
                    columnsSql = string.Join(", ", plan.PrimaryKeys.Select(x => x.FieldName));
                    valuesSql = string.Join(", ", plan.PrimaryKeys.Select(x => $"@{x.FieldName}"));
                }
            }

            string fullSql = $"INSERT INTO {plan.TableName} ({columnsSql}) VALUES ({valuesSql})";

            return fullSql;
        }

        /**
         * Binds the parameters for an insert statement on the provided object using the given command, it is assumed that the command objects commandtext
         * has been set with a corresponding insert statement generated for the object
         **/
        public bool BindInsert(object from, SqlCommand command)
        {
            Type type = from.GetType();
            if (!_plans.ContainsKey(type))
            {
                return false;
            }

            DatabaseClassPlan plan = _plans[type];
            foreach (var field in plan.Fields)
            {
                var value = field.Property.GetValue(from);

                // Guids need to be compared differently, == is always false
                if (field.IsGuid)
                {
                    if (Guid.Empty.Equals(value))
                        value = DBNull.Value;
                }
                else if (field.IsDateTime) 
                {
                    if (Convert.ToDateTime(value) == DateTime.MinValue)
                        value = DBNull.Value;
                }
                else
                {
                    if (value == field.NullValue)
                        value = DBNull.Value;
                }

                command.Parameters.AddWithValue(field.FieldName, value);
            }

            foreach (var field in plan.PrimaryKeys)
            {
                var value = field.Property.GetValue(from);
                if (value.Equals(field.NullValue) && field.IsGuid)
                    value = Guid.NewGuid();
                command.Parameters.AddWithValue(field.FieldName, value);
            }

            return true;
        }

        /**
         * Generates an updates statement for the provided object
         **/
        public string GenerateUpdate(object from)
        {
            Type type = from.GetType();

            if (!_plans.ContainsKey(type) && !CreatePlan(type))
            {
                return null;
            }

            DatabaseClassPlan plan = _plans[type];
            string primaryKeySql = string.Join(" AND ", plan.PrimaryKeys.Select(x => $"{x.FieldName} = @{x.FieldName}").ToList());
            string updateSql = string.Join(", ", plan.Fields.Select(x => $"{x.FieldName} = @{x.FieldName}").ToList());
            string fullSql = $"UPDATE {plan.TableName} SET {updateSql} WHERE {primaryKeySql}";
            return fullSql;
        }

        /**
         * Binds the parameters for an update statement on the provided object using the given command, it is assumed that the command objects commandtext
         * has been set with a corresponding update statement generated for the object
         **/
        public bool BindUpdate(object from, SqlCommand command)
        {
            Type type = from.GetType();
            if (!_plans.ContainsKey(type))
            {
                return false;
            }

            DatabaseClassPlan plan = _plans[type];
            foreach (var field in plan.Fields)
            {
                var value = field.Property.GetValue(from);
                if (value == field.NullValue)
                    value = System.DBNull.Value;
                command.Parameters.AddWithValue(field.FieldName, value);
            }

            foreach (var field in plan.PrimaryKeys)
            {
                var value = field.Property.GetValue(from);
                command.Parameters.AddWithValue(field.FieldName, value);
            }

            return true;
        }

        /**
         * Helper function to create an instance of a data bound class without the use of reflection or Activator.CreateInstance.
         * This method calls the pre-compiled lambda expression to invoke the empty constructor for the type
         **/
        public T Create<T>() where T : class
        {
            Type type = typeof(T);
            if (!_plans.ContainsKey(type) && !CreatePlan(type))
            {
                return null;
            }

            DatabaseClassPlan plan = _plans[type];
            var instance = plan.Generator.Invoke();
            return (T)instance;
        }
    }
}
