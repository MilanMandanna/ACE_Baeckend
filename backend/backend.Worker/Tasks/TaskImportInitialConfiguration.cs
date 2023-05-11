using backend.worker;
using backend.Worker.Data;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SQLite;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Threading.Tasks;

namespace backend.Worker.Tasks
{
    public class TaskImportInitialConfiguration
    {
        public async Task<int> ImportConfigXml(TaskEnvironment environment, int configurationId,string outputPath)
        {

            string importInitialFiles = outputPath + ".zip";
            string ipadConfigCustomXML = string.Empty;
            string ipadConfigXML = string.Empty;
            string asxiprofileXML = string.Empty;
            string asxiInfoDatabase = string.Empty;
            StringBuilder sbErrorLogs = new StringBuilder("Importing Data");
            try
            {
                if (!Directory.Exists(outputPath))
                    Directory.CreateDirectory(outputPath);

                if (File.Exists(importInitialFiles))
                {
                    ZipFile.ExtractToDirectory(importInitialFiles, outputPath);
                }
                string[] files_c = Directory.GetFiles(outputPath, "*.*", SearchOption.AllDirectories);
                foreach (string s in files_c)
                {
                    if (s.Contains("custom.xml"))
                    {
                        //It is Ipad config Custom.xml 
                        ipadConfigCustomXML = environment.PathWrapper(s);
                    }
                    if (s.Contains("asxiprofile.xml"))
                    {
                        asxiprofileXML = environment.PathWrapper(s);
                    }
                    if (s.Contains("ipadconfig.xml"))
                    {
                        ipadConfigXML = environment.PathWrapper(s);
                    }
                    if (s.Contains("asxinfo.sqlite3"))
                    {
                        asxiInfoDatabase = environment.PathWrapper(s);
                    }
                }
                if (File.Exists(ipadConfigCustomXML))
                {
                    ImportCustomDataAsync(environment, ipadConfigCustomXML, configurationId);
                    await environment.UpdateDetailedStatus("Custom.xml has been Imported");

                }
                if (File.Exists(asxiprofileXML))
                {
                    ImportCustomDataAsync(environment, asxiprofileXML, configurationId);
                    await environment.UpdateDetailedStatus("asxiprofile.xml has been Imported");
                }

                if (File.Exists(ipadConfigXML))
                {
                    ImportCustomDataAsync(environment, ipadConfigXML, configurationId);
                    await environment.UpdateDetailedStatus("IpadConfig.xml has been Imported");
                }
                if (File.Exists(asxiInfoDatabase))
                {
                    await ImportasxinfoDB(environment, asxiInfoDatabase, configurationId);
                    await environment.UpdateDetailedStatus("asxinfo.sqlite3 has been Imported");
                }
                return 0;
            }
            catch(Exception Ex)
            {
                sbErrorLogs.AppendFormat("{0};", "Exception has raised "+Ex.ToString());
                environment.CurrentTask.ErrorLog = sbErrorLogs.ToString();
                return -1;
            }
            
        }

