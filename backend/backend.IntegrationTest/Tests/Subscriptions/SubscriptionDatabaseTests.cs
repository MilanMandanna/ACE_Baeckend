using backend.IntegrationTest.Helpers;
using System;
using System.Collections.Generic;
using System.Text;
using FluentAssertions;
using backend.DataLayer.Models.Subscription;
using Xunit;
using backend.Mappers.DataTransferObjects.Subscription;
using System.Threading.Tasks;

namespace backend.IntegrationTest.Tests.Subscriptions
{
    [Collection("sequential")]
    public class SubscriptionDatabaseTests :
        IClassFixture<DatabaseHelper>,
        IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private ApplicationFactory<backend.Startup> _factory;

        public SubscriptionDatabaseTests(
            ApplicationFactory<backend.Startup> factory,
            DatabaseHelper helper)
        {
            _factory = factory;
            _factory.EnableMockDatabase(false);

            helper.Once(DatabaseSettings.LocalConnectionString, adapter =>
            {
                helper.DeleteAllData();
                helper.AddUserAdmin(adapter);

                adapter.Repositories.Simple<Subscription>().Insert(new Subscription()
                {
                    Id = Guid.NewGuid(),
                    Name = "Mine!",
                    IsObsolete = false,
                    DateCreated = DateTime.Now
                });

                adapter.Repositories.Simple<Subscription>().Insert(new Subscription()
                {
                    Id = Guid.NewGuid(),
                    Name = "Mine2",
                    IsObsolete = true,
                    DateCreated = DateTime.Now
                });

                adapter.Save();
            });
        }

        [DatabaseFact]
        public async Task ActiveSubscriptions()
        {
            var client = _factory.CreateAdmin();

            var active = await client.GetAsync<SubscriptionDTO[]>("api/subscription/active");
            active.Should().HaveCount(1);
            active[0].Name.Should().Be("Mine!");
        }

        [DatabaseFact]
        public async Task AllSubscriptions()
        {
            var client = _factory.CreateAdmin();

            var all = await client.GetAsync<SubscriptionDTO[]>("api/subscription/all");
            all.Should().HaveCount(2);
        }

    }
}
