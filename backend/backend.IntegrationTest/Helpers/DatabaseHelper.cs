using backend.DataLayer.Models;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.DataLayer.UnitOfWork.SqlServer;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace backend.IntegrationTest.Helpers
{
    /**
     * storage for the connection strings used for local database access
     */
    public class DatabaseSettings
    {
        public static readonly string LocalConnectionString = "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=ACE;Integrated Security=True;";
        public static readonly string LocalConnectionStringMaster = "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=master;Integrated Security=True;";
    }

    /**
     * Fact that can be used on tests that rely on the database, if the database is not available
     * then the test will be skipped.
     */
    public class DatabaseFact : FactAttribute
    {
        public DatabaseFact()
        {
            DatabaseHelper.CheckForDatabase();
            Skip = DatabaseHelper.DatabaseCheck == 0 ? "test requires database access" : null;
        }
    }

    /**
     * Class that can be used as a test fixture and has some helper routines for getting test data
     * into the local database
     */
    public class DatabaseHelper : IDisposable
    {
        // have we checked for the existance of the local database yet and if so is it present
        public static int DatabaseCheck = -1;

        // has the once helper been invoked
        private bool _onceDone = false;

        // connection string to use
        private string _connectionString = null;

        public void Dispose()
        {
        }

        /**
         * Checks for the existance of the local database
         */
        public static void CheckForDatabase()
        {
            if (DatabaseCheck != -1) return;

            try
            {
                using var connection = new SqlConnection(DatabaseSettings.LocalConnectionStringMaster);
                connection.Open();

                string sql = "select count(*) from sys.databases where name = 'ACE'";
                using var cmd = new SqlCommand(sql, connection);
                var count = (int)cmd.ExecuteScalar();
                DatabaseHelper.DatabaseCheck = count == 0 ? 0 : 1;
                connection.Close();
            }
            catch
            {
                DatabaseHelper.DatabaseCheck = 0;
            }
        }

        /**
         * Allows for database initialization logic to be called only once. Handy when
         * used within a test class constructor (can be used to emulate the logic of the
         * nunit [SetUp] attribute
         */
        public void Once(string connectionString, Action<IUnitOfWorkAdapter> action)
        {
            _connectionString = connectionString;

            CheckForDatabase();

            if (_onceDone) return;
            if (DatabaseCheck == 0) return;

            _onceDone = true;

            using var adapter = new UnitOfWorkSqlServerAdapter(connectionString);
            action.Invoke(adapter);
        }

        /**
         * Helper function that deletes all data from the local database, resetting it
         */
        public void DeleteAllData()
        {
            using var connection = new SqlConnection(_connectionString);
            connection.Open();

            string sql = "exec sys.sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'";
            using (var cmd = new SqlCommand(sql, connection)) { cmd.ExecuteNonQuery(); }

            sql = "exec sys.sp_MSforeachtable 'DELETE FROM ?'";
            using (var cmd = new SqlCommand(sql, connection)) { cmd.ExecuteNonQuery(); }

            sql = "exec sys.sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'";
            using (var cmd = new SqlCommand(sql, connection)) { cmd.ExecuteNonQuery(); }

            connection.Close();
        }

        /**
         * Adds an admin user to the database
         */
        public void AddUserAdmin(IUnitOfWorkAdapter adapter)
        {
            adapter.Repositories.Simple<User>().Insert(new User()
            {
                Id = Guid.NewGuid(),
                UserName = "katherine.holcomb"
            });
        }

        /**
         * Adds a non-special user to the database
         */
        public void AddUserNobody(IUnitOfWorkAdapter adapter)
        {
            adapter.Repositories.Simple<User>().Insert(new User()
            {
                Id = Guid.NewGuid(),
                UserName = "aehageme"
            });
        }

    }
}
