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

namespace backend.IntegrationTest.Tests.Custom_Configuration
{
    [Collection("sequential")]
    public class ScriptConfigurationTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public ScriptConfigurationTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

        #region Mock Dependant Repos

        private Moq.Mock<SimpleRepository<User>> GetMockUserRepo()
        {
            var userRepo = new Moq.Mock<SimpleRepository<User>>();
            userRepo.Setup(c => c.FirstAsync("UserName", "katherine.holcomb")).Returns(Task.FromResult(new User()));
            userRepo.Setup(c => c.FirstAsync("UserName", "aehageme")).Returns(Task.FromResult(new User()));
            return userRepo;
        }

        //private Moq.Mock<ConfigurationDefinitionRepository> GetMockConfigRepo()
        //{
        //    var userRepo = new Moq.Mock<ConfigurationDefinitionRepository>();
        //    IEnumerable<ConfigurationDefinitionDetails> configurationDefinitionDetails;
        //    List<ConfigurationDefinitionDetails> configurationDefinitions = new List<ConfigurationDefinitionDetails>();
        //    configurationDefinitionDetails = configurationDefinitions;
        //    userRepo.Setup(c => c.GetConfigurationInfoByConfigurationId(1)).Returns(Task.FromResult(configurationDefinitionDetails));
        //    return userRepo;
        //}

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



        private void SetUpMockRepo(Moq.Mock<ScriptConfigurationRepository> scriptRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.ScriptConfigurationRepository).Returns(scriptRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }

        #endregion

