using backend.DataLayer.UnitOfWork.Contracts;
using backend.DataLayer.UnitOfWork.SqlServer;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.IntegrationTest.Helpers
{
    /**
     * Class that will be used to allow the test environment
     * to switch between using a mock database or the real one
     * at runtime.
     */
    public class UnitOfWorkProxy : IUnitOfWork
    {
        public UnitOfWorkProxy()
        {
            MockAdapter = new Moq.Mock<IUnitOfWorkAdapter>();
        }

        public string DatabaseConnectionString { get; set; }
        public bool EnableMockDatabase { get; set; }
        public Moq.Mock<IUnitOfWorkAdapter> MockAdapter { get; set; }

        /**
         * If mocking is enabled then return the mock adapter,
         * otherwise connect to the database configured
         */
        IUnitOfWorkAdapter IUnitOfWork.Create
        {
            get
            {
                if (EnableMockDatabase)
                {
                    return MockAdapter.Object;
                }
                else
                {
                    var connectionString = DatabaseConnectionString;
                    return new UnitOfWorkSqlServerAdapter(connectionString);
                }
            }
        }
    }
}