        public void ImportCustomDataAsync(TaskEnvironment environment, string XmlPath, int ConfigID)
        {
            var dotNetVariable = Program.Configuration.GetValue<string>("DOTNET_ENVIRONMENT");
            string command;
            if (dotNetVariable == "AzureDev" || dotNetVariable == "AzureQA" || dotNetVariable == "Production")
            {
                if(XmlPath.Contains("custom.xml"))
                    command = $"java -jar {environment.GetLocalAssetPath("bin\\AceImport.jar")} -DAzureEnv {dotNetVariable} -DConfigurationID {ConfigID} -DCustomXMLPath {XmlPath}";
                else if (XmlPath.Contains("ipadconfig.xml"))
                    command = $"java -jar {environment.GetLocalAssetPath("bin\\AceImport.jar")} -DAzureEnv {dotNetVariable} -DConfigurationID {ConfigID} -DIpadConfigXMLPath {XmlPath}";
                else
                    command = $"java -jar {environment.GetLocalAssetPath("bin\\AceImport.jar")} -DAzureEnv {dotNetVariable} -DConfigurationID {ConfigID} -DAsxiProfileXMLPath {XmlPath}";
            }
            else
            {
                if (XmlPath.Contains("custom.xml"))
                    command = $"java -jar {environment.GetLocalAssetPath("bin\\AceImport.jar")} -DConfigurationID {ConfigID} -DCustomXMLPath {XmlPath}";
                else if (XmlPath.Contains("ipadconfig.xml"))
                    command = $"java -jar {environment.GetLocalAssetPath("bin\\AceImport.jar")} -DConfigurationID {ConfigID} -DIpadConfigXMLPath {XmlPath}";
                else
                    command = $"java -jar {environment.GetLocalAssetPath("bin\\AceImport.jar")} -DConfigurationID {ConfigID} -DAsxiProfileXMLPath {XmlPath}";
            }
            ExecuteCommand(environment, command);
        }
        static void ExecuteCommand(TaskEnvironment environment,string command)
        {
            var processInfo = new ProcessStartInfo("cmd.exe", "/c " + command)
            {
                CreateNoWindow = true,
                UseShellExecute = false,
                RedirectStandardError = true,
                RedirectStandardOutput = true
            };

            var process = Process.Start(processInfo);

            process.OutputDataReceived += (object sender, DataReceivedEventArgs e) =>
                environment.Logger.LogInfo("Xml download>>" + e.Data);
            process.BeginOutputReadLine();

            process.ErrorDataReceived += (object sender, DataReceivedEventArgs e) =>
                environment.Logger.LogInfo("Xml download error>>" + e.Data);
            process.BeginErrorReadLine();

            process.WaitForExit();

            environment.Logger.LogInfo("Xml download>>ExitCode: " + process.ExitCode.ToString());
            process.Close();
        }
        /// <summary>
        /// This Method used to Determine the given Table exist or not in the Database.
        /// </summary>
        /// <param name="tablename"></param>
        /// <param name="Destination Connection String"></param>
        /// <returns>Boolean</returns>
        private static bool SQLTableExists(string tablename, SqlConnection m_sqlcon)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '" + tablename + "'", m_sqlcon))
            {
                using SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// This Method Copy the Table Data from sqlite 3 to Sql Serever.
        /// </summary>
        /// <param name="tablename"></param>
        /// <param name="destinationTablename"></param>
        /// <param name="schema"></param>
        /// <param name="Source Connection String"></param>
        /// <param name="Destination Connection String"></param>
        /// <returns></returns>
        private static void Transfer(string tablename, string destinationTablename, List<KeyValuePair<string, string>> schema, SQLiteConnection m_sqlitecon, SqlConnection m_sqlcon)
        {
            using SQLiteCommand cmd = new SQLiteCommand("select * from " + tablename, m_sqlitecon);
            using SQLiteDataReader reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                StringBuilder sql = new StringBuilder();
                sql.Append("insert into " + destinationTablename + " (");
                bool first = true;
                foreach (KeyValuePair<string, string> column in schema)
                {
                    if (first)
                        first = false;
                    else
                        sql.Append(",");
                    sql.Append("[" + column.Key + "]");
                }
                sql.Append(") Values(");
                first = true;
                foreach (KeyValuePair<string, string> column in schema)
                {
                    if (first)
                        first = false;
                    else
                        sql.Append(",");
                    sql.Append("@");
                    sql.Append(column.Key);
                }
                sql.Append(");");
                try
                {
                    using (SqlCommand sqlcmd = new SqlCommand(sql.ToString(), m_sqlcon))
                    {
                        foreach (KeyValuePair<string, string> column in schema)
                        {
                            sqlcmd.Parameters.AddWithValue("@" + column.Key, reader[column.Key]);
                        }
                        int count = sqlcmd.ExecuteNonQuery();
                        if (count == 0)
                            throw new Exception("Unable to insert row!");
                    }
                }
                catch (Exception Exception)
                {
                    string message = Exception.Message;
                    int idx = message.IndexOf("Violation of PRIMARY KEY");
                    if (idx < 0)
                        throw;
                }
            }
        }

        /// <summary>
        /// This Method is to Format the sql Statements.
        /// </summary>
        /// <param name="input str"></param>
        /// <param name="oldValue"></param>
        /// <param name="newValue"></param>
        /// <returns></returns>
        private static string ReplaceCaseInsensitive(string str, string oldValue, string newValue)
        {
            int prevPos = 0;
            string retval = str;
            // find the first occurence of oldValue
            int pos = retval.IndexOf(oldValue, StringComparison.InvariantCultureIgnoreCase);

            while (pos > -1)
            {
                // remove oldValue from the string
                retval = retval.Remove(pos, oldValue.Length);

                // insert newValue in its place
                retval = retval.Insert(pos, newValue);

                // check if oldValue is found further down
                prevPos = pos + newValue.Length;
                pos = retval.IndexOf(oldValue, prevPos, StringComparison.InvariantCultureIgnoreCase);
            }

            return retval;
        }
        /// <summary>
        /// This Method is used to retreive the schema of the asxinfo.sqlite Database.
        /// </summary>
        /// <param name="tablename"></param>
        /// <param name="SConnection"></param>
        /// <returns></returns>
        private static List<KeyValuePair<string, string>> GetSQLiteSchema(string tablename, SQLiteConnection m_sqlitecon)
        {
            using (var cmd = new SQLiteCommand("PRAGMA table_info(" + tablename + ");", m_sqlitecon))
            {
                var table = new DataTable();

                SQLiteDataAdapter adp = null;
                try
                {
                    adp = new SQLiteDataAdapter(cmd);
                    adp.Fill(table);
                    List<KeyValuePair<string, string>> res = new List<KeyValuePair<string, string>>();
                    for (int i = 0; i < table.Rows.Count; i++)
                    {
                        string key = table.Rows[i]["name"].ToString();
                        string value = table.Rows[i]["type"].ToString();
                        KeyValuePair<string, string> kvp = new KeyValuePair<string, string>(key, value);

                        res.Add(kvp);
                    }
                    return res;
                }
                catch (Exception ex) { Console.WriteLine(ex.Message); }
            }
            return null;
        }

