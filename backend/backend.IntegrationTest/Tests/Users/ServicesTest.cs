using backend.IntegrationTest.Helpers;
using backend.Mappers.DataTransferObjects.Manage;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Xunit;
using FluentAssertions;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Models;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;

namespace backend.IntegrationTest.Tests.Users
{
    public class ServicesTest :
        IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public ServicesTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;

            _factory.EnableMockDatabase(true);
            var userRepo = new Moq.Mock<SimpleRepository<User>>();
            userRepo.Setup(c => c.FirstAsync("UserName", "katherine.holcomb")).Returns(Task.FromResult(new User()));
            userRepo.Setup(c => c.FirstAsync("UserName", "aehageme")).Returns(Task.FromResult(new User()));

            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }

        [Theory(DisplayName = "Services are indicated based on user claims")]
        [InlineData(TokenHelper.ServiceAirshow, true, false)]
        [InlineData(TokenHelper.ServiceAll, true, true)]
        public async Task AvailableFlags(string token, bool airshow, bool stage)
        {
            using var client = _factory.CreateClient();
            TokenHelper.AuthorizeAs(client, token);

            var response = await client.GetAsync("api/user/services");
            var services = JsonConvert.DeserializeObject<AvailableServicesDTO>(await response.Content.ReadAsStringAsync());
            services.Should().NotBeNull();
            services.Airshow.Should().Be(airshow);
            services.Stage.Should().Be(stage);
        }
    }
}
