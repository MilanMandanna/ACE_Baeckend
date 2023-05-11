using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Linq;
using Microsoft.Extensions.DependencyInjection;
using backend.Helpers;
using System.Net.Http;
using backend.IntegrationTest.Helpers;
using backend.DataLayer.UnitOfWork.Contracts;


namespace backend.IntegrationTest
{
    /**
     * Web application factory that is customized to support integration testing for the ACE tool.
     * Will serve as the host for the application and re-configures some of the services to work
     * in the integration testing environment.
     * 
     * Provides a proxy for the unit of work service that allows control of where
     * database requests will go to, a mock database interface or the real database
     */
    public class ApplicationFactory<T> :
        WebApplicationFactory<T> where T : class
    {
        public UnitOfWorkProxy UnitOfWorkProxy { get; set; }

        public ApplicationFactory()
        {
            UnitOfWorkProxy = new UnitOfWorkProxy(); 
            EnableMockDatabase(false);
        }

        /**
         * Creates an http client configured as an admin for the application
         */
        public HttpClient CreateAdmin()
        {
            var client = this.CreateClient();
            TokenHelper.AuthorizeAs(client, TokenHelper.Admin);
            return client;
        }

        /**
         * Allows the access to the mock database to be switched on or off
         */
        public void EnableMockDatabase(bool enable)
        {
            UnitOfWorkProxy.EnableMockDatabase = enable;
        }

        /**
         * Returns the mock object to be used for the database
         */
        public Moq.Mock<IUnitOfWorkAdapter> GetMockDatabase()
        {
            return UnitOfWorkProxy.MockAdapter;
        }

        /**
         * Reconfigures the hosted application for the test environment
         */
        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            builder.ConfigureServices(services =>
            {
                // replace the default database interface with our proxy, the proxy lets us configure at runtime whether
                // tests will interface with a mock database or a real one
                var dbService = services.SingleOrDefault(d => d.ServiceType == typeof(IUnitOfWork));
                if (dbService != null)
                {
                    services.Remove(dbService);
                    services.AddSingleton<IUnitOfWork>(UnitOfWorkProxy);
                }

                UnitOfWorkProxy.DatabaseConnectionString = DatabaseSettings.LocalConnectionString;

                var serviceProvider = services.BuildServiceProvider();

                // get the configuration service and modify the connection string to point to our local test database
                var configuration = serviceProvider.GetService<Configuration>();
                if (configuration != null)
                {
                    configuration.ConnectionString = DatabaseSettings.LocalConnectionString;
                }

            });
        }
    }
}
