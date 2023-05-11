using backend.IntegrationTest.Helpers;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Subscription;
using FluentAssertions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace backend.IntegrationTest.Tests.Subscriptions
{
    [Collection("sequential")]
    public class SubscriptionAdd :
        IClassFixture<DatabaseHelper>,
        IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private ApplicationFactory<backend.Startup> _factory;

        public SubscriptionAdd(
            ApplicationFactory<backend.Startup> factory,
            DatabaseHelper helper)
        {
            _factory = factory;
            _factory.EnableMockDatabase(false);

            helper.Once(DatabaseSettings.LocalConnectionString, adapter =>
            {
                helper.DeleteAllData();
                helper.AddUserAdmin(adapter);
                adapter.Save();
            });
        }

        [DatabaseFact]
        public async Task AddSubscription()
        {
            var client = _factory.CreateAdmin();

            var active = await client.GetAsync<SubscriptionDTO[]>("api/subscription/active");
            active.Should().BeEmpty();

            var subscription = new SubscriptionDetailsDTO()
            {
                Id = Guid.Empty,
                Name = "added subscription",
                Description = "description",
                DateCreated = DateTime.Now,
                Features = new List<SubscriptionFeatureAssignmentDTO>(),
                IsObsolete = false
            };

            var result = await client.PostAsyncJson<DataCreationResultDTO>("api/subscription/details", subscription);

            result.Id.Should().NotBeEmpty();
            result.IsError.Should().BeFalse();

            active = await client.GetAsync<SubscriptionDTO[]>("api/subscription/active");
            active.Should().HaveCount(1);
            active[0].Id.Should().Be(result.Id);
            active[0].Name.Should().Be("added subscription");
            active[0].Description.Should().Be("description");
        }
    }
}
