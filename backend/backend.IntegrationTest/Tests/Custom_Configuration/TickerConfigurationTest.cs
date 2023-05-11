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
using System.Linq;

namespace backend.IntegrationTest.Tests.Custom_Configuration
{
    public class TickerConfigurationTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public TickerConfigurationTest(ApplicationFactory<backend.Startup> factory)
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



        private void SetUpMockRepo(Moq.Mock<TickerConfigurationRepository> tickerRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.TickerConfigurationRepository).Returns(tickerRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }

        [Theory(DisplayName = "Ticker config - GetTicker")]
        [InlineData(18, 0)]
        [InlineData(1, 1)]

        public async Task GetTicker(int configId, int? expectedResult)
        {
            
            var tickerMockRepo = new Moq.Mock<TickerConfigurationRepository>();
            Dictionary<string, object> lstTicker = new Dictionary<string, object>();
            lstTicker.Add("Position", "top");
            tickerMockRepo.Setup(c => c.GetTicker(1)).Returns(Task.FromResult(lstTicker));
            tickerMockRepo.Setup(c => c.GetTicker(18)).Returns(Task.FromResult(new Dictionary<string, object>()));

            SetUpMockRepo(tickerMockRepo,configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/TickerConfiguration/" + configId + "/ticker");
            var result = JsonConvert.DeserializeObject<Dictionary<string, object>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Ticker config - UpdateTicker")]
        [InlineData(18, "ticker1", "newvalue", true)]
        [InlineData(1, "ticker1", "newvalue", false)]

        public async Task UpdateTicker(int configId, string name, string value, bool expectedResult)
        {

            var tickerMockRepo = new Moq.Mock<TickerConfigurationRepository>();
            tickerMockRepo.Setup(c => c.UpdateTicker(1, "ticker1", "newvalue")).Returns(Task.FromResult(1));
            tickerMockRepo.Setup(c => c.UpdateTicker(18, "ticker1", "newvalue")).Returns(Task.FromResult(0));

            SetUpMockRepo(tickerMockRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/TickerConfiguration/" + configId + "/ticker/" + name + "/set/" + value, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Ticker config - GetSelectedTickerParameters")]
        [InlineData(18, 1)]
        public async Task GetSelectedTickerParameters(int configId, int expectedResult)
        {

            var tickerMockRepo = new Moq.Mock<TickerConfigurationRepository>();

            List<string> lstTickerPrams = new List<string>();
            lstTickerPrams.Add("param1");
            IEnumerable<string> paramss;
            paramss = lstTickerPrams;

            List<TickerParameter> lstTickerPrams1 = new List<TickerParameter>();
            lstTickerPrams1.Add(new TickerParameter() { Name= "param1" });
            IEnumerable<TickerParameter> paramss1;
            paramss1 = lstTickerPrams1;

            tickerMockRepo.Setup(c => c.GetAllTickerParameters(18)).Returns(Task.FromResult(paramss1));
            tickerMockRepo.Setup(c => c.GetSelectedTickerParameters(18)).Returns(Task.FromResult(paramss));

            SetUpMockRepo(tickerMockRepo,configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/TickerConfiguration/" + configId + "/ticker/parameters/selected");
            var result = JsonConvert.DeserializeObject<List<TickerParameter>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Ticker config - GetSelectedTickerParameters")]
        [InlineData(18, 1)]
        public async Task GetAllTickerParameters(int configId, int expectedResult)
        {

            var tickerMockRepo = new Moq.Mock<TickerConfigurationRepository>();

            List<TickerParameter> lstTickerPrams = new List<TickerParameter>();
            lstTickerPrams.Add(new TickerParameter());
            IEnumerable<TickerParameter> paramss;
            paramss = lstTickerPrams;

            tickerMockRepo.Setup(c => c.GetAllTickerParameters(18)).Returns(Task.FromResult(paramss));

            SetUpMockRepo(tickerMockRepo,configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/TickerConfiguration/" + configId + "/ticker/parameters/all");
            var result = JsonConvert.DeserializeObject<List<TickerParameter>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Ticker config - AddTickerParameter")]
        [InlineData(18, false)]
        [InlineData(1, true)]
        public async Task AddTickerParameter(int configId, bool expectedResult)
        {

            var tickerMockRepo = new Moq.Mock<TickerConfigurationRepository>();

            List<TickerParameter> lstTickerPrams = new List<TickerParameter>();
            lstTickerPrams.Add(new TickerParameter() { Name = "eAltitude" ,DisplayName = "Altitude"});
            List<string> tickerParameters = lstTickerPrams.Select(param => param.Name).ToArray().ToList();

            tickerMockRepo.Setup(c => c.AddTickerParameters(18, tickerParameters)).Returns(Task.FromResult(1));
            tickerMockRepo.Setup(c => c.AddTickerParameters(1, tickerParameters)).Returns(Task.FromResult(0));

            SetUpMockRepo(tickerMockRepo,configId);

            

            var httpContent = JsonConvert.SerializeObject(lstTickerPrams);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");


            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/TickerConfiguration/" + configId + "/ticker/parameters/add", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Ticker config - RemoveTickerParameter")]
        [InlineData(18, false)]
        [InlineData(1, true)]

        public async Task RemoveTickerParameter(int configId, bool expectedResult)
        {

            var tickerMockRepo = new Moq.Mock<TickerConfigurationRepository>();

            List<string> lstParam = new List<string>();
            lstParam.Add("param1");
            IEnumerable<string> strParams;
            strParams = lstParam;
            int position = 1;
            tickerMockRepo.Setup(c => c.GetSelectedTickerParameters(18)).Returns(Task.FromResult(strParams));

            tickerMockRepo.Setup(c => c.RemoveTickerParameter(18, position)).Returns(Task.FromResult(1));
            tickerMockRepo.Setup(c => c.RemoveTickerParameter(1, position)).Returns(Task.FromResult(0));

            SetUpMockRepo(tickerMockRepo,configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/TickerConfiguration/" + configId + "/ticker/parameters/remove/"+position, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Ticker config - MoveTickerParameterPosition")]
        [InlineData(18,1,2, false)]
        [InlineData(1,-1,2, true)]

        public async Task MoveTickerParameterPosition(int configId,int from,int to, bool expectedResult)
        {
            var tickerMockRepo = new Moq.Mock<TickerConfigurationRepository>();
            tickerMockRepo.Setup(c => c.MoveTickerParameterPosition(18,1,2)).Returns(Task.FromResult(1));
            tickerMockRepo.Setup(c => c.MoveTickerParameterPosition(18, -1, 2)).Returns(Task.FromResult(0));
            SetUpMockRepo(tickerMockRepo,configId);
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/TickerConfiguration/" + configId + "/ticker/parameters/move/" + from + "/to/" + to, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expectedResult);

        }
    }
}
