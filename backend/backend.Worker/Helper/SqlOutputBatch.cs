using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Linq;
using System.Threading.Tasks;

namespace backend.Worker.Helper
{
    public enum SqlOutputFormat
    {
        Sqlite3,
        Access,
        MySql,
        TSQL
    }

    public enum SqlOutputBatchMode
    {
        None,
        Insert,
        InsertImproved
    }

    /**
     * Support class for generate .sql files, helps with management of multiple sql statements into transactions and multi-insert statements
     * By default this class is setup to support the SQL syntax used by sqlite, but can be extended to handle other formats
     */
    public class SqlOutputBatch
    {
        public int BatchMax { get; set; }

        private StreamWriter _output;
        private SqlOutputBatchMode Mode = SqlOutputBatchMode.None;
        public SqlOutputFormat Format = SqlOutputFormat.Sqlite3;
        private int _batchCount = 0;
        
        private string _insertColumns;
        private string _batchInsertTable;
        private string[] _batchInsertColumns;

        public SqlOutputBatch(StreamWriter output)
        {
            _output = output;
            BatchMax = 499;
        }

        public async Task BatchInsertReader(SqlDataReader reader, string tableName)
        {
            var columns = new string[reader.FieldCount];
            for (int i = 0; i < reader.FieldCount; ++i)
            {
                columns[i] = reader.GetName(i);
            }

            BeginBatchInsert(tableName, columns);
            while (await reader.ReadAsync())
            {
                WriteBatchedInsert(reader);
            }
            EndBatchInsert();
        }

        /**
         * Starts a new batch insert section. Groups BatchMax number of inserts into a single insert statement using
         * the columns specified. All inserts executed between BeginBatchInsert and EndBatchInsert are also
         * wrapped in a single transaction
         */
        public void BeginBatchInsert(string insertColumns)
        {
            Mode = SqlOutputBatchMode.Insert;
            _insertColumns = insertColumns;
            _batchCount = 0;
            //_output.WriteLine("BEGIN TRANSACTION;");
        }

        public void BeginBatchInsert(string tableName, string[] columns)
        {
            Mode = SqlOutputBatchMode.InsertImproved;
            _batchInsertColumns = columns;
            _batchInsertTable = tableName;
            _batchCount = 0;

            switch (Format)
            {
                case SqlOutputFormat.Sqlite3:
                case SqlOutputFormat.Access:
                case SqlOutputFormat.TSQL:
                    //_output.WriteLine("BEGIN TRANSACTION;");
                    break;
                case SqlOutputFormat.MySql:
                    _output.WriteLine($"/*!40000 ALTER TABLE `{tableName}` DISABLE KEYS */;");
                    break;
                default:
                    break;
            }
        }

        public string FormatSqlString(string value)
        {
            return $"'{value.ToString().Replace("'", "''")}'";
        }

        private string FormatMySqlColumn(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);

            var value = reader.GetValue(ordinal);
            if (value is System.DBNull)
                return "NULL";
            
            var columnType = reader.GetDataTypeName(ordinal);
            switch (columnType)
            {
                case "varchar":
                case "nvarchar":
                    return $"'{reader.GetString(ordinal).Replace("'", "''")}'";
                default:
                    return reader.GetValue(ordinal).ToString();
            }
        }

        private string  FormatAccessColumn(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);

            var value = reader.GetValue(ordinal);
            if (value is System.DBNull)
                return "NULL";

