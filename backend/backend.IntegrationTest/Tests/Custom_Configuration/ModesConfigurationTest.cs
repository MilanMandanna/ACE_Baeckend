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
using System.Net.Http;
using Moq;
using Ace.DataLayer.Models;
using System.Net.Http.Headers;

namespace backend.IntegrationTest.Tests.Custom_Configuration
{
    public class ModesConfigurationTest: IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;
        public ModesConfigurationTest(ApplicationFactory<backend.Startup> factory)
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



        private void SetUpMockRepo(Moq.Mock<ModesConfigurationRepository> modesRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.ModesConfigurationRepository).Returns(modesRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }

        private Mock<ModeConfigurationMappingRepository> MockModelMapping()
        {
            var modeMappingRepo = new Moq.Mock<ModeConfigurationMappingRepository>();

            List<ModeConfigurationMapping> modeConfigurationMappings = new List<ModeConfigurationMapping>();
            modeConfigurationMappings.Add(new ModeConfigurationMapping());
            modeMappingRepo.Setup(c => c.FilterAsync("ConfigurationID", 18)).Returns(Task.FromResult(modeConfigurationMappings));
            modeMappingRepo.Setup(c => c.FilterAsync("ConfigurationID", 0)).Returns(Task.FromResult(new List<ModeConfigurationMapping>()));
            return modeMappingRepo;
        }

        [Theory(DisplayName = "Modes config - GetAllModes")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetAllModes(int configId, int? expectedResult)
        {


            IEnumerable<Mode> modes;
            List<Mode> lstMode = new List<Mode>();
            lstMode.Add(new Mode());
            modes = lstMode;

            var modesRepo = new Moq.Mock<ModesConfigurationRepository>();
            modesRepo.Setup(c => c.GetAllModes(18)).Returns(Task.FromResult(modes));

            SetUpMockRepo(modesRepo,configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ModesConfiguration/" + configId + "/modes/all");
            var result = JsonConvert.DeserializeObject<List<Mode>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Modes config - AddMode")]
        [InlineData(18, 0)]
        [InlineData(0, 0)]
        public async Task AddMode(int configId, int expectedResult)
        {

            Mode mode = new Mode();

            var modesRepo = new Moq.Mock<ModesConfigurationRepository>();
            

            modesRepo.Setup(c => c.GetMaxModeDefID(18)).Returns(Task.FromResult(1));
            modesRepo.Setup(c => c.GetMaxModeDefID(0)).Returns(Task.FromResult(0));

            modesRepo.Setup(c => c.InsetNewMode(mode)).Returns(Task.FromResult(1));

            modesRepo.Setup(c => c.GetNextModeDefID()).Returns(Task.FromResult(1));

            modesRepo.Setup(c => c.AddMode(18, mode)).Returns(Task.FromResult((1, "")));
            modesRepo.Setup(c => c.AddMode(0, mode)).Returns(Task.FromResult((0, "")));

            SetUpMockRepo(modesRepo,configId);

            var httpContent = JsonConvert.SerializeObject(mode);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ModesConfiguration/" + configId + "/modes/add", byteContent);
            var result = JsonConvert.DeserializeObject<(int,string)>(await response.Content.ReadAsStringAsync());
            result.Item1.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Modes config - RemoveMode")]
        [InlineData(18, 1, false)]
        [InlineData(0, 1, true)]
        public async Task RemoveMode(int configId, int modeId, bool expectedResult)
        {
            Mode mode = new Mode();

            var modesRepo = new Moq.Mock<ModesConfigurationRepository>();
            modesRepo.Setup(c => c.RemoveMode(18, "1")).Returns(Task.FromResult(1));
            modesRepo.Setup(c => c.RemoveMode(0, "1")).Returns(Task.FromResult(0));


            SetUpMockRepo(modesRepo,configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ModesConfiguration/" + configId + "/modes/" + modeId + "/remove",null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expectedResult);

        }
    }
}
