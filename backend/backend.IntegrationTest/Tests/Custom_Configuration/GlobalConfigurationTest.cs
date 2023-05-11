using Ace.DataLayer.Models;
using AutoMapper;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
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
    public class GlobalConfigurationTest:
        IClassFixture<ApplicationFactory<Startup>>
    {
        private ApplicationFactory<Startup> _factory;
        public GlobalConfigurationTest(ApplicationFactory<Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

        #region Test methods

        [Theory(DisplayName = "Global config - Get fonts")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetLayers(int configurationId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            IEnumerable<FontFile> fonts;
            List<FontFile> fontFilesList = new List<FontFile>();
            FontFile fontFile = new FontFile();
            fontFile.Description = "Roboto";
            fontFile.FontFileID = 1;
            fontFile.IsSelected = 1;
            fontFile.Name = "Roboto";
            fontFilesList.Add(fontFile);
            fonts = fontFilesList;

            var mapsRepo = new Mock<GlobalConfigurationRepository>();
            if (configurationId == 18)
                mapsRepo.Setup(m => m.GetFonts(configurationId)).Returns(Task.FromResult(fonts));
            else if (configurationId == 0)
                mapsRepo.Setup(m => m.GetFonts(configurationId)).Returns(Task.FromResult<IEnumerable<FontFile>>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(m => m.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(m => m.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(m => m.GlobalConfigurationRepository).Returns(mapsRepo.Object);
            mockRepos.Setup(m => m.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
            
            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/GlobalConfiguration/" + configurationId + "/fonts");
            var result = JsonConvert.DeserializeObject<List<FontFileDTO>>(await response.Content.ReadAsStringAsync());

            // Assert
            result.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Global config - Set Font File Seleted For Configuration")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task SetFontFileSeletedForConfiguration(int configurationId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);

            FontFileSelection fontFileSelection = new FontFileSelection();
            fontFileSelection.FontFileID = 1;
            fontFileSelection.FontFileSelectionID = 1;

            FontConfigurationMapping fontConfiguration = new FontConfigurationMapping();
            fontConfiguration.FontFileSelectionID = 1;
            fontConfiguration.IsDeleted = false;
            fontConfiguration.PreviousFontFileSelectionID = 2;

            List<FontConfigurationMapping> mappings = new List<FontConfigurationMapping>();
            mappings.Add(fontConfiguration);

            var fontRepo = new Mock<FontConfigurationMappingRepository>();
            fontRepo.Setup(m => m.GetFontSelectionMappingCountForConfiguration(configurationId)).Returns(Task.FromResult(inputResult));
            if (configurationId == 18)
            {
                fontRepo.Setup(m => m.GetFontSelectionIdForFont(configurationId)).Returns(Task.FromResult(fontFileSelection));
                fontRepo.Setup(f => f.FilterAsync("configurationId", configurationId)).Returns(Task.FromResult(mappings));
                fontRepo.Setup(m => m.UpdateAsync(fontConfiguration)).Returns(Task.FromResult(inputResult));
                fontRepo.Setup(m => m.InsertAsync(fontConfiguration)).Returns(Task.FromResult(inputResult));
            }
            else if (configurationId == 0)
            {
                fontRepo.Setup(m => m.GetFontSelectionIdForFont(configurationId)).Returns(Task.FromResult<FontFileSelection>(null));
                mappings = null;
                fontRepo.Setup(f => f.FilterAsync("configurationId", configurationId)).Returns(Task.FromResult(mappings));
                fontConfiguration = null;
                fontRepo.Setup(m => m.UpdateAsync(fontConfiguration)).Returns(Task.FromResult(inputResult));
                fontRepo.Setup(m => m.InsertAsync(fontConfiguration)).Returns(Task.FromResult(inputResult));
            }
                
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(m => m.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(m => m.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(m => m.FontConfigurationMappingRepository).Returns(fontRepo.Object);
            mockRepos.Setup(m => m.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            UserListDTO userList = new UserListDTO();
            userList.Id = new Guid();
            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(userList);
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = await client.PostAsync("api/GlobalConfiguration/" + configurationId + "/fonts/select/1", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Global config - Get configuration languages")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetConfigurationLanguages(int configurationId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            IEnumerable<Language> languages;
            List<Language> languageList = new List<Language>();
            Language language = new Language();
            language.Description = "English";
            language.LanguageID = 1;
            language.ID = 1;
            language.Name = "English";
            languageList.Add(language);
            languages = languageList;

            var mapsRepo = new Mock<GlobalConfigurationRepository>();
            if (configurationId == 18)
                mapsRepo.Setup(m => m.GetAllLanguages()).Returns(Task.FromResult(languages));
            else if (configurationId == 0)
                mapsRepo.Setup(m => m.GetAllLanguages()).Returns(Task.FromResult<IEnumerable<Language>>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(m => m.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(m => m.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(m => m.GlobalConfigurationRepository).Returns(mapsRepo.Object);
            mockRepos.Setup(m => m.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/GlobalConfiguration/" + configurationId + "/languages");
            var result = JsonConvert.DeserializeObject<List<Language>>(await response.Content.ReadAsStringAsync());

            // Assert
            result.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Global config - Get configuration languages")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        public async Task GetSelectedLanguages(int configurationId, int inputResult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            IEnumerable<SelectedLanguage> languages;
            List<SelectedLanguage> languageList = new List<SelectedLanguage>();
            SelectedLanguage language = new SelectedLanguage();
            language.Name = "English";
            language.IsDefault = true;
            languageList.Add(language);
            languages = languageList;

            var mapsRepo = new Mock<GlobalConfigurationRepository>();
            if (configurationId == 18)
                mapsRepo.Setup(m => m.GetSelectedLanguages(configurationId)).Returns(Task.FromResult(languages));
            else if (configurationId == 0)
                mapsRepo.Setup(m => m.GetSelectedLanguages(configurationId)).Returns(Task.FromResult<IEnumerable<SelectedLanguage>>(null));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(m => m.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(m => m.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(m => m.GlobalConfigurationRepository).Returns(mapsRepo.Object);
            mockRepos.Setup(m => m.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/GlobalConfiguration/" + configurationId + "/languages/selected");
            var result = JsonConvert.DeserializeObject<List<SelectedLanguageDTO>>(await response.Content.ReadAsStringAsync());

            // Assert
            result.Count.Should().Be(inputResult);
        }

        [Theory(DisplayName = "Global config - Add configuration languages")]
        [InlineData(18, new string[] { "English, German, Spanish" }, 1)]
        [InlineData(0, new string[] { "English, German, Spanish" }, 0)]
        public async Task AddLanguages(int configId, string[] languageList, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var globalRepo = new Mock<GlobalConfigurationRepository>();
            List<string> languages = languageList[0].Split(",").ToList();
            globalRepo.Setup(c => c.AddLanguages(configId, languages)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.GlobalConfigurationRepository).Returns(globalRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(languages);
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = await client.PostAsync("api/GlobalConfiguration/" + configId + "/languages/selected/add", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (resultValue == 1)
                result.IsError.Should().BeFalse();
            else if (resultValue == 0)
                result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Global config - Add configuration languages")]
        [InlineData(18, "1", 1)]
        [InlineData(0, "0", 0)]
        public async Task RemoveLanguage(int configId, string language, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var globalRepo = new Mock<GlobalConfigurationRepository>();
            globalRepo.Setup(c => c.RemoveLanguage(configId, language)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.GlobalConfigurationRepository).Returns(globalRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/GlobalConfiguration/" + configId + "/languages/selected/remove/" + language, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (resultValue == 1)
                result.IsError.Should().BeFalse();
            else if (resultValue == 0)
                result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Global config - Move Language Code To Position ")]
        [InlineData(18, "1", 1, 1)]
        [InlineData(0, "0", 2, 0)]
        public async Task MoveLanguageCodeToPosition(int configId, string language, int position, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var globalRepo = new Mock<GlobalConfigurationRepository>();
            globalRepo.Setup(c => c.MoveLanguageCodeToPosition(configId, language, position)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.GlobalConfigurationRepository).Returns(globalRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/GlobalConfiguration/" + configId + "/languages/selected/ " + language + "/moveto/" + position, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());


            result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Global config - Move Language Code To Position ")]
        [InlineData(18, "1", "English", "true", 1)]
        [InlineData(0, "0", "English", "true", 0)]
        public async Task UpdateLanguagesSetting(int configId, string language, string name, string value, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var globalRepo = new Mock<GlobalConfigurationRepository>();
            globalRepo.Setup(c => c.UpdateLanguagesSetting(configId, language, name, value)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.GlobalConfigurationRepository).Returns(globalRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/GlobalConfiguration/" + configId + "/languages/selected/ " + language + "/set/" + name + "/to/" + value, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Global config - Set default Language ")]
        [InlineData(18, "1", 1)]
        [InlineData(0, "0", 0)]
        public async Task SetLanguageAsDefault(int configId, string language, int resultValue)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var globalRepo = new Mock<GlobalConfigurationRepository>();
            globalRepo.Setup(c => c.SetLanguageAsDefault(configId, language)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.GlobalConfigurationRepository).Returns(globalRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/GlobalConfiguration/" + configId + "/languages/selected/ " + language + "/default", null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            result.IsError.Should().BeTrue();
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
