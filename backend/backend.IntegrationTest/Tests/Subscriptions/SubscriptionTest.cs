using System;
using System.Collections.Generic;
using System.Text;
using Xunit;
using FluentAssertions;
using System.Threading.Tasks;
using System.Net.Http;
using backend.Mappers.DataTransferObjects.Subscription;
using Newtonsoft.Json;
using backend.Mappers.DataTransferObjects.Generic;
using System.Linq;
using backend.IntegrationTest.Helpers;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.Models.Subscription;
using System.Data.SqlClient;
using backend.DataLayer.Models;
using backend.DataLayer.UnitOfWork.Contracts;
using Moq;

namespace backend.IntegrationTest.Tests.Subscriptions
{
    public class SubscriptionTest :
        IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public SubscriptionTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;
        }

        // ideally we would want the setup of the mock data in the constructor or a seperate class fixture but
        // we can also do it in the function
        // just some test data to make the test execute multiple times to guage  the speed
        [Theory]
        [InlineData(1)]
        [InlineData(3)]
        [InlineData(4)]
        [InlineData(5)]
        
        public async Task AllSubscriptions(int something)
        {
            _factory.EnableMockDatabase(true);

            var mockUsers = new Moq.Mock<SimpleRepository<User>>();
            mockUsers.Setup(c => c.FirstAsync("UserName", "katherine.holcomb")).Returns(Task.FromResult(new User()));

            var mockSubscriptions = new Moq.Mock<SimpleRepository<Subscription>>();
            var allSubscriptions = new List<Subscription>();
            allSubscriptions.Add(new Subscription());
            allSubscriptions.Add(new Subscription());
            mockSubscriptions.Setup(c => c.FindAllAsync()).Returns(Task.FromResult(allSubscriptions));
            mockSubscriptions.Setup(c => c.InsertAsync(It.IsAny<Subscription>())).Returns(Task.FromResult(1));

            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(mockUsers.Object);
            mockRepos.Setup(c => c.Simple<Subscription>()).Returns(mockSubscriptions.Object);

            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            var client = _factory.CreateAdmin();

            var all = await client.GetAsync<SubscriptionDTO[]>("api/subscription/all");
            all.Should().HaveCount(2);

            allSubscriptions.Clear();
            all = await client.GetAsync<SubscriptionDTO[]>("api/subscription/all");
            all.Should().HaveCount(0);
        }
    }
}
