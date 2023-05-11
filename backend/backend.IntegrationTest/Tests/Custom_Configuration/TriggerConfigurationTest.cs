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
using backend.Logging.Contracts;
using backend.BusinessLayer.Contracts.Configuration;
using backend.Controllers.Configurations;
using Microsoft.AspNetCore.Mvc;
using System.Linq;

namespace backend.IntegrationTest.Tests.Custom_Configuration
{
    public class TriggerConfigurationTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public TriggerConfigurationTest(ApplicationFactory<backend.Startup> factory)
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

        private Mock<AirportInfoRepository> MockAirportData(int configId)
        {
        
            List<string> list = new List<string>();

            list.Add("CID");
            list.Add("LAX");
            Mock<AirportInfoRepository> mock = new Mock<AirportInfoRepository>();
            mock.Setup(c => c.GetIATAList(configId)).Returns(Task.FromResult(list));
            mock.Setup(c => c.GetICAOList(configId)).Returns(Task.FromResult(list));
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



        private void SetUpMockRepo(Moq.Mock<TriggerConfigurationRepository> triggerRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.AirportInfo).Returns(MockAirportData(configId).Object);
            mockRepos.Setup(c => c.TriggerConfigurationRepository).Returns(triggerRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }

        [Theory(DisplayName = "Triggers config - GetAllTriggers")]
        [InlineData(18, 1)]
        [InlineData(1, 1)]

        public async Task GetAllTriggers(int configId, int? expectedResult)
        {
            IEnumerable<Trigger> triggers;
            List<Trigger> lstTrigers = new List<Trigger>();
            var trigger = new Trigger();
            trigger.parameters = new List<object>();
            TriggerParameter param = new TriggerParameter()
            {
                DisplayName = "Ground Speed",
                Name = "GS",
                EditorFieldFormat = "none",
                EditorFieldType = "numeric",
                EditorFieldValue = "0",
                EditorFieldValues = null,
                EditorFieldValueUnit = "none",
                IATAList = null,
                ICAOList = null,
                Operator = "Equal to",
                Operators = null
            };
            trigger.parameters.Add(param);
            trigger.Condition = "GS EQ 0";
            lstTrigers.Add(trigger);
            triggers = lstTrigers;

            var triggersMockRepo = new Moq.Mock<TriggerConfigurationRepository>();
            triggersMockRepo.Setup(c => c.GetAllTriggers(18)).Returns(Task.FromResult(triggers));
            triggersMockRepo.Setup(c => c.GetAllTriggers(1)).Returns(Task.FromResult(triggers));

            SetUpMockRepo(triggersMockRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/TriggerConfiguration/" + configId.ToString() + "/triggers/all");
            var result = JsonConvert.DeserializeObject<List<Trigger>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Triggers config - AddTrigger")]
        [InlineData(18, true)]
        [InlineData(1, false)]

        public async Task AddTrigger(int configId, bool expectedResult)
        {
            Trigger trigger = new Trigger();
            trigger.Name = "trigger1";
            trigger.Id = "10";
            trigger.IsDefault = "yes";
            trigger.Type = "Type1";
            trigger.Condition = "some";
            trigger.parameters = new List<object>();
            TriggerParameter param = new TriggerParameter()
            {
                DisplayName = "Ground Speed",
                Name = "GS",
                EditorFieldFormat = "none",
                EditorFieldType = "numeric",
                EditorFieldValue = "0",
                EditorFieldValues = null,
                EditorFieldValueUnit = "none",
                IATAList = null,
                ICAOList = null,
                Operator = "Equal to",
                Operators = null
            };
            trigger.parameters.Add(param);

            var triggersMockRepo = new Moq.Mock<TriggerConfigurationRepository>();
            triggersMockRepo.Setup(c => c.AddTriggerItem(configId, trigger)).Returns(Task.FromResult(0));
            triggersMockRepo.Setup(c => c.AddTriggerItem(configId, trigger)).Returns(Task.FromResult(1));

            SetUpMockRepo(triggersMockRepo, configId);

            var httpContent = JsonConvert.SerializeObject(trigger);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/TriggerConfiguration/" + configId + "/triggers/add", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Triggers config - RemoveTrigger")]
        [InlineData(18, "1", false)]
        public async Task RemoveTrigger(int configId, string triggerId, bool expectedResult)
        {
            var triggersMockRepo = new Moq.Mock<TriggerConfigurationRepository>();
            triggersMockRepo.Setup(c => c.RemoveTrigger(18, "1")).Returns(Task.FromResult(1));

            SetUpMockRepo(triggersMockRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/TriggerConfiguration/" + configId + "/triggers/" + triggerId + "/remove",null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Triggers config - GetTriggr")]
        [InlineData(18, "1", 1)]
        public async Task GetTrigger(int configId, string triggerId, int expectedResult)
        {

            IEnumerable<Trigger> triggers;
            List<Trigger> lstTrigers = new List<Trigger>();
            Trigger trigger = new Trigger() { Id = "1", Name = "Trigger1" };
            lstTrigers.Add(new Trigger() { Id = "1", Name = "Trigger1" });
            triggers = lstTrigers;

            var triggersMockRepo = new Moq.Mock<TriggerConfigurationRepository>();
            triggersMockRepo.Setup(c => c.GetTrigger(18, "1")).Returns(Task.FromResult(triggers));
            triggersMockRepo.Setup(c => c.GetAllTriggers(18)).Returns(Task.FromResult(triggers));
            SetUpMockRepo(triggersMockRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/TriggerConfiguration/" + configId + "/triggers/all");
            var result = JsonConvert.DeserializeObject<List<Trigger>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Triggers config - GetAllTriggerParameters")]
        [InlineData("18", 1)]
        public async Task GetAllTriggerParameters(string configId, int? expectedResult)
        {

            Mock<ITriggerConfigurationService> triggerServiceMock = new Mock<ITriggerConfigurationService>();
            Mock<ILoggerManager> loggerManagerMock = new Mock<ILoggerManager>();


            Task<IEnumerable<TriggerParameter>> triggerparameter;
            List<TriggerParameter> lstTrigers = new List<TriggerParameter>();
            var triggerparam = new TriggerParameter();

            lstTrigers.Add(triggerparam);
            var triggersMockRepo = new Moq.Mock<TriggerConfigurationRepository>();

            SetUpMockRepo(triggersMockRepo, Int32.Parse(configId));
            triggerparameter = new Task<IEnumerable<TriggerParameter>>(lstTrigers.AsEnumerable); ;

            //Mock the service method
            triggerServiceMock.Setup(c => c.GetAllTriggerParameters(Int32.Parse(configId))).Returns(triggerparameter);


            SetUpMockRepo(triggersMockRepo, Int32.Parse(configId));

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/TriggerConfiguration/" + configId + "/trigger/parameters");
            var result = JsonConvert.DeserializeObject<List<Trigger>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().BeGreaterThan(0);

        }

        [Theory(DisplayName = "Triggers config - ValidateTrigger")]
        [InlineData(false)]
        [InlineData(true)]

        public void ValidateTrigger(bool expectedResult)
        {

            Mock<ITriggerConfigurationService> triggerServiceMock = new Mock<ITriggerConfigurationService>();
            Mock<ILoggerManager> loggerManagerMock = new Mock<ILoggerManager>();

            Trigger trigger = new Trigger() { Id = "1", Name = "Trigger1" };
  

            //Prepare mock data
            Mock<DataCreationResultDTO> resultMock = new Mock<DataCreationResultDTO>();
            if(expectedResult)
            {
                resultMock.Object.IsError = true;

            } else
            {
                resultMock.Object.IsError = false;

            }
        
            //Mock the service method
            triggerServiceMock.Setup(c => c.ValidateTrigger(trigger)).Returns(resultMock.Object);

            //Create Controller Instance
            TriggerConfigurationController triggerController = new TriggerConfigurationController(triggerServiceMock.Object, loggerManagerMock.Object);
            var result = triggerController.ValidateTrigger(trigger).Result as OkObjectResult;

            //assert
            var resultObject = result.Value as DataCreationResultDTO;
            resultObject.IsError.Should().Be(expectedResult);
           
        }

        [Theory(DisplayName = "Triggers config - BuildTriggerCondition")]
        [InlineData("some string")]
        [InlineData("")]

        public void BuildTriggerCondition(string expectedResult)
        {

            Mock<ITriggerConfigurationService> triggerServiceMock = new Mock<ITriggerConfigurationService>();
            Mock<ILoggerManager> loggerManagerMock = new Mock<ILoggerManager>();

            Trigger trigger = new Trigger() { Id = "1", Name = "Trigger1", parameters = new List<object>()};
            TriggerParameter param = new TriggerParameter()
            {
                DisplayName = "Ground Speed",
                Name = "GS",
                EditorFieldFormat = "none",
                EditorFieldType = "numeric",
                EditorFieldValue = "0",
                EditorFieldValues = null,
                EditorFieldValueUnit = "none",
                IATAList = null,
                ICAOList = null,
                Operator = "EQ",
                Operators = null
            };

            //Prepare mock data
            string resultMock = "";
            if (expectedResult.Equals(""))
            {
                trigger.parameters = null;
            }
            else
            {
                trigger.parameters.Add(param);
            }
            resultMock = trigger.parameters != null ? "some string" : "";

            //Mock the service method
            //triggerServiceMock.Setup(c => c.BuildTriggerCondition(trigger)).Returns(resultMock);

            ////Create Controller Instance
            //TriggerConfigurationController triggerController = new TriggerConfigurationController(triggerServiceMock.Object, loggerManagerMock.Object);

            //var result = triggerController.BuildTriggerCondition(trigger) as OkObjectResult;

            //assert
            //result.Value.Equals(expectedResult);

        }
    }
}
