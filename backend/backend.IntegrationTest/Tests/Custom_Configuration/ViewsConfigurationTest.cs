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
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Xunit;

namespace backend.IntegrationTest.Tests.Custom_Configuration
{
    [Collection("sequential")]
    public class ViewsConfigurationTest :
        IClassFixture<ApplicationFactory<Startup>>
    {
        private ApplicationFactory<Startup> _factory;
        public ViewsConfigurationTest(ApplicationFactory<Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
            
        }

        #region Test methods

        #region Views

        [Theory(DisplayName = "Views config - GetAllViewDetails")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetAllViewDetails(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);

            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.GetAllViewDetails(configId, "all")).Returns
                (Task.FromResult(new ConfigurationViewDTO() { ConfigurationData = new List<Views>() { new Views() { Preset = true, Name = "Compass" } } }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetAllViewDetails(configId, "all")).Returns(Task.FromResult<ConfigurationViewDTO>(null));

            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/views");
            var result = JsonConvert.DeserializeObject<ConfigurationViewDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.ConfigurationData.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Update Selected View")]
        [InlineData(18, "compass", "true", 1)]
        [InlineData(19, "Makkah", "true", 2)]
        [InlineData(0, "Autoplay", "false", 0)]
        public async Task UpdateSelectedView(int configId, string viewName, string value, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.UpdateSelectedView(configId, viewName, value)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/views/preset/" + viewName + "/to/" + value, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be(viewName + " Preset has been updated to " + value);
            else if (configId == 19)
                result.Message.Should().Be("Max preset reached");
            else if (configId == 0)
                result.Message.Should().Be("Preset updation failed");
        }

        [Theory(DisplayName = "Views config - Disable selected view")]
        [InlineData(18, "compass")]
        [InlineData(0, "Autoplay")]
        public async Task DisableSelectedView(int configId, string viewName)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.DisableSelectedView(configId, viewName)).Returns(Task.FromResult(1));
            else if (configId == 0)
                viewsRepo.Setup(c => c.DisableSelectedView(configId, viewName)).Returns(Task.FromResult(0));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/views/delete/" + viewName, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be(viewName + " enable status has been updated");
            else if (configId == 0)
                result.Message.Should().Be(viewName + " enable status updation failed");
        }