        /// <summary>
        /// This Method Imports the Data from asinfo.sqlite3 to SQL Server Database.
        /// </summary>
        /// <param name="environment"></param>
        /// <param name="Path"></param>
        /// <returns></returns>
        private async Task<int> ImportasxinfoDB(TaskEnvironment environment, string asxiinfoDB, int configurationId)
        {

            var uOfWork = environment.NewUnitOfWork();
            using var context = uOfWork.Create;
            StringBuilder sbErrorLogs = new StringBuilder("Import AsxiInforDB:");
            try
            {


                string connectionString = Program.Configuration.GetValue<string>("Configuration:ConnectionString", null);
                using SqlConnection m_sqlcon = new SqlConnection(connectionString);
                m_sqlcon.Open();

                SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder
                {
                    DataSource = asxiinfoDB,
                    TypeSystemVersion = "version 3"
                };

                using var m_sqlitecon = new SQLiteConnection(builder.ConnectionString);
                m_sqlitecon.Open();
                string sql = "SELECT * FROM sqlite_master WHERE type='table'";
                SQLiteCommand command = new SQLiteCommand(sql, m_sqlitecon);
                SQLiteDataReader reader = command.ExecuteReader();
                List<string> sourceTables = new List<string>();
                List<string> destinationTables = new List<string>();

                while (reader.Read())
                {
                    Console.WriteLine(reader.GetString(0));
                    string sourceTablename = reader["name"].ToString();
                    string destinationTablename = "AsxiInfo" + reader["name"].ToString();
                    sourceTables.Add(sourceTablename);
                    destinationTables.Add(destinationTablename);
                    string sqlstr = reader["sql"].ToString();
                    // Only create and import table if it does not exist
                    if (!SQLTableExists(destinationTablename, m_sqlcon))
                    {
                        Console.WriteLine("Creating table: " + destinationTablename);
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "tb", "AsxiInfotb");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "\n  ", "");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "\"", "");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "BOOLEAN", "bit");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "BLOB", "varbinary(max)"); // Note, maks 2 GB i varbinary(max) kolonner
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "VARCHAR", "nvarchar");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "nvarchar,", "nvarchar(max),");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "nvarchar\r", "nvarchar(max)\r"); // Case windiows
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "nvarchar\n", "nvarchar(max)\n"); // Case linux
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "INTEGER", "int");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "int(11)", "int");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "tinyint(1)", "bit");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "double", "float");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "TEXT", "nvarchar(max)");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "DEFAULT '0'", "DEFAULT 0");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "DEFAULT '1'", "DEFAULT 1");
                        sqlstr = ReplaceCaseInsensitive(sqlstr, "DEFAULT ", "DEFAULT ");
                        SqlCommand sqlcmd = new SqlCommand(sqlstr, m_sqlcon);
                        sqlcmd.ExecuteNonQuery();
                        sqlcmd.Dispose();
                        List<KeyValuePair<string, string>> columns = GetSQLiteSchema(sourceTablename, m_sqlitecon);
                        // Copy all rows to MS SQL Server
                        Transfer(sourceTablename, destinationTablename, columns, m_sqlitecon, m_sqlcon);
                    }
                    else
                        environment.CurrentTask.TaskDataJSON = "Table already exists: " + sourceTablename;
                }          
                var result = await context.Repositories.ConfigurationRepository.ImportAsxiInfo(environment.CurrentTask.ConfigurationID);
                if (result > 0)
                {
                    await context.SaveChanges();
                    await environment.UpdateDetailedStatus("AsxiInfo db has been Imported");
                	SQLiteConnection.ClearAllPools();
                	SqlConnection.ClearAllPools();					
                    return 0;
                }
            }
            catch (Exception ex)
            {
                sbErrorLogs.AppendFormat("{0};", "Exception in Stored Procedure");
                environment.CurrentTask.ErrorLog = sbErrorLogs.ToString();
                SQLiteConnection.ClearAllPools();
                SqlConnection.ClearAllPools();				
                environment.Logger.LogError("Exception while importing the Data: " + ex);            
            }

            return -1;
        }
    }
}