        [Theory(DisplayName = "Script config - Getscrpts")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetScripts(int configId, int expectedResult)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetScripts(18)).Returns(Task.FromResult(new List<ScriptConfiguration>() { new ScriptConfiguration() { ScriptId = 1, ScriptName = "testScript" } }));
            scriptRepo.Setup(c => c.GetScripts(0)).Returns(Task.FromResult(new List<ScriptConfiguration>()));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId);
            var result = JsonConvert.DeserializeObject<List<ScriptConfiguration>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Script config - RemoveScript")]
        [InlineData(18, 1, false)]
        [InlineData(18, 0, true)]
        [InlineData(0, 1, true)]
        [InlineData(0, 0, true)]
        public async Task RemoveScript(int configId, int scriptId, bool expected)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.RemoveScript(18, 1)).Returns(Task.FromResult(1));
            scriptRepo.Setup(c => c.RemoveScript(18, 0)).Returns(Task.FromResult(0));
            scriptRepo.Setup(c => c.RemoveScript(0, 1)).Returns(Task.FromResult(0));
            scriptRepo.Setup(c => c.RemoveScript(0, 0)).Returns(Task.FromResult(0));

            SetUpMockRepo(scriptRepo, configId);

            //var name= System.Reflection.MethodBase.GetCurrentMethod().Name;

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ScriptConfiguration/scripts/" + configId + "/remove/" + scriptId, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expected);
        }

        [Theory(DisplayName = "Script config - getlanguages")]
        [InlineData(18, 1, 2)]
        [InlineData(18, 2, 1)]
        [InlineData(18, 0, 0)]
        public async Task GetForcedLanguages(int configId, int scriptId, int expectedResult)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetForcedLanguages(18, 1)).Returns(Task.FromResult(new List<ScriptForcedLanguage>() { new ScriptForcedLanguage() { LanguageName = "English", LanguageCode = "en", IsDefault = true, isSelected = true },new ScriptForcedLanguage() {
            LanguageName = "French", LanguageCode = "fr", IsDefault = false, isSelected = false} }));
            scriptRepo.Setup(c => c.GetForcedLanguages(18, 2)).Returns(Task.FromResult(new List<ScriptForcedLanguage>() { new ScriptForcedLanguage() { LanguageName = "English", LanguageCode = "en", IsDefault = true, isSelected = true } }));
            scriptRepo.Setup(c => c.GetForcedLanguages(18, 0)).Returns(Task.FromResult(new List<ScriptForcedLanguage>()));

            SetUpMockRepo(scriptRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/getlanguages/" + scriptId);
            var result = JsonConvert.DeserializeObject<List<ScriptForcedLanguage>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Script config - setlanguages")]
        [InlineData(18, 1, "en,fr", false)]
        [InlineData(18, 1, "fr", false)]
        [InlineData(18, 0, "en,fr", true)]
        [InlineData(0, 1, "en,fr", true)]
        [InlineData(0, 0, "en,fr", true)]
        public async Task SetForcedLanguage(int configId, int scriptId, string languageCodes, bool expected)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.SetForcedLanguage(18, 1, "en,fr")).Returns(Task.FromResult(1));
            scriptRepo.Setup(c => c.SetForcedLanguage(18, 1, "fr")).Returns(Task.FromResult(1));
            scriptRepo.Setup(c => c.SetForcedLanguage(18, 0, "en")).Returns(Task.FromResult(0));
            scriptRepo.Setup(c => c.SetForcedLanguage(0, 1, "")).Returns(Task.FromResult(0));
            scriptRepo.Setup(c => c.SetForcedLanguage(0, 0, "")).Returns(Task.FromResult(0));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ScriptConfiguration/scripts/" + configId + "/setlanguages/" + scriptId + "/" + languageCodes, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expected);
        }

        [Theory(DisplayName = "Script config - getscriptitems")]
        [InlineData(18, 2, 2)]
        //[InlineData(18, 2, 1)]
        [InlineData(18, 0, 0)]
        public async Task GetScriptItemsByScript(int configId, int scriptId, int expectedResult)
        {


            List<ScriptItemDisplay> scriptItemDisplays = new List<ScriptItemDisplay>();
            scriptItemDisplays.Add(new ScriptItemDisplay());
            scriptItemDisplays.Add(new ScriptItemDisplay());

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetScriptItemsByScript(2, 18)).Returns(Task.FromResult(scriptItemDisplays));

            //scriptRepo.Setup(c => c.GetScriptItemsByScript(2, 18)).Returns(Task.FromResult(scriptItemDisplays));

            scriptRepo.Setup(c => c.GetScriptItemsByScript(0, 18)).Returns(Task.FromResult(new List<ScriptItemDisplay>()));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/getscriptitems/" + scriptId);
            var result = JsonConvert.DeserializeObject<List<ScriptItemDisplay>>(await response.Content.ReadAsStringAsync());

            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Script config - addscript")]
        [InlineData(18, "testScript", false)]
        [InlineData(0, "testScript", true)]
        public async Task InsertScript(int configId, string scriptName, bool expected)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.SaveScript(18, "testScript",1)).Returns(Task.FromResult(1));
            scriptRepo.Setup(c => c.SaveScript(0, "testScript",1)).Returns(Task.FromResult(0));
            scriptRepo.Setup(c => c.SaveScript(18, "",1)).Returns(Task.FromResult(0));
            scriptRepo.Setup(c => c.SaveScript(0, "",1)).Returns(Task.FromResult(0));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ScriptConfiguration/scripts/" + configId + "/addscript/" + scriptName+"/"+1, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expected);
        }

        [Theory(DisplayName = "Script config - getscriptItemdetails")]
        [InlineData(18, 1, 0, "itemType1")]
        [InlineData(18, 1, 1, "itemType1")]
        [InlineData(18, 0, 1, null)]
        public async Task GetScriptItemDetails(int configId, int scriptId, int index, string expeced)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetScriptItemDetails(1, 0, 18)).Returns(Task.FromResult(new ScriptItem() { ItemType = "itemType1" }));
            scriptRepo.Setup(c => c.GetScriptItemDetails(1, 1, 18)).Returns(Task.FromResult(new ScriptItem() { ItemType = "itemType1" }));
            scriptRepo.Setup(c => c.GetScriptItemDetails(0, 0, 18)).Returns(Task.FromResult(new ScriptItem()));
            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/getscriptItemdetails/" + scriptId + "/" + index);
            var result = JsonConvert.DeserializeObject<ScriptItem>(await response.Content.ReadAsStringAsync());
            if (expeced == null)
                result.Should().BeNull();
            else
                result.ItemType.Should().Be(expeced);
        }

        [Theory(DisplayName = "Script config - removeitem")]
        [InlineData(18, 1, 0, false)]
        [InlineData(18, 1, -1, true)]
        [InlineData(18, 0, 0, true)]
        public async Task RemoveScriptItem(int configId, int scriptId, int index, bool expected)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.RemoveScriptItem(0, 1, 18)).Returns(Task.FromResult(1));
            scriptRepo.Setup(c => c.RemoveScriptItem(-1, 1, 18)).Returns(Task.FromResult(0));
            scriptRepo.Setup(c => c.RemoveScriptItem(0, 0, 18)).Returns(Task.FromResult(0));

            SetUpMockRepo(scriptRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ScriptConfiguration/scripts/" + configId + "/removeitem/" + scriptId + "/" + index, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expected);
        }

        [Theory(DisplayName = "Script config - saveitem")]
        [InlineData(18, "testScript")]
        [InlineData(1, "testScript")]
        public async Task SaveScriptItem(int configId, string scriptId)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            ScriptItem scriptItem = new ScriptItem();
            scriptRepo.Setup(c => c.SaveScriptItem(scriptItem, 18, 1)).Returns(Task.FromResult(new ScriptItemCreationResult() { Result = 1, Id = "0" }));
            scriptRepo.Setup(c => c.SaveScriptItem(scriptItem, 18, 1)).Returns(Task.FromResult(new ScriptItemCreationResult() { Result = 1, Id = "0" }));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ScriptConfiguration/scripts/" + configId + "/saveitem/" + scriptId, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().BeFalse();
        }

        [Theory(DisplayName = "Script config - getitems")]
        [InlineData(18, 2)]
        [InlineData(1, 0)]
        public async Task GetScriptItemTypes(int configId, int expectedResult)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetScriptItemTypes(18)).Returns(Task.FromResult(new List<ScriptItemType>() { new ScriptItemType() { DisplayName="test",Name="test"} }));
            scriptRepo.Setup(c => c.GetScriptItemTypes(1)).Returns(Task.FromResult(new List<ScriptItemType>()));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/getitems");
            var result = JsonConvert.DeserializeObject<List<ScriptItemType>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Script config - triggers")]
        [InlineData(18, 2)]
        [InlineData(1, 2)]

        public async Task GetTriggers(int configId, int expectedResult)
        {

            List<Trigger> lstTriger = new List<Trigger>();
            lstTriger.Add(new Trigger());
            lstTriger.Add(new Trigger());
            IEnumerable<Trigger> triggers = lstTriger;
            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetTriggers(18)).Returns(Task.FromResult(triggers));

            scriptRepo.Setup(c => c.GetTriggers(1)).Returns(Task.FromResult(triggers));


            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/triggers");
            var result = JsonConvert.DeserializeObject<List<Trigger>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Script config - overridelanguages")]
        [InlineData(18, 2)]
        [InlineData(1, 0)]

        public async Task GetLanguagesOverride(int configId, int expectedResult)
        {
            List<ScriptForcedLanguage> scriptForcedLanguages = new List<ScriptForcedLanguage>();
            scriptForcedLanguages.Add(new ScriptForcedLanguage());
            scriptForcedLanguages.Add(new ScriptForcedLanguage());
            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetLanguagesOverride(18)).Returns(Task.FromResult(scriptForcedLanguages));
            scriptRepo.Setup(c => c.GetLanguagesOverride(1)).Returns(Task.FromResult(new List<ScriptForcedLanguage>()));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/overridelanguages");
            var result = JsonConvert.DeserializeObject<List<ScriptForcedLanguage>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Script config - flightinfo")]
        [InlineData(18, 2, 1, 2)]
        [InlineData(1, 2, 1, 0)]

        public async Task GetFlightInfoView(int configId, int scriptId, int index, int expectedResult)
        {
            List<ScriptConfigFlightInfo> scriptConfigFlightInfos = new List<ScriptConfigFlightInfo>();
            scriptConfigFlightInfos.Add(new ScriptConfigFlightInfo());
            scriptConfigFlightInfos.Add(new ScriptConfigFlightInfo());
            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetFlightInfoView(18, 2, 1)).Returns(Task.FromResult(scriptConfigFlightInfos));
            scriptRepo.Setup(c => c.GetFlightInfoView(1, 2, 1)).Returns(Task.FromResult(new List<ScriptConfigFlightInfo>()));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/flightinfo/" + scriptId + "/" + index);
            var result = JsonConvert.DeserializeObject<List<ScriptConfigFlightInfo>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Script config - params")]
        [InlineData(18, 2, 1, 2)]
        [InlineData(1, 2, 1, 0)]
        public async Task GetFlightInfoViewParameters(int configId, int scriptId, int index, int expectedResult)
        {
            List<ScriptConfigFlightInfoParams> scriptConfigFlightInfoParams = new List<ScriptConfigFlightInfoParams>();
            scriptConfigFlightInfoParams.Add(new ScriptConfigFlightInfoParams());
            scriptConfigFlightInfoParams.Add(new ScriptConfigFlightInfoParams());

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetFlightInfoViewParameters(18, 2, 1,"")).Returns(Task.FromResult(scriptConfigFlightInfoParams));
            scriptRepo.Setup(c => c.GetFlightInfoViewParameters(1, 2, 1,"")).Returns(Task.FromResult(new List<ScriptConfigFlightInfoParams>()));

            SetUpMockRepo(scriptRepo, configId);
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/flightinfo/params/" + scriptId + "/" + index);
            var result = JsonConvert.DeserializeObject<List<ScriptConfigFlightInfoParams>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Script config - availableparams")]
        [InlineData(18, 2, 1, 2)]
        [InlineData(1, 2, 1, 0)]

        public async Task GetAvailableInfoParameters(int configId, int scriptId, int index, int expectedResult)
        {

            List<ScriptConfigFlightInfoParams> scriptConfigFlightInfoParams = new List<ScriptConfigFlightInfoParams>();
            scriptConfigFlightInfoParams.Add(new ScriptConfigFlightInfoParams());
            scriptConfigFlightInfoParams.Add(new ScriptConfigFlightInfoParams());

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.GetAvailableInfoParameters(18, 2, 1,"")).Returns(Task.FromResult(scriptConfigFlightInfoParams));
            scriptRepo.Setup(c => c.GetAvailableInfoParameters(1, 2, 1,"")).Returns(Task.FromResult(new List<ScriptConfigFlightInfoParams>()));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/flightinfo/availableparams/" + scriptId + "/" + index);
            var result = JsonConvert.DeserializeObject<List<ScriptConfigFlightInfoParams>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }

        [Theory(DisplayName = "Script config - addparams")]
        [InlineData(18, 2, 1, "testView", "param1", 1)]
        public async Task FlightInfoViewUpdateParameters(int configId, int scriptId, int index, string viewName, string selectedParams, int expectedResult)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.FlightInfoViewUpdateParameters(18, 2, 1, "testView", "param1")).Returns(Task.FromResult(1));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ScriptConfiguration/scripts/" + configId + "/flightinfo/addparams/" + scriptId + "/" + index + "/" + viewName + "/" + selectedParams, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().BeFalse();
        }

        [Theory(DisplayName = "Script config - addview")]
        [InlineData(18, "testView", 2)]
        public async Task FlightInfoAddView(int configId, string viewName, int expectedResult)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.FlightInfoAddView(18, "testView")).Returns(Task.FromResult(1));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/ScriptConfiguration/scripts/" + configId + "/flightinfo/addview/" + viewName);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().BeFalse();
        }

        [Theory(DisplayName = "Script config - setView")]
        [InlineData(18, 2, 1, "testView", 2)]
        public async Task SetFlightInfoViewForItem(int configId, int scriptId, int index, string viewName, int expectedResult)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();
            scriptRepo.Setup(c => c.SetFlightInfoViewForItem(18, 2, 1, "testView")).Returns(Task.FromResult(1));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ScriptConfiguration/scripts/" + configId + "/flightinfo/setView/" + scriptId + "/" + index + "/" + viewName, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().BeFalse();
        }

        [Theory(DisplayName = "Script config - moveitemposition")]
        [InlineData(18, 2, 0, 1, 2)]
        [InlineData(1, 2, 1, 0, 2)]
        public async Task MoveItemToPosition(int configId, int scriptId, int currentPostion, int toPosition, int expectedResult)
        {

            var scriptRepo = new Moq.Mock<ScriptConfigurationRepository>();

            List<ScriptItemDisplay> scriptItemDisplays = new List<ScriptItemDisplay>();
            scriptItemDisplays.Add(new ScriptItemDisplay());
            scriptItemDisplays.Add(new ScriptItemDisplay());
            scriptRepo.Setup(c => c.MoveItemToPosition(18, 2, 0, 1)).Returns(Task.FromResult(scriptItemDisplays));
            scriptRepo.Setup(c => c.MoveItemToPosition(1, 2, 1, 0)).Returns(Task.FromResult(scriptItemDisplays));

            SetUpMockRepo(scriptRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/ScriptConfiguration/scripts/" + configId + "/script/moveitemposition/" + scriptId + "/" + currentPostion + "/" + toPosition, null);
            var result = JsonConvert.DeserializeObject<List<ScriptItemDisplay>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }
    }
}
