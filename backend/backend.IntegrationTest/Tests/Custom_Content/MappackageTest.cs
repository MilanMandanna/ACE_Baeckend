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
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using Moq;
using Ace.DataLayer.Models;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Models.Roles_Claims;
using System.Net.Http;
using System.Net.Http.Headers;
using backend.DataLayer.Repository.Extensions;
using backend.Mappers.DataTransferObjects.User;
using System.Linq;


namespace backend.IntegrationTest.Tests.Custom_Content
{


    [Collection("sequential")]
    public class MappackageTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public MappackageTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

        [Theory(DisplayName = "get selected HF cities")]
        [InlineData(1)]
        [InlineData(18)]
        public async Task GetSelectedHFCitiesTest(int configId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            List<City> city = new List<City>();
            City c = new City();

            var claimsrepo = new Mock<CustomContentRepository>();
            if (configId == 18)
            {
                c.ASXiInsetID = 1;
                c.InsetName = "banglore";
                city.Add(c);
                claimsrepo.Setup(c => c.GetSelectedHFCities(configId)).Returns(Task.FromResult(city));
            }
            else if (configId == 1)
            {
                claimsrepo.Setup(c => c.GetSelectedHFCities(configId)).Returns(Task.FromResult(city));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(claimsrepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getSelectedHFCities");
            var result = JsonConvert.DeserializeObject<List<City>>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configId == 18)
            {
                result.ToList().Count.Should().Be(1);
            }
            else
            {
                result.Should().BeNullOrEmpty();
            }


        }


        [Theory(DisplayName = "get selected HF cities")]
        [InlineData(1)]
        [InlineData(18)]
        public async Task SelectHFCityTest(int configId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var claimsrepo = new Mock<CustomContentRepository>();
            var cities = new int[2] { 1, 2 };
            if (configId == 18)
            {
                claimsrepo.Setup(c => c.SelectHFCity(configId, cities)).Returns(Task.FromResult(1));
            }
            else if (configId == 1)
            {
                claimsrepo.Setup(c => c.SelectHFCity(configId, cities)).Returns(Task.FromResult(0));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(claimsrepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);


            var httpContent = JsonConvert.SerializeObject(cities);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/CustomContent/" + configId + "/cities/HFselected/add", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configId == 18)
            {
                result.Message.Should().Be("City updated successfully..!");
            }
            else if (configId == 1)
            {
                result.Message.Should().Be("Failed to update city..!");
            }
        }


        [Theory(DisplayName = "delete HF cities")]
        [InlineData(1, 0)]
        [InlineData(18, 1)]
        public async Task DeleteHFCityTest(int configId, int inset)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var claimsrepo = new Mock<CustomContentRepository>();
            if (configId == 18)
            {
                claimsrepo.Setup(c => c.DeleteHFCity(configId, inset)).Returns(Task.FromResult(1));
            }
            else if (configId == 1)
            {
                claimsrepo.Setup(c => c.DeleteHFCity(configId, inset)).Returns(Task.FromResult(0));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(claimsrepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/CustomContent/" + configId + "/removeHFcity/" + inset, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configId == 18)
            {
                result.Message.Should().Be("City deleted successfully..!");
            }
            else if (configId == 1)
            {
                result.Message.Should().Be("Failed to delete city..!");
            }
        }


        [Theory(DisplayName = "Delete all HF cities")]
        [InlineData(1)]
        [InlineData(18)]
        public async Task DeleteAllHFCitiesTest(int configId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var claimsrepo = new Mock<CustomContentRepository>();
            var insets = new int[2] { 1, 2 };
            if (configId == 18)
            {
                claimsrepo.Setup(c => c.DeleteAllHFCities(configId, insets)).Returns(Task.FromResult(1));
            }
            else if (configId == 1)
            {
                claimsrepo.Setup(c => c.DeleteAllHFCities(configId, insets)).Returns(Task.FromResult(0));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(claimsrepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);


            var httpContent = JsonConvert.SerializeObject(insets);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/CustomContent/" + configId + "/removeAllHFcities", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configId == 18)
            {
                result.Message.Should().Be("All High focus cities deleted successfully..!");
            }
            else if (configId == 1)
            {
                result.Message.Should().Be("Failed to delete cities..!");
            }
        }


        [Theory(DisplayName = "get selected UHF cities")]
        [InlineData(1)]
        [InlineData(18)]
        public async Task GetSelecteUHFCitiesTest(int configId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            List<City> city = new List<City>();
            City c = new City();

            var claimsrepo = new Mock<CustomContentRepository>();
            if (configId == 18)
            {
                c.ASXiInsetID = 1;
                c.InsetName = "banglore";
                city.Add(c);
                claimsrepo.Setup(c => c.GetSelectedUHFCities(configId)).Returns(Task.FromResult(city));
            }
            else if (configId == 1)
            {
                claimsrepo.Setup(c => c.GetSelectedUHFCities(configId)).Returns(Task.FromResult(city));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(claimsrepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getSelectedUHFCities");
            var result = JsonConvert.DeserializeObject<List<City>>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configId == 18)
            {
                result.ToList().Count.Should().Be(1);
            }
            else
            {
                result.Should().BeNullOrEmpty();
            }
        }

        [Theory(DisplayName = "delete UHF cities")]
        [InlineData(1, 0)]
        [InlineData(18, 1)]
        public async Task DeleteUHFCity(int configId, int inset)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var claimsrepo = new Mock<CustomContentRepository>();
            if (configId == 18)
            {
                claimsrepo.Setup(c => c.DeleteUHFCity(configId, inset)).Returns(Task.FromResult(1));
            }
            else if (configId == 1)
            {
                claimsrepo.Setup(c => c.DeleteUHFCity(configId, inset)).Returns(Task.FromResult(0));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(claimsrepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/CustomContent/" + configId + "/removeUHFcity/" + inset, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configId == 18)
            {
                result.Message.Should().Be("City deleted successfully..!");
            }
            else if (configId == 1)
            {
                result.Message.Should().Be("Failed to delete city..!");
            }
        }


        [Theory(DisplayName = "Delete all UHF cities")]
        [InlineData(1)]
        [InlineData(18)]
        public async Task DeleteAllUHFCitiesTest(int configId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var claimsrepo = new Mock<CustomContentRepository>();
            var insets = new int[2] { 1, 2 };
            if (configId == 18)
            {
                claimsrepo.Setup(c => c.DeleteAllUHFCities(configId, insets)).Returns(Task.FromResult(1));
            }
            else if (configId == 1)
            {
                claimsrepo.Setup(c => c.DeleteAllUHFCities(configId, insets)).Returns(Task.FromResult(0));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(claimsrepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);


            var httpContent = JsonConvert.SerializeObject(insets);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/CustomContent/" + configId + "/removeAllUHFcities", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configId == 18)
            {
                result.Message.Should().Be("All Ultra high focus cities deleted successfully..!");
            }
            else if (configId == 1)
            {
                result.Message.Should().Be("Failed to delete cities..!");
            }


        }


        private Mock<SimpleRepository<User>> MockUserData()
        {
            Mock<SimpleRepository<User>> mock = new Mock<SimpleRepository<User>>();

            mock = new Mock<SimpleRepository<User>>();
            mock.Setup(c => c.FirstAsync("UserName", "katherine.holcomb")).Returns(Task.FromResult(new User()));
            mock.Setup(c => c.FirstAsync("UserName", "aehageme")).Returns(Task.FromResult(new User()));
            return mock;
        }

        private Mock<AircraftRepository> MockAircraftData(int configId)
        {
            IEnumerable<Aircraft> aircrafts;
            List<Aircraft> aircraftList = new List<Aircraft>();
            Aircraft aircraft = new Aircraft();
            aircraft.Id = Guid.Parse("E95FB669-FFF6-4DB3-8849-35307DFDC9CD");
            aircraft.ConnectivityTypes = "0";
            aircraft.ContentDiskSpace = 1782580;
            aircraftList.Add(aircraft);
            aircrafts = aircraftList;
            Mock<AircraftRepository> mock = new Mock<AircraftRepository>();
            mock.Setup(c => c.GetAircraftByConfigurationId(configId)).Returns(Task.FromResult(aircrafts));

            IEnumerable<Product> products;
            List<Product> productList = new List<Product>();
            Product product = new Product();
            product.Description = "AS4XXX Product";
            product.Name = "AS4XXX";
            product.ProductID = 1;
            productList.Add(product);
            products = productList;
            mock.Setup(c => c.GetAircraftsProduct(aircraft.Id)).Returns(Task.FromResult(products));
            return mock;
        }

        private Mock<ConfigurationDefinitionRepository> MockConfigData(int configId)
        {
            IEnumerable<ConfigurationDefinitionDetails> configurationDefinitions;
            List<ConfigurationDefinitionDetails> configDef = new List<ConfigurationDefinitionDetails>();
            ConfigurationDefinitionDetails definitionDetails = new ConfigurationDefinitionDetails();
            definitionDetails.ConfigurationDefinitionID = 18;
            definitionDetails.ConfigurationDefinitionTypeID = 18;
            definitionDetails.ConfigurationDefinitionType = "";
            configDef.Add(definitionDetails);
            configurationDefinitions = configDef;
            Mock<ConfigurationDefinitionRepository> mock = new Mock<ConfigurationDefinitionRepository>();
            mock.Setup(c => c.GetConfigurationInfoByConfigurationId(configId)).Returns(Task.FromResult(configurationDefinitions));

            return mock;
        }


    }
}
