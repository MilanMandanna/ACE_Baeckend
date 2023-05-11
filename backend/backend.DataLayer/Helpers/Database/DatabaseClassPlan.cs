using backend.DataLayer.Helpers;
using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;

namespace backend.DataLayer.Helpers.Database
{
    public delegate object ObjectActivator();

    /**
     * Class that encapsulates the necessary data for quickly
     * generating sql statements for a given object type. This class works by scanning a type
     * for DataProperty attributes and building up the necessary cache and data for the type.
     **/
    public class DatabaseClassPlan
    {
        private Type _mappedType;

        public DataMapping dataMapping { get; set; }

        public string TableName { get; set; }
        public List<DatabaseFieldPlan> PrimaryKeys { get; set; }

        public List<DatabaseFieldPlan> Fields { get; set; }

        public ObjectActivator Generator;

        /**
         * Builds up the mapping information for the specified type in this plan
         **/
        public void FromType(Type type)
        {
            DataProperty dataProperty = (DataProperty)type.GetCustomAttributes(typeof(DataProperty), false).DefaultIfEmpty(null).FirstOrDefault();
            if (dataProperty != null)
            {
                TableName = dataProperty.TableName;
            }

            dataMapping = (DataMapping)type.GetCustomAttributes(typeof(DataMapping), false).DefaultIfEmpty(null).FirstOrDefault();

            List<PropertyInfo> properties = type.GetProperties().Where(x => x.GetCustomAttributes(typeof(DataProperty), false).Length > 0).ToList();
            List<DatabaseFieldPlan> primaryKeys = new List<DatabaseFieldPlan>();
            List<DatabaseFieldPlan> fields = new List<DatabaseFieldPlan>();

            foreach (var property in properties)
            {
                DataProperty definition = (DataProperty)property.GetCustomAttribute<DataProperty>();
                if (definition == null) return;

                DatabaseFieldPlan fieldPlan = new DatabaseFieldPlan();
                fieldPlan.DataProperty = definition;
                fieldPlan.Property = property;

                // use the property name as the database column name, and optionally override
                // based on the attribute
                fieldPlan.FieldName = property.Name;
                if (definition.FieldName != null)
                    fieldPlan.FieldName = definition.FieldName;

                // probably a better way to store this, but this works for now.
                fieldPlan.IsGuid = (fieldPlan.Property.PropertyType == typeof(System.Guid));
                fieldPlan.IsDateTimeOffset = (fieldPlan.Property.PropertyType == typeof(System.DateTimeOffset));
                fieldPlan.IsDateTimeOffset |= (fieldPlan.Property.PropertyType == typeof(System.DateTimeOffset?));
                fieldPlan.IsDateTime = (fieldPlan.Property.PropertyType == typeof(System.DateTime));
                fieldPlan.IsString = (fieldPlan.Property.PropertyType == typeof(string));
                fieldPlan.IsInt = (fieldPlan.Property.PropertyType == typeof(int?));
                fieldPlan.IsInt |= (fieldPlan.Property.PropertyType == typeof(int));

                // determine the proper null values
                if (fieldPlan.IsGuid)
                {
                    fieldPlan.NullValue = System.Guid.Empty;
                    if (definition.NullValue != null)
                        fieldPlan.NullValue = System.Guid.Parse(definition.NullValue.ToString());
                }
                else if (fieldPlan.IsDateTime)
                {
                    fieldPlan.NullValue = DateTime.UnixEpoch;
                    if (definition.NullValue != null)
                        fieldPlan.NullValue = DateTime.Parse(definition.NullValue.ToString());
                }
                else if (fieldPlan.IsDateTimeOffset)
                {
                    fieldPlan.NullValue = System.DateTimeOffset.UnixEpoch;
                    if (definition.NullValue != null)
                        fieldPlan.NullValue = DateTimeOffset.Parse(definition.NullValue.ToString());
                }
                else if (fieldPlan.IsInt)
                {
                    fieldPlan.NullValue = null;
                    if (definition.NullValue != null)
                        fieldPlan.NullValue = Convert.ToInt32(definition.NullValue.ToString());
                }
                else
                {
                    fieldPlan.NullValue = definition.NullValue;
                }

                if (definition.PrimaryKey)
                    primaryKeys.Add(fieldPlan);
                else
                    fields.Add(fieldPlan);
            }

            ConstructorInfo ctor = type.GetConstructor(new Type[] { });
            NewExpression newExp = Expression.New(ctor);
            LambdaExpression lambda = Expression.Lambda(typeof(ObjectActivator), newExp);
            ObjectActivator compiled = (ObjectActivator)lambda.Compile();

            _mappedType = type;
            PrimaryKeys = primaryKeys;
            Fields = fields;
            Generator = compiled;
        }

    }
}
