using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using FluentAssertions;
using Moq;
using Newtonsoft.Json;
using Xunit;

namespace backend.IntegrationTest.Tests.Custom_Content
{
    [Collection("sequential")]
    public class PlaceNamesTest: IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public PlaceNamesTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

        private Moq.Mock<SimpleRepository<User>> GetMockUserRepo()
        {
            var userRepo = new Moq.Mock<SimpleRepository<User>>();
            userRepo.Setup(c => c.FirstAsync("UserName", "katherine.holcomb")).Returns(Task.FromResult(new User()));
            userRepo.Setup(c => c.FirstAsync("UserName", "aehageme")).Returns(Task.FromResult(new User()));
            return userRepo;
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



        private void SetUpMockRepo(Moq.Mock<CustomContentRepository> customConfigRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(customConfigRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }

        [Theory(DisplayName = "PlaceNames - GetPlaceNamesTest")]
        [InlineData(1)]
        public async Task GetPlaceNamesTest(int configId)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            List<PlaceName> placeNames = new List<PlaceName>() { new PlaceName() { Name = "test" } };
            customContentRepo.Setup(c => c.GetPlaceNames(configId)).Returns(Task.FromResult(placeNames));
            SetUpMockRepo(customContentRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/loadplacenames");
            var result = JsonConvert.DeserializeObject<List<PlaceName>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(placeNames.Count);
        }

        [Theory(DisplayName = "PlaceNames - GetPlaceNameInfoTest")]
        [InlineData(1,1)]
        public async Task GetPlaceNameInfoTest(int configId,int placeNameId)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            List<PlaceNameLanguage> placeNames = new List<PlaceNameLanguage>() { new PlaceNameLanguage() { LanguageName="english" } };
            customContentRepo.Setup(c => c.GetPlaceNameInfo(configId,placeNameId)).Returns(Task.FromResult(placeNames));
            SetUpMockRepo(customContentRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getplacenamespellinginfo/" + placeNameId);
            var result = JsonConvert.DeserializeObject<List<PlaceNameLanguage>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(placeNames.Count);
        }

        [Theory(DisplayName = "PlaceNames - GetCatTypesTest")]
        [InlineData(1, 1)]
        public async Task GetCatTypesTest(int configId, int placeNameId)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            List<PlaceCatType> placeNames = new List<PlaceCatType>() { new PlaceCatType() { CatTypeDesc="city" } };
            customContentRepo.Setup(c => c.GetCatTypes(configId, placeNameId)).Returns(Task.FromResult(placeNames));
            SetUpMockRepo(customContentRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getcattypes/" + placeNameId);
            var result = JsonConvert.DeserializeObject<List<PlaceCatType>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(placeNames.Count);
        }

        [Theory(DisplayName = "PlaceNames - GetVisibilityTest")]
        [InlineData(1, 1)]
        public async Task GetVisibilityTest(int configId, int georefId)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            List<Visibility> placeNames = new List<Visibility>() { new Visibility() { Resolution=100 } };
            customContentRepo.Setup(c => c.GetVisibility(configId, georefId)).Returns(Task.FromResult(placeNames));
            SetUpMockRepo(customContentRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getvisibilityinfo/" + georefId);
            var result = JsonConvert.DeserializeObject<List<Visibility>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(placeNames.Count);
        }

        [Theory(DisplayName = "PlaceNames - UpdatePlaceNameCatTypeTest")]
        [InlineData(1, 1,1)]
        public async Task UpdatePlaceNameCatTypeTest(int configId, int placeNameId, int catType)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            ListModlist listModData = new ListModlist();
            customContentRepo.Setup(c => c.UpdatePlaceNameCatType(configId, placeNameId, listModData)).Returns(Task.FromResult(1));
            SetUpMockRepo(customContentRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/updateCatType/" + placeNameId + "/" + catType);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(false);
        }

        [Theory(DisplayName = "PlaceNames - SavePlaceNameSpellingTest")]
        [InlineData(1, 1)]
        public async Task SavePlaceNameSpellingTest(int configId, int georefId)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            List<PlaceNameLanguage> placeNameLanguages = new List<PlaceNameLanguage>() { new PlaceNameLanguage() { LanguageName = "english" } };
            customContentRepo.Setup(c => c.SavePlaceNameSpelling(configId, georefId, placeNameLanguages.ToArray())).Returns(Task.FromResult(1));
            SetUpMockRepo(customContentRepo, configId);

            var httpContent = JsonConvert.SerializeObject(placeNameLanguages.ToArray());
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/CustomContent/" + configId + "/updateCatType/" + georefId, byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(false);
        }

        [Theory(DisplayName = "PlaceNames - GetAdvancedPlaceNameInfoTest")]
        [InlineData(1, 1)]
        public async Task GetAdvancedPlaceNameInfoTest(int configId, int placeNameId)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            PlaceName placeName = new PlaceName() { Name = "test" };
            customContentRepo.Setup(c => c.GetAdvancedPlaceNameInfo(configId, placeNameId)).Returns(Task.FromResult(placeName));
            SetUpMockRepo(customContentRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getadvancedplacenameinfo/" + placeNameId);
            var result = JsonConvert.DeserializeObject<PlaceName>(await response.Content.ReadAsStringAsync());
            result.Name.Should().Be(placeName.Name);
        }

        [Theory(DisplayName = "PlaceNames - SavePlaceInfoTest")]
        [InlineData(1)]
        public async Task SavePlaceInfoTest(int configId)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            PlaceName placeName = new PlaceName() { Name = "test" };
            ListModlistsave placeNames = new ListModlistsave() { Name = "test" };
            Dictionary<int, int> keyValuePairs = new Dictionary<int, int>();
            keyValuePairs.Add(1, 1);
            customContentRepo.Setup(c => c.SavePlaceInfo(configId, placeNames)).Returns(Task.FromResult(keyValuePairs));
            SetUpMockRepo(customContentRepo, configId);

            var httpContent = JsonConvert.SerializeObject(placeName);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/CustomContent/" + configId + "/saveplacename", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultPlaceName>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(false);
        }

        [Theory(DisplayName = "PlaceNames - SaveVisibilityTest")]
        [InlineData(1,1)]
        public async Task SaveVisibilityTest(int configId,int geoRefId)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            List<Visibility> visibilities = new List<Visibility>();
            Visibility visibility = new Visibility() { Resolution = 100, IsExcluded = false, Priority = 0, VisibilityId = 1 };
            ListModlistVisiblity listModlistInfosaveVisiblity = new ListModlistVisiblity();
            visibilities.Add(visibility);
            customContentRepo.Setup(c => c.SaveVisibility(configId, geoRefId, visibilities.ToArray(), listModlistInfosaveVisiblity)).Returns(Task.FromResult(1));
            SetUpMockRepo(customContentRepo, configId);

            var httpContent = JsonConvert.SerializeObject(visibilities.ToArray());
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/CustomContent/" + configId + "/savevisibility/"+geoRefId, byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(false);
        }
    }
}
