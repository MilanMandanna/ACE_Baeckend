using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using FluentAssertions;
using Moq;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Xunit;

namespace backend.IntegrationTest.Tests.Custom_Configuration
{
    [Collection("sequential")]
    public class MapsConfigurationTest:
        IClassFixture<ApplicationFactory<Startup>>
    {
        private ApplicationFactory<Startup> _factory;
        public MapsConfigurationTest(ApplicationFactory<Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

        #region Test methods

        [Theory(DisplayName = "Maps config - Get Layers")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetLayers(int configurationId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);

            IEnumerable<Layer> layers;
            List<Layer> layersList = new List<Layer>();
            Layer layer = new Layer();
            layer.Active = "true";
            layer.DisplayName = "Distance To Poi";
            layer.Enabled = "true";
            layer.Name = "distance to poi";
            layersList.Add(layer);
            layers = layersList;

            var mapsRepo = new Mock<MapsConfigurationRepository>();
            if (configurationId == 18)
                mapsRepo.Setup(m => m.GetLayers(configurationId)).Returns(Task.FromResult(layers));
            else if (configurationId == 0)
                mapsRepo.Setup(m => m.GetLayers(configurationId)).Returns(Task.FromResult<IEnumerable<Layer>>(null));

            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(m => m.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(m => m.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(m => m.MapsConfigurationRepository).Returns(mapsRepo.Object);
            mockRepos.Setup(m => m.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/MapsConfiguration/" + configurationId + "/layers");
            var result = JsonConvert.DeserializeObject<IEnumerable<Layer>>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.Should().HaveCount(inputResult);
        }

        [Theory(DisplayName = "Maps config - Get configuration for section")]
        [InlineData(18, "flyoveralerts", 1)]
        [InlineData(0, "flyoveralerts,", 0)]
        public async Task GetConfigurationFor(int configurationId, string section, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);

            Dictionary<string, object> keyValuePairs = new Dictionary<string, object>();
            string key = "ApproachAlertLeadTime";
            object value = 60000;
            keyValuePairs.Add(key, value);

            var mapsRepo = new Mock<MapsConfigurationRepository>();
            if (configurationId == 18)
                mapsRepo.Setup(m => m.GetConfigurationFor(configurationId, section)).Returns(Task.FromResult(keyValuePairs));
            else if (configurationId == 0)
                mapsRepo.Setup(m => m.GetConfigurationFor(configurationId, section)).Returns(Task.FromResult<Dictionary<string, object>>(null));

            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(m => m.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(m => m.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(m => m.MapsConfigurationRepository).Returns(mapsRepo.Object);
            mockRepos.Setup(m => m.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/MapsConfiguration/" + configurationId + "/simple/" + section);
            var result = JsonConvert.DeserializeObject<Dictionary<string, object>>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.Should().HaveCount(inputResult);
        }

        [Theory(DisplayName = "Maps config - update section data")]
        [InlineData(18, "flyoveralerts", "alert_duration", "60000", 1,"success", false)]
        [InlineData(0, "flyoveralerts,", "alert_duration", "60000", 0, "success", true)]
        public async Task UpdateSectionData(int configurationId, string section, string name, string value,  int inputResult, string message, bool resValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);

            var mapsRepo = new Mock<MapsConfigurationRepository>();
            mapsRepo.Setup(m => m.UpdateSectionData(configurationId, section, name, value)).Returns(Task.FromResult((inputResult, message)));

            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(m => m.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(m => m.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(m => m.MapsConfigurationRepository).Returns(mapsRepo.Object);
            mockRepos.Setup(m => m.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/MapsConfiguration/" + configurationId + "/simple/" + section + "/set/" + name + "/to/" + value, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            result.IsError.Should().Equals(resValue);
        }

        [Theory(DisplayName = "Maps config - Update selected layer")]
        [InlineData(18, 1, false)]
        [InlineData(0, 1, true)]
        public async Task UpdateLayer(int configId, int resultValue, bool resValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            Layer layer = new Layer();
            layer.Active = "true";
            layer.DisplayName = "Distance To Poi";
            layer.Enabled = "true";
            layer.Name = "distance to poi";

            var mapsRepo = new Mock<MapsConfigurationRepository>();
            mapsRepo.Setup(c => c.UpdateLayer(configId, layer)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.MapsConfigurationRepository).Returns(mapsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(layer);
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = await client.PostAsync("api/MapsConfiguration/" + configId + "/layers/update", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            result.IsError.Should().Equals(resValue);
        }
        #endregion

        #region Private methods

        /// <summary>
        /// 1. Mocking userdata
        /// </summary>
        /// <returns></returns>
        private Mock<SimpleRepository<User>> MockUserData()
        {
            Mock<SimpleRepository<User>> mock = new Mock<SimpleRepository<User>>();

            mock = new Mock<SimpleRepository<User>>();
            mock.Setup(c => c.FirstAsync("UserName", "katherine.holcomb")).Returns(Task.FromResult(new User()));
            mock.Setup(c => c.FirstAsync("UserName", "aehageme")).Returns(Task.FromResult(new User()));
            return mock;
        }

        /// <summary>
        /// 1. Mock Config Data
        /// </summary>
        /// <returns></returns>
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

        /// <summary>
        /// 1. Mock aircraft and product related data
        /// </summary>
        /// <returns></returns>
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
        #endregion
    }
}
