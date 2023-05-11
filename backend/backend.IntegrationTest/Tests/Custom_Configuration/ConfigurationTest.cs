using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Subscription;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using FluentAssertions;
using Moq;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Xunit;
using System.Linq;
using HttpContextMoq.Extensions;
using Microsoft.AspNetCore.Http;
using System.Security.Principal;
using HttpContextMoq;
using backend.Controllers.Configurations;
using backend.BusinessLayer.Contracts.Configuration;
using backend.Logging.Contracts;
using Microsoft.AspNetCore.Mvc;

namespace backend.IntegrationTest.Tests.Custom_Configuration
{

    public class ConfigurationTest: IClassFixture<ApplicationFactory<Startup>>
    {
        private ApplicationFactory<Startup> _factory;

        public ConfigurationTest(ApplicationFactory<Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

        [Theory(DisplayName = "Global config - Update Autolock value")]
        [InlineData(1, 1)]
        [InlineData(0, 0)]
        public async Task UpdateAutoLockValue(int configId, int resultValue)
        {
            
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var globalRepo = new Mock<ConfigurationRepository>();
            List<ConfigurationSettings> configurationSettings = new List<ConfigurationSettings>();
            ConfigurationSettings configuration = new ConfigurationSettings();
            configuration.Name = "Auto Deplay";
            configuration.Value = true;
            configurationSettings.Add(configuration);

            globalRepo.Setup(c => c.UpdateConfigurationDefinitionSettings(configId, configurationSettings)).Returns(Task.FromResult(resultValue));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ConfigurationRepository).Returns(globalRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var myContent = JsonConvert.SerializeObject(configurationSettings);
            var buffer = System.Text.Encoding.UTF8.GetBytes(myContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            var response = await client.PostAsync("api/Configuration/" + configId + "/setting/update" , byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            result.IsError.Should().BeTrue();
        }

        [Theory(DisplayName = "Configuration - GetDefaultLockingComments")]
        [InlineData(2, 0)]
        [InlineData(1, 2)]
        public async Task GetDefaultLockingComments(int configurationId, int? expectedResult)
        {

            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var configurationrepoRepo = new Mock<ConfigurationRepository>();

            List<string> comments = new List<string>();
            comments.Add("comment1");
            comments.Add("comment2");
            IEnumerable<string> commentList;
            commentList = comments;

            IEnumerable<string> commentList1 = new List<string>();

            if (configurationId == 1)
                configurationrepoRepo.Setup(c => c.GetDefaultLockingComments(configurationId)).Returns(Task.FromResult(commentList));
            else if (configurationId == 0)
                configurationrepoRepo.Setup(c => c.GetDefaultLockingComments(configurationId)).Returns(Task.FromResult(commentList1));


            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ConfigurationRepository).Returns(configurationrepoRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Configuration/" + configurationId + "/lockingComments");
            var result = JsonConvert.DeserializeObject<List<string>>(await response.Content.ReadAsStringAsync());

        
            // Assert
            if (configurationId == 1)
                result.Count.Should().Be(expectedResult);
            else if (configurationId == 2)
                result.Should().BeNullOrEmpty();

        }

        [Theory(DisplayName = "Configuration - Update Release notes")]
        [InlineData(1, "1", "releaseNotes",1)]
        [InlineData(0, "1", "releaseNotes",0)]
        public async Task UpdateReleaseNotes(int configurationId, string version, string releaseNotes, int expectedResult)
        {
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var globalRepo = new Mock<ConfigurationRepository>();
            globalRepo.Setup(c => c.UpdateReleaseNotes(configurationId, version, releaseNotes)).Returns(Task.FromResult(expectedResult));
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ConfigurationRepository).Returns(globalRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            var httpContent = JsonConvert.SerializeObject(releaseNotes);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/Configuration/" + configurationId + "/update/"+version+ "/releaseNotes", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (expectedResult == 0)
                result.IsError.Should().BeTrue();
            else if (expectedResult == 1)
                result.IsError.Should().BeFalse();
        }

        [Theory(DisplayName = "Configuration - GetCollinsAdminItems")]
        [InlineData(2, 1)]
        [InlineData(0, 0)]
        public async Task GetCollinsAdminItems(int configurationId, int outputResult)
        {

            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var configurationrepoRepo = new Mock<ConfigurationRepository>();

            if (configurationId == 1)
                configurationrepoRepo.Setup(c => c.GetCollinsAdminItems(configurationId)).Returns(Task.FromResult("abc"));
            else if (configurationId == 0)
                configurationrepoRepo.Setup(c => c.GetCollinsAdminItems(configurationId)).Returns(Task.FromResult(""));


            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ConfigurationRepository).Returns(configurationrepoRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Configuration/" + configurationId + "/adminItems");
            var result = JsonConvert.DeserializeObject<List<string>>(await response.Content.ReadAsStringAsync());


            // Assert
            if (configurationId == 1)
                result.Should().NotBeNullOrEmpty();
            else if (configurationId == 0)
                result.Should().BeNullOrEmpty();

        }

        [Theory(DisplayName = "Configuration - GetDownloadDetails")]
        [InlineData(2, "populations", 1)]
        [InlineData(0, "populations", 0)]
        public async Task GetDownloadDetails(int configurationId, string pageName, int outputResult)
        {

            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var configurationrepoRepo = new Mock<ConfigurationRepository>();

            AdminOnlyDownloadDetails adminOnlyDownloadDetails = new AdminOnlyDownloadDetails();
            adminOnlyDownloadDetails.Revision = 3;
            adminOnlyDownloadDetails.Date = DateTime.Now;
            adminOnlyDownloadDetails.Author = "Abc";

            List<AdminOnlyDownloadDetails> lstAdminOnlyDownloadDetails = new List<AdminOnlyDownloadDetails>();
            lstAdminOnlyDownloadDetails.Add(adminOnlyDownloadDetails);

            List<AdminOnlyDownloadDetails> lstAdminOnlyDownloadDetails1 = new List<AdminOnlyDownloadDetails>();

            if (configurationId == 1)
                configurationrepoRepo.Setup(c => c.GetDownloadDetails(configurationId, pageName)).Returns(Task.FromResult(lstAdminOnlyDownloadDetails));
            else if (configurationId == 0)
                configurationrepoRepo.Setup(c => c.GetDownloadDetails(configurationId, pageName)).Returns(Task.FromResult(lstAdminOnlyDownloadDetails1));


            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ConfigurationRepository).Returns(configurationrepoRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Configuration/" + configurationId + "/downloaddetails/page/" + pageName);
            var result = JsonConvert.DeserializeObject<List<AdminOnlyDownloadDetails>>(await response.Content.ReadAsStringAsync());


            // Assert
            if (configurationId == 1)
                result.Should().NotBeNullOrEmpty();
            else if (configurationId == 0)
                result.Should().BeNullOrEmpty();

        }

       
        [Theory(DisplayName = "Configuration - GetAllDefnitions")]
        [InlineData(2, 3,1)]
        [InlineData(1, 0,0)]
        public async Task GetAllDefinitionsTest(int configurationId, int expectedResult, int configDefId)
        {

            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            var results = new List<ConfigurationDefinition>();
            IEnumerable<ConfigurationDefinition> paramss;
            var results1 = new List<ConfigurationDefinitionDTO>();
            results.Add(new ConfigurationDefinition
            {
                ConfigurationDefinitionID = configDefId
            });
            paramss = results;
            var configDefRepo = new Mock<ConfigurationDefinitionRepository>();
            configDefRepo.Setup(c => c.GetProductConfigurationDefinitions()).Returns(Task.FromResult(paramss));
            configDefRepo.Setup(c => c.GetPlatformConfigurationDefinitions()).Returns(Task.FromResult(paramss));
            configDefRepo.Setup(c => c.GetGlobalConfigurationDefinitions()).Returns(Task.FromResult(paramss));
            configDefRepo.Setup(c => c.GetGlobal(configDefId)).Returns(Task.FromResult(new Global()));
            configDefRepo.Setup(c => c.GetProduct(configDefId)).Returns(Task.FromResult(new Product()));
            configDefRepo.Setup(c => c.GetPlatform(configDefId)).Returns(Task.FromResult(new Platform()));
            SetUpMockRepo(configDefRepo, configurationId);

            //act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Configuration/definitions");
            var result = JsonConvert.DeserializeObject<List<ConfigurationDefinitionDTO>>(await response.Content.ReadAsStringAsync());

            //assert
            result.Count.Should().Be(expectedResult);
        }


      
        [Theory(DisplayName = "geting configuration based on userid")]
        [InlineData(1)]
        [InlineData(0)]
        public async Task GetConfigurationsByUserIdTest(int configurationId)
        {
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                var aircraftRepo = MockAircraftData(configurationId);
                UserListDTO user = new UserListDTO();
                IEnumerable<UserConfigurationDefinition> userdef;
                UserConfigurationDefinition userd = new UserConfigurationDefinition();
                userd.ConfigurationDefinitionID = 2;
                userd.ConfigurationDefinitionParentID = 1;
                userd.ConfigurationTypeID = 4;
                List<UserConfigurationDefinition> list = new List<UserConfigurationDefinition>();
                list.Add(userd);
                userdef = list;
                user.Id = Guid.Parse("4DBED025-B15F-4760-B925-34076D13A10A");
                user.UserName = "holcomb";
                var configdef = new Mock<ConfigurationDefinitionRepository>();
                if (configurationId == 1)
                {
                    configdef.Setup(c => c.GetConfigurationDefinitionsForUser(user.Id)).Returns(Task.FromResult(userdef));
                }
                else if (configurationId == 0)
                {
                    configdef.Setup(c => c.GetConfigurationDefinitionsForUser(user.Id)).Returns(Task.FromResult<IEnumerable<UserConfigurationDefinition>>(null));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configdef.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);


                //Act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/Configuration/definitions/all");
                var result = JsonConvert.DeserializeObject<IEnumerable<UserConfigurationDefinitionDTO>>(await response.Content.ReadAsStringAsync());
                // Assert
                if (configurationId == 1)
                    result.Should().NotBeNullOrEmpty();
                else if (configurationId == 0)
                    result.Should().BeNullOrEmpty();
        }

      

        [Theory(DisplayName = "geting all defnition version")]
        [InlineData(1, 1)]
        [InlineData(0,  2)]
        public async Task GetDefinitionVersionsTest(int configurationId,int definitionId)
        {

                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                var aircraftRepo = MockAircraftData(configurationId);
                List<ConfigurationName> list = new List<ConfigurationName>();
                ConfigurationName cn = new ConfigurationName();
                cn.ConfigurationDefinitionId = 2;
                cn.ConfigurationId = 108;
                list.Add(cn);
                var config = new Mock<ConfigurationRepository>();
                if (configurationId == 1)
                {
                    config.Setup(c => c.GetDefinitionVersions(definitionId)).Returns(Task.FromResult(list));
                }
                else if (configurationId == 0)
                {
                    config.Setup(c => c.GetDefinitionVersions(definitionId)).Returns(Task.FromResult<List<ConfigurationName>>(null));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.ConfigurationRepository).Returns(config.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                //Act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/Configuration/definition/" + definitionId + "/versions");
                var result = JsonConvert.DeserializeObject<IEnumerable<ConfigurationDefinitionVersionDTO>>(await response.Content.ReadAsStringAsync());
                // Assert
                if (configurationId == 1)
                    result.Should().NotBeNullOrEmpty();
                else if (configurationId == 0)
                    result.Should().BeNullOrEmpty();

        }

        [Theory(DisplayName = "geting all lockdefnition version")]
        [InlineData(1, 1)]
        [InlineData(0, 2)]
        public async Task GetLockDefinitionVersionsTest(int configurationId, int definitionId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            List<ConfigurationName> list = new List<ConfigurationName>();
            ConfigurationName cn = new ConfigurationName();
            cn.ConfigurationDefinitionId = 2;
            cn.ConfigurationId = 108;
            list.Add(cn);
            var config = new Mock<ConfigurationRepository>();
            if (configurationId == 1)
            {
                config.Setup(c => c.GetLockDefinitionVersions(definitionId)).Returns(Task.FromResult(list));
            }
            else if (configurationId == 0)
            {
                config.Setup(c => c.GetLockDefinitionVersions(definitionId)).Returns(Task.FromResult<List<ConfigurationName>>(null));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ConfigurationRepository).Returns(config.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
            //Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Configuration/definition/" + definitionId + "/lockedversions");
            var result = JsonConvert.DeserializeObject<IEnumerable<ConfigurationDefinitionVersionDTO>>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configurationId == 1)
                result.Should().NotBeNullOrEmpty();
            else if (configurationId == 0)
                result.Should().BeNullOrEmpty();
        }


        [Theory(DisplayName = "get configuration updates")]
        [InlineData(1)]
        [InlineData(0)]
        public async Task GetConfigurationUpdatesTest(int configurationId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            IEnumerable<ConfigurationFeature> feature;
            List<ConfigurationFeature> list = new List<ConfigurationFeature>();
            ConfigurationFeature feature1 = new ConfigurationFeature();
            feature1.Name = "new";
            feature1.Value = "02";
            list.Add(feature1);
            feature = list;
            var config = new Mock<ConfigurationRepository>();
            if (configurationId == 1)
            {
                config.Setup(c => c.GetFeatures(configurationId)).Returns(Task.FromResult(feature));
            }
            else if (configurationId == 0)
            {
                config.Setup(c => c.GetFeatures(configurationId)).Returns(Task.FromResult<IEnumerable<ConfigurationFeature>>(null));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ConfigurationRepository).Returns(config.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
            //Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Configuration/"+configurationId+"/updates");
            var result = JsonConvert.DeserializeObject<ConfigurationUpdatesDTO>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configurationId == 1)
                result.Should().NotBeNull();
            else if (configurationId == 0)
                result.Should().BeNull();
        }


        [Theory(DisplayName = "get configurationfeature Test")]
        [InlineData(1,1)]
        [InlineData(0,0)]
        public async Task GetConfigurationFeaturesTest(int configurationId, int expected)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configurationId);
            var aircraftRepo = MockAircraftData(configurationId);
            IEnumerable<ConfigurationFeature> feature;
            List<ConfigurationFeature> list = new List<ConfigurationFeature>();
            var config = new Mock<ConfigurationRepository>();
            if (configurationId == 1)
            {
                ConfigurationFeature feature1 = new ConfigurationFeature();
                feature1.Name = "new";
                feature1.Value = "02";
                list.Add(feature1);
                feature = list;
                config.Setup(c => c.GetFeatures(configurationId)).Returns(Task.FromResult(feature));
            }
            else if (configurationId == 0)
            {
                feature = null;
                config.Setup(c => c.GetFeatures(configurationId)).Returns(Task.FromResult<IEnumerable<ConfigurationFeature>>(feature));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.ConfigurationRepository).Returns(config.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
            //Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Configuration/" + configurationId + "/features");
            var result = JsonConvert.DeserializeObject<IEnumerable<ConfigurationFeature>>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configurationId == 1)
                result.Should().HaveCount(expected);
            else if (configurationId == 0)
                result.Should().BeNullOrEmpty();
        }


        [Theory(DisplayName = "get configurationfeature Test")]
        [InlineData(1, "collins-admin-items")]
        [InlineData(0, "")]
        public async Task GetConfigurationFeatureTest(int configurationId, string featureName)
        {
                // Arrange
                var userRepo = MockUserData();
                var aircraftRepo = MockAircraftData(configurationId);
                var config = new Mock<ConfigurationRepository>();
                if (configurationId == 1)
                {
                    ConfigurationFeature feature1 = new ConfigurationFeature();
                    feature1.Name = "collins-admin-items";
                    feature1.Value = "flight data, system config,briefings,timezone database";
                    config.Setup(c => c.GetFeature(configurationId, featureName)).Returns(Task.FromResult(feature1));
                }
                else if (configurationId == 0)
                {
                    ConfigurationFeature feature2 = new ConfigurationFeature();

                    config.Setup(c => c.GetFeature(configurationId, featureName)).Returns(Task.FromResult(feature2));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationRepository).Returns(config.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
                //Act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/Configuration/" + configurationId + "/feature/" + featureName);
                var apiContent = await response.Content.ReadAsStringAsync();
                var result = JsonConvert.DeserializeObject<ConfigurationFeature>(apiContent);
                // Assert
                if (configurationId == 1)
                    result.Name = "collins-admin-items";
                else if (configurationId == 0)
                    result.Should().BeNull();

        }
        [Theory(DisplayName = "create inset configuration Maping")]
        [InlineData(1, 1)]
        [InlineData(2, 0)]
        public async Task CreateInsetConfigurationMapping(int configurationId, int expectedResult)
        {
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                var aircraftRepo = MockAircraftData(configurationId);
                var config = new Mock<ConfigurationRepository>();
                if (configurationId == 1)
                {
                    config.Setup(c => c.CreateInsetConfigurationMapping(configurationId)).Returns(Task.FromResult(expectedResult));
                }
                else if (configurationId == 2)
                {
                    config.Setup(c => c.CreateInsetConfigurationMapping(configurationId)).Returns(Task.FromResult(expectedResult));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.ConfigurationRepository).Returns(config.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
                //Act
                var client = _factory.CreateAdmin();
                var response = await client.PostAsync("api/Configuration/" + configurationId + "/updateInset",null);
                var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
                // Assert
                if (configurationId == 1)
                    result.Message.Should().Be("Inset Configuration Mapping has been created");
                else if (configurationId == 0)
                    result.Message.Should().Be("Error creating Inset Configuration Mapping");
        }



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

        private Moq.Mock<SimpleRepository<User>> GetMockUserRepo()
        {
            var userRepo = new Moq.Mock<SimpleRepository<User>>();
            userRepo.Setup(c => c.FirstAsync("UserName", "katherine.holcomb")).Returns(Task.FromResult(new User()));
            userRepo.Setup(c => c.FirstAsync("UserName", "aehageme")).Returns(Task.FromResult(new User()));
            return userRepo;
        }
        private void SetUpMockRepo(Moq.Mock<ConfigurationDefinitionRepository> scriptRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(scriptRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
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