        [Theory(DisplayName = "Views config - Add Selected View")]
        [InlineData(18, new string[] { "Autoplay" }, 1)]
        [InlineData(0, new string[] { "Autoplay" }, 1)]
        public async Task AddSelectedView(int configId, string[] viewName, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.AddSelectedView(configId, viewName.ToList())).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(viewName.ToList());
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/views/add", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            result.Message.Should().Be("failure");
        }

        [Theory(DisplayName = "Views config - Move Selected View")]
        [InlineData(18, "compass", 1, 3, 1)]
        [InlineData(19, "Makkah", 2, 1, 2)]
        [InlineData(0, "Autoplay", 0, 0, 0)]
        public async Task MoveSelectedView(int configId, string viewName, int oldValue, int newValue, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>(); 
            viewsRepo.Setup(c => c.MoveSelectedView(configId, viewName, oldValue, newValue)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/views/move/" + viewName + "/from/" + oldValue + "/to/" + newValue, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be("Node successfully repositioned");
            else if (configId == 19)
                result.Message.Should().Be("Node is not enabled");
            else if (configId == 0)
                result.Message.Should().Be("Node repositioning failed");
        }
        #endregion

        #region Get available locations

        [Theory(DisplayName = "Views config - Get Locations for view type")]
        [InlineData(18, "compass", 1)]
        [InlineData(18, "timezone", 1)]
        [InlineData(18, "worldclock", 1)]
        [InlineData(0, "compass", 0)]
        public async Task GetLocationsForViewType(int configId, string type, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.GetLocationsForViewType(configId, type)).Returns
                    (Task.FromResult(new ConfigAvailableLocationsDTO()
                    {
                        Cities = new List<CityDetails>() { new CityDetails()
                    { Country = "India", GeoRefid = 0, Name = "Bangalore", State = "Karnataka", GmtOffset = null} }
                    }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetLocationsForViewType(configId, type)).Returns(Task.FromResult<ConfigAvailableLocationsDTO>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/locations/" + type + "/available");
            var result = JsonConvert.DeserializeObject<ConfigAvailableLocationsDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.Cities.Count.Should().Be(inputResult);
        }
        #endregion

        #region Compass

        [Theory(DisplayName = "Views config - Get Available Compass location")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetAvailableCompassLocation(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.GetAvailableCompassLocation(configId)).Returns
                    (Task.FromResult(new CompassLocationsDTO()
                    {
                        LocationDetails = new List<LocationDetails>() { new LocationDetails()
                    { Index = 0, Location = new CityDetails() { Country = "India", GeoRefid = 0, GmtOffset = null, Name = "Bangalore", State = "Karnataka" } } }
                    }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetAvailableCompassLocation(configId)).Returns(Task.FromResult<CompassLocationsDTO>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/compass/locations");
            var result = JsonConvert.DeserializeObject<CompassLocationsDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.LocationDetails.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Get Airplane types")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetAirplaneTypes(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.GetAirplaneTypes(configId)).Returns
                    (Task.FromResult(new AirplaneData()
                    {
                        AirplaneList = new List<AirplaneTypes>() { new AirplaneTypes()
                    { Id = 0, Name = "Boieng777" } }
                    }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetAirplaneTypes(configId)).Returns(Task.FromResult<AirplaneData>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/compass/airplanetypes");
            var result = JsonConvert.DeserializeObject<AirplaneData>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.AirplaneList.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Get Available Airplane types")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetAvailableAirplaneTypes(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.GetAvailableAirplaneTypes(configId)).Returns
                    (Task.FromResult(new AirplaneData()
                    {
                        AirplaneList = new List<AirplaneTypes>() { new AirplaneTypes()
                    { Id = 0, Name = "Boieng777" } }
                    }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetAvailableAirplaneTypes(configId)).Returns(Task.FromResult<AirplaneData>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/compass/airplanetypes/available");
            var result = JsonConvert.DeserializeObject<AirplaneData>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.AirplaneList.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Add Compass Airplane types")]
        [InlineData(18, new string[] { "1,2" }, 1)]
        [InlineData(0, new string[] { "3,4" }, 0)]
        public async Task AddCompassAirplaneTypes(int configId, string[] airplaneId, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            List<string> planes = airplaneId[0].Split(",").ToList();
            viewsRepo.Setup(c => c.AddCompassAirplaneTypes(configId, planes)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(planes);
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/compass/airplanetypes", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (resultValue == 1)
                result.IsError.Should().BeFalse();
            else if (resultValue == 0)
                result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Views config - Get Compass Colors")]
        [InlineData(18)]
        [InlineData(0)]
        public async Task GetCompassColors(int configurationId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configurationId == 18)
                viewsRepo.Setup(c => c.GetCompassColors(configurationId)).Returns(Task.FromResult(new CompassColors() { CompassColorPlaceholder = "ffffff", Location_1_Color = "ffffff" }));
            else
                viewsRepo.Setup(c => c.GetCompassColors(configurationId)).Returns(Task.FromResult<CompassColors>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configurationId + "/compass/colors");
            var result = JsonConvert.DeserializeObject<CompassColors>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configurationId == 18)
                result.CompassColorPlaceholder.Should().NotBeNull();
            else if (configurationId == 0)
                result.Should().BeNull();
        }

        [Theory(DisplayName = "Views config - Update Compass Colors")]
        [InlineData(18, "ffffff", "location1", 1)]
        [InlineData(0, "ffffff", "location1", 0)]
        public async Task UpdateCompassColors(int configurationId, string color, string nodeName, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.UpdateCompassColors(configurationId, color, nodeName)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configurationId + "/compass/colors/" + color + "/node/" + nodeName, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (resultValue == 1)
                result.IsError.Should().BeFalse();
            else if (resultValue == 0)
                result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Views config - Update Compass Colors")]
        [InlineData(18, 0, 9, 1)]
        [InlineData(0, 0, 0, 0)]
        public async Task UpdateCompassLocation(int configurationId, int index, int georefid, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.UpdateCompassLocation(configurationId, index, georefid)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configurationId + "/compass/location/set/" + index + "/to/" + georefid, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (resultValue == 1)
                result.IsError.Should().BeFalse();
            else if (resultValue == 0)
                result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Views config - Update Compass Colors")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task getCompassMakkahValues(int configurationId, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configurationId == 18)
                viewsRepo.Setup(c => c.getCompassMakkahValues(configurationId)).Returns(Task.FromResult(new List<string>() { "true", "true" }));
            else if (configurationId == 0)
                viewsRepo.Setup(c => c.getCompassMakkahValues(configurationId)).Returns(Task.FromResult<List<string>>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configurationId + "/compass/makkah/values");
            var result = JsonConvert.DeserializeObject<List<string>>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configurationId == 18)
                result.Count.Should().Equals(resultValue);
            else if (configurationId == 0)
                result.Should().BeNull();
        }

        [Theory(DisplayName = "Views config - Update Compass Colors")]
        [InlineData(18, "image", "true", 1)]
        [InlineData(0, "image", "true", 0)]
        public async Task UpdateCompassValues(int configurationId, string type, string data, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.UpdateCompassValues(configurationId, type, data)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configurationId + "/compass/values/" + type + "/to/" + data, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (resultValue == 1)
                result.IsError.Should().BeFalse();
            else if (resultValue == 0)
                result.IsError.Should().BeTrue();
        }
        #endregion

        #region Timezone

        [Theory(DisplayName = "Views config - Get Available timezone location")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetAvailableTimezoneLocations(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.GetAvailableTimezoneLocations(configId)).Returns
                    (Task.FromResult(new TimezoneLocationDTO()
                    {
                        TimeZoneLocations = new List<CityDetails>() { new CityDetails()
                    { Country = "India", GeoRefid = 0, Name = "Bangalore", GmtOffset = null, State  = "Karnataka" } }
                    }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetAvailableTimezoneLocations(configId)).Returns(Task.FromResult<TimezoneLocationDTO>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);

            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/timezone/locations");
            var result = JsonConvert.DeserializeObject<TimezoneLocationDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.TimeZoneLocations.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Add or remove time zone locations")]
        [InlineData(18, new string[] { "1,2" }, 1)]
        [InlineData(0, new string[] { "3,4" }, 0)]
        public async Task AddRemoveTimezoneLocations(int configId, string[] listGeoRefId, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            List<string> geoRef = listGeoRefId[0].Split(",").ToList();
            if (configId == 18)
                viewsRepo.Setup(c => c.UpdateTimezoneLocations(configId, geoRef, "add")).Returns(Task.FromResult(resultValue));
            else if (configId == 0)
                viewsRepo.Setup(c => c.UpdateTimezoneLocations(configId, geoRef, "delete")).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(geoRef);
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = new HttpResponseMessage();
            if (configId == 18)
                response = await client.PostAsync("api/ViewConfiguration/" + configId + "/timezone/locations/add", byteContent);
            else if (configId == 0)
                response = await client.PostAsync("api/ViewConfiguration/" + configId + "/timezone/locations/delete", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (resultValue == 1)
                result.IsError.Should().BeFalse();
            else if (resultValue == 0)
                result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Views config - Get timezone colors")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetTimezoneColors(int configId, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            IEnumerable<string> colors = new List<string>();
            List<string> color = new List<string>();
            color.Add("ffffff");
            color.Add("ffffff");
            if (configId == 18)
            {
                colors = color;
            }
            viewsRepo.Setup(c => c.GetTimezoneColors(configId)).Returns(Task.FromResult(colors));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = new HttpResponseMessage();
            response = await client.GetAsync("api/ViewConfiguration/" + configId + "/timezone/colors");
            var result = JsonConvert.DeserializeObject<IEnumerable<string>>(await response.Content.ReadAsStringAsync());

            // Assert
            result.Count().Should().Equals(resultValue);
        }

        [Theory(DisplayName = "Views config - Update Timezone Colors")]
        [InlineData(1, "ffffff", "dest_color", 1)]
        [InlineData(0, "ffffff", "dest_color", 0)]
        public async Task UpdateTimezoneColors(int configId, string color, string node, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.UpdateTimezoneColors(configId, color, node)).Returns(Task.FromResult(inputResult));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/timezone/colors/" + color + "/node/" + node, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 1)
                result.IsError.Should().BeFalse();
            else if (configId == 0)
                result.IsError.Should().BeTrue();
        }

        #endregion

        #region WorldClock

        [Theory(DisplayName = "Views config - Get world clock location")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetAvailableWorlclockLocations(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.GetAvailableWorlclockLocations(configId)).Returns
                (Task.FromResult(new WorldClockLocationsDTO()
                {
                    WorldclockLocations = new List<CityDetails>()
                { new CityDetails { Country = "India", Name = "Bangalore", State = "Karnataka", GeoRefid = 0, GmtOffset = null } }
                }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetAvailableWorlclockLocations(configId)).Returns(Task.FromResult<WorldClockLocationsDTO>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/worldclock/locations");
            var result = JsonConvert.DeserializeObject<WorldClockLocationsDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.WorldclockLocations.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Get alternate world clock location")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetAlternateWorlclockLocations(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            if (configId == 18)
                viewsRepo.Setup(c => c.GetAlternateWorlclockLocations(configId)).Returns
                (Task.FromResult(new WorldClockLocationsDTO()
                {
                    WorldclockLocations = new List<CityDetails>()
                { new CityDetails { Country = "India", Name = "Bangalore", State = "Karnataka", GeoRefid = 0, GmtOffset = null } }
                }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetAlternateWorlclockLocations(configId)).Returns(Task.FromResult<WorldClockLocationsDTO>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/worldclock/alternates");
            var result = JsonConvert.DeserializeObject<WorldClockLocationsDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.WorldclockLocations.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Move Selected View")]
        [InlineData(18, "126", "1", "3", 1)]
        [InlineData(19, "127", "3", "1", 2)]
        [InlineData(0, "129", "6", "1", 0)]
        public async Task MoveSelectedWorldClockLocation(int configId, string geoRefId, string oldPosition, string newPosition, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.MoveSelectedWorldClockLocation(configId, geoRefId, int.Parse(oldPosition), int.Parse(newPosition))).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/worldclock/move/" + geoRefId + "/from/" + oldPosition + "/to/" + newPosition, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be("Node successfully repositioned");
            else if (configId == 19)
                result.Message.Should().Be("Node is not enabled");
            else if (configId == 0)
                result.Message.Should().Be("Node repositioning failed");
        }

        [Theory(DisplayName = "Views config - Add or remove world clock locations")]
        [InlineData(18, new string[] { "123,234" }, 1)]
        [InlineData(0, new string[] { "321,432" }, 0)]
        public async Task AddRemoveWorldclockLocation(int configId, string[] listGeoRefId, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            List<string> gerRef = listGeoRefId[0].Split(",").ToList();
            if (configId == 18)
                viewsRepo.Setup(c => c.UpdateWorldclockLocation(configId, gerRef, "add")).Returns(Task.FromResult(resultValue));
            else if (configId == 0)
                viewsRepo.Setup(c => c.UpdateWorldclockLocation(configId, gerRef, "delete")).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(gerRef);
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = new HttpResponseMessage();
            if (configId == 18)
                response = await client.PostAsync("api/ViewConfiguration/" + configId + "/worldclock/locations/add", byteContent);
            else if (configId == 0)
                response = await client.PostAsync("api/ViewConfiguration/" + configId + "/worldclock/locations/delete", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (resultValue == 1)
                result.IsError.Should().BeFalse();
            else if (resultValue == 0)
                result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Views config - Move Selected View")]
        [InlineData(18, "126", "1", 1)]
        [InlineData(0, "129", "6", 0)]
        public async Task AddAlternateWorldclockCity(int configId, string geoRefId, string position, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.AddAlternateWorldclockCity(configId, int.Parse(position), int.Parse(geoRefId))).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/worldclock/alternate/set/" + position + "/to/" + geoRefId, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be("Success");
            else if (configId == 0)
                result.Message.Should().Be("Failure");
        }
        #endregion

        #region Flight Info

        [Theory(DisplayName = "Views config - Get flight info parameters")]
        [InlineData(18)]
        [InlineData(0)]
        public async Task GetFlightInfoParameters(int configId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            Dictionary<FlightInfoParams, List<string>> data = new Dictionary<FlightInfoParams, List<string>>();
            FlightInfoParams flightInfo = new FlightInfoParams();
            flightInfo.DisplayName = "eGroundSpeed,eAltitude";
            flightInfo.Name = "Ground Speed,Altitude";

            List<string> name = new List<string>();
            name.Add("eGroundSpeed");
            name.Add("eAltitude");

            data.Add(flightInfo, name);
            string pageName = "flightInfo";
            if (configId == 18)
                viewsRepo.Setup(c => c.GetFlightInfoParameters(pageName, configId)).Returns
                    (Task.FromResult(data));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetFlightInfoParameters(pageName, configId)).Returns
                    (Task.FromResult<Dictionary<FlightInfoParams, List<string>>>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/flightinfo/parameters");
            var result = JsonConvert.DeserializeObject<List<string>>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Count.Should().Be(0);
            else if (configId == 0)
                result.Should().BeNullOrEmpty();
        }

        [Theory(DisplayName = "Views config - Get available flight info parameters")]
        [InlineData(18, 2)]
        [InlineData(0, 0)]
        public async Task GetAvailableFlightInfoParameters(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            Dictionary<string, string> data = new Dictionary<string, string>();
            string keys = "eGroundSpeed,eAltitude";
            string values = "Ground Speed,Altitude";
            data.Add(keys, values);
            string pageName = "flightInfo";
            if (configId == 18)
                viewsRepo.Setup(c => c.GetAvailableFlightInfoParameters(pageName, configId)).Returns
                    (Task.FromResult(data));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetAvailableFlightInfoParameters(pageName, configId)).Returns
                    (Task.FromResult<Dictionary<string, string>>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/flightinfo/parameters/available");
            var result = JsonConvert.DeserializeObject<List<string>>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Add new flight info parameters")]
        [InlineData(18, new string[] { "Altitude,GroundSpeed" })]
        [InlineData(0, new string[] { "Altitude,GroundSpeed" })]
        public async Task AddNewFlighInfoParams(int configId, string[] flightInfoParameters)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            string pageName = "flightInfo";
            if (configId == 18)
                viewsRepo.Setup(c => c.AddNewFlighInfoParams(pageName, configId, flightInfoParameters.ToList())).Returns(Task.FromResult(1));
            else if (configId == 0)
                viewsRepo.Setup(c => c.AddNewFlighInfoParams(pageName, configId, flightInfoParameters.ToList())).Returns(Task.FromResult(0));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(flightInfoParameters.ToList());
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/flightinfo/parameters", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            result.Message.Should().Be("Failure");
        }

        [Theory(DisplayName = "Views config - Move flight info parameters")]
        [InlineData(18, 1, 2)]
        [InlineData(0, 2, 3)]
        public async Task MoveFlightInfoParameterPosition(int configId, int fromPosition, int toPosition)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            string pageName = "flightInfo";
            if (configId == 18)
                viewsRepo.Setup(c => c.MoveFlightInfoParameterPosition(pageName, configId, fromPosition, toPosition)).Returns(Task.FromResult(1));
            else if (configId == 0)
                viewsRepo.Setup(c => c.MoveFlightInfoParameterPosition(pageName, configId, fromPosition, toPosition)).Returns(Task.FromResult(0));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "/flightinfo/parameters/move/" + fromPosition + "/to/" + toPosition, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be("Success");
            else if (configId == 0)
                result.Message.Should().Be("Failure");
        }

        [Theory(DisplayName = "Views config - ReMove flight info parameters")]
        [InlineData(18, 1)]
        [InlineData(0, 2)]
        public async Task RemoveSelectedFlightInfoParameter(int configId, int fromPosition)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            string pageName = "flightInfo";
            if (configId == 18)
                viewsRepo.Setup(c => c.RemoveSelectedFlightInfoParameter(pageName, configId, fromPosition)).Returns(Task.FromResult(1));
            else if (configId == 0)
                viewsRepo.Setup(c => c.RemoveSelectedFlightInfoParameter(pageName, configId, fromPosition)).Returns(Task.FromResult(0));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.DeleteAsync("api/ViewConfiguration/" + configId + "/flightinfo/parameters/" + fromPosition);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be("Success");
            else if (configId == 0)
                result.Message.Should().Be("Failure");
        }
        #endregion

        #region Makkah

        [Theory(DisplayName = "Views config - Get Makkah prayer times")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetMakkahPrayertimes(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            List<MakkahPrayerCalculationTypes> makkahPrayerCalculationTypes = new List<MakkahPrayerCalculationTypes>();
            MakkahPrayerCalculationTypes makkahPrayerCalculation = new MakkahPrayerCalculationTypes();
            makkahPrayerCalculation.MakkahTypeName = "";
            makkahPrayerCalculation.MakkahDisplayName = "";
            makkahPrayerCalculationTypes.Add(makkahPrayerCalculation);
            if (configId == 18)
                viewsRepo.Setup(c => c.GetMakkahPrayertimes(configId)).Returns
                    (Task.FromResult(makkahPrayerCalculationTypes));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetMakkahPrayertimes(configId)).Returns
                    (Task.FromResult<List<MakkahPrayerCalculationTypes>>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/makkah/prayertimecalculations/available");
            var result = JsonConvert.DeserializeObject<List<string>>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Get available Makkah locations")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetMakkahLocation(int configId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            Dictionary<string, string> data = new Dictionary<string, string>();
            string key = "mwl";
            string value = "MWL";
            data.Add(key, value);

            if (configId == 18)
                viewsRepo.Setup(c => c.GetMakkahLocation(configId, "available")).Returns
                    (Task.FromResult(new MakkahLocations()
                    {
                        AvailableMakkahLocations = new List<CityDetails>()
                        { new CityDetails { Country = "India", Name = "Bangalore", State = "Karnataka", GeoRefid = 0, GmtOffset = null } }
                    }));
            else if (configId == 0)
                viewsRepo.Setup(c => c.GetMakkahLocation(configId, "available")).Returns
                    (Task.FromResult<MakkahLocations>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "/makkah/locations");
            var result = JsonConvert.DeserializeObject<MakkahLocations>(await response.Content.ReadAsStringAsync());

            // Assert
            if (inputResult == 0)
                result.Should().BeNull();
            else
                result.AvailableMakkahLocations.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Views config - Update Makkah Location And PrayerTime Location")]
        [InlineData(1,"true", "available", 1)]
        [InlineData(1, "true", "available", 0)]
        public async Task UpdateMakkahLocationAndPrayerTimeLocation(int configId, string data, string type, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.UpdateMakkahLocationAndPrayerTimeLocation(configId, data, type)).Returns(Task.FromResult(inputResult));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ViewConfiguration/" + configId + "makkah/location/set/to/" + data, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be("Node successfully repositioned");
            else if (configId == 0)
                result.Message.Should().Be("Node repositioning failed");
        }

        [Theory(DisplayName = "Views config - Update Makkah Location And PrayerTime Location")]
        [InlineData(1)]
        public async Task GetMakkahValues(int configId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var viewsRepo = new Mock<ViewsConfigurationRepository>();
            viewsRepo.Setup(c => c.GetMakkahValues(configId)).Returns(Task.FromResult(new MakkahData()
            {
                Cities = new List<CityDetails>()
                {
                    { new CityDetails { Country = "India", Name = "Bangalore", State = "Karnataka", GeoRefid = 0, GmtOffset = null } }
                },
                MakkahValues = new List<string>()
                {
                    {"a,a,a"}
                },
                PrayerTimeCaluculation = "test"
            }));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ViewsConfigurationRepository).Returns(viewsRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ViewConfiguration/" + configId + "makkah/values");
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be("Node successfully repositioned");
            else if (configId == 0)
                result.Message.Should().Be("Node repositioning failed");
        }

        #endregion

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