            var columnType = reader.GetDataTypeName(ordinal);
            switch (columnType)
            {
                case "char":
                case "varchar":
                case "nvarchar":
                    var temp = $"'{reader.GetString(ordinal).Replace("'", "''")}'"; // replace single-quotes in the string with two single-quotes
                    temp = temp.Replace("`", "' & CHR(96) & '"); // replace grave acceent with CHR(96), ucanaccess has some sql problem handling grave accents in a string (it replaces them with brackets)
                    return temp;
                case "bit":
                    if (Boolean.Parse(value.ToString()) == false)
                        return "0";                    
					else
                        return "1";
                case "smallint":
                case "int":
                case "decimal":
                    return reader.GetValue(ordinal).ToString();
                default:
                    Console.WriteLine("unhandled field type in FormatAccessColumn: " + columnType);
                    return reader.GetValue(ordinal).ToString();
            }
        }

        public void WriteBatchedInsert(SqlDataReader reader)
        {
            if (_batchCount == 0)
            {
                switch (Format)
                {
                    case SqlOutputFormat.Sqlite3:
                        var columns = String.Join(", ", _batchInsertColumns.Select(x => $"\"{x}\""));
                        _output.WriteLine($"INSERT INTO `{_batchInsertTable}` ({columns}) VALUES");
                        break;

                    case SqlOutputFormat.Access:
                    case SqlOutputFormat.TSQL:
                        columns = String.Join(", ", _batchInsertColumns.Select(x => $"[{x}]"));
                        _output.WriteLine($"INSERT INTO [{_batchInsertTable}] ({columns}) VALUES");
                        break;

                    case SqlOutputFormat.MySql:
                        columns = String.Join(", ", _batchInsertColumns.Select(x => $"`{x}`"));
                        _output.WriteLine($"INSERT INTO `{_batchInsertTable}` ({columns}) VALUES");
                        break;
                    default:
                        throw new NotImplementedException("batch default format not supported");
                }
            }

            if (_batchCount > 0) _output.WriteLine(",");

            switch (Format)
            {
                case SqlOutputFormat.Access:
                    var values = String.Join(", ", _batchInsertColumns.Select(x => FormatAccessColumn(reader, x)));
                    _output.Write($"({values})");
                    break;

                case SqlOutputFormat.Sqlite3:
                case SqlOutputFormat.TSQL:
                case SqlOutputFormat.MySql:
                    values = String.Join(", ", _batchInsertColumns.Select(x => FormatMySqlColumn(reader, x)));
                    _output.Write($"({values})");
                    break;

                default:
                    throw new NotImplementedException("batch default format not supported");
            }

            _batchCount++;

            if (_batchCount > BatchMax)
            {
                _output.WriteLine(";");
                _output.WriteLine("");
                _batchCount = 0;
            }
        }

        /**
         * Writes out a new values for a batched insert group
         */
        public void WriteBatchedInsert(string values)
        {
            if (Mode != SqlOutputBatchMode.Insert) throw new InvalidOperationException("batch in the wrong mode");

            // handle the different formatting and output modes now!
            if (_batchCount == 0)
            {
                _output.WriteLine(_insertColumns);
                _output.WriteLine("VALUES");
            }

            if (_batchCount > 0) _output.WriteLine(",");

            _output.Write($"({values})");
            _batchCount++;

            if (_batchCount > BatchMax)
            {
                _output.WriteLine(";");
                _output.WriteLine("");
                _batchCount = 0;
            }
        }

        /**
         * Stops batch mode for insert statements and commits the current transaction
         */
        public void EndBatchInsert()
        {
            if (_batchCount > 0)
            {
                _output.WriteLine(";");
                _batchCount = 0;
            }

            switch (Format)
            {
                case SqlOutputFormat.Sqlite3:
                case SqlOutputFormat.Access:
                case SqlOutputFormat.TSQL:
                    //_output.WriteLine("COMMIT;");
                    break;
                case SqlOutputFormat.MySql:
                    //_output.WriteLine("COMMIT;");
                    break;
                default:
                    _output.WriteLine($"/*40000 ALTER TABLE `{_batchInsertTable}` ENABLE KEYS */;");
                    break;
            }

            _insertColumns = null;
            _batchInsertColumns = null;
            Mode = SqlOutputBatchMode.None;
        }

        public void WriteAccessLog(string message)
        {
            _output.WriteLine("--log:" + message + ";");
        }
    }
}
