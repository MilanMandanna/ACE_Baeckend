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
using backend.DataLayer.Models.MergeConfiguration;

namespace backend.IntegrationTest.Tests.Custom_Configuration
{

    [Collection("sequential")]
    public class MergeConfigurationTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public MergeConfigurationTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

        

        [Theory(DisplayName = "get Mergeconfigupdatesavailable")]
        [InlineData(18, 2)]
        [InlineData(19, 1)]
        public async Task GetMergeConfigurationUpdateavailableTest(int configId, int definitionId)
        {

            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var Mergerepo = new Mock<MergeConfigurationRepository>();
            MergeConfigurationAvailable mergeavl = new MergeConfigurationAvailable();
            if (configId == 18)
            {
                mergeavl.IsUpdatesAvailable = true;
                Mergerepo.Setup(c => c.CheckUpdatesAvailable(definitionId,configId)).Returns(Task.FromResult(mergeavl));

            }
            else if (configId == 19)
            {
                mergeavl.IsUpdatesAvailable = false;
                Mergerepo.Setup(c => c.CheckUpdatesAvailable(definitionId, configId)).Returns(Task.FromResult(mergeavl));
            }
            else if (configId == 0)
            {
                
                Mergerepo.Setup(c => c.CheckUpdatesAvailable(definitionId, configId)).Returns(Task.FromResult<MergeConfigurationAvailable>(null));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.MergeConfigurationRepository).Returns(Mergerepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/MergeConfiguration/"+definitionId+"/"+configId+"/updatesavailable");
            var result = JsonConvert.DeserializeObject<MergeConfigurationAvailable>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.IsUpdatesAvailable = true;
            else if (configId == 19)
                result.IsUpdatesAvailable = false;
            else if (configId == 0)
                result.IsUpdatesAvailable = false;
            
        }


        [Theory(DisplayName = "get MergeConfigurtionupdatesdetails")]
        [InlineData(18, 3)]
        [InlineData(19, 2)]
        [InlineData(0, 1)]
        public async Task GetMergeConfigurationUpdateDetailsTest(int configId, int definitionId)
        {

            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var Mergerepo = new Mock<MergeConfigurationRepository>();
            
            if (configId == 18)
            {
                MergeConfigurationUpdateDetails mergeavl = new MergeConfigurationUpdateDetails();
                mergeavl.ConfigurationId = 18;
                mergeavl.ReleaseNotes = "new";
                mergeavl.VersionDate = "01/01/22";
                mergeavl.VersionNumber = 12343;
                List<MergeConfigurationUpdateDetails> list = new List<MergeConfigurationUpdateDetails>();
                list.Add(mergeavl);
                Mergerepo.Setup(c => c.GetMergeConfigurationUpdateDetails(definitionId)).Returns(Task.FromResult(list));

            }
            else if (configId == 19)
            {
                MergeConfigurationUpdateDetails mergeavl = new MergeConfigurationUpdateDetails();
                List<MergeConfigurationUpdateDetails> list = new List<MergeConfigurationUpdateDetails>();
                
                Mergerepo.Setup(c => c.GetMergeConfigurationUpdateDetails(definitionId)).Returns(Task.FromResult(list));
            }
            else if (configId == 0)
            {

                Mergerepo.Setup(c => c.GetMergeConfigurationUpdateDetails(definitionId)).Returns(Task.FromResult<List<MergeConfigurationUpdateDetails>>(null));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.MergeConfigurationRepository).Returns(Mergerepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/MergeConfiguration/" + definitionId);
            var result = JsonConvert.DeserializeObject<List<MergeConfigurationUpdateDetails>>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Count.Should().Be(1);
            else if (configId == 19)
                result.Count.Should().Be(0);
            else if (configId == 0)
                result.Should().BeNullOrEmpty();
        }



        [Theory(DisplayName = "get TaskData")]
        [InlineData("18", 3)]
        [InlineData("19", 2)]
        [InlineData("0", 1)]
        public async Task GetMergeConfigurationTaskDataTest(string configurationId, int definitionId)
        {
            try
            {
                // Arrange
                var configId = int.Parse(configurationId);
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configId);
                var aircraftRepo = MockAircraftData(configId);
                var Mergerepo = new Mock<MergeConfigurationRepository>();
                MergeTaskInfo info = new MergeTaskInfo();
                info.TaskId = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                info.TasKName = "new Task";
                info.TaskStatus = 0;
                List<MergeTaskInfo> list = new List<MergeTaskInfo>();
                list.Add(info);
                if (configId == 18)
                {
                    
                    Mergerepo.Setup(c => c.GetMergeConfigurationTaskData(configId)).Returns(Task.FromResult(list));
                }
                else if (configId == 19)
                {
                    List<MergeTaskInfo> list1 = new List<MergeTaskInfo>();
                    Mergerepo.Setup(c => c.GetMergeConfigurationTaskData(configId)).Returns(Task.FromResult(list1));
                }
                else if (configId == 0)
                {
                    Mergerepo.Setup(c => c.GetMergeConfigurationTaskData(configId)).Returns(Task.FromResult<List<MergeTaskInfo>>(null));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.MergeConfigurationRepository).Returns(Mergerepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                // Act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/MergeConfiguration/" + configId + "/TaskData");
                var result = JsonConvert.DeserializeObject<List<MergeTaskInfo>>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configId == 18)
                    result.Count.Should().Be(1);
                else if (configId == 19)
                    result.Count.Should().Be(0);
                else if (configId == 0)
                    result.Should().BeNullOrEmpty();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        [Theory(DisplayName = "get MergeconflictDataTest")]
        [InlineData(18, "C56A4180-65AA-42EC-A945-5FD21DEC0999")]
        [InlineData(19, "C56A4180-65AA-42EC-A945-5FD21DEC0999")]
        [InlineData(0, "C56A4180-65AA-42EC-A945-5FD21DEC0999")]
        public async Task GetMergeConflictDataTest(int configId, Guid taskid)
        {
            try
            {
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configId);
                var aircraftRepo = MockAircraftData(configId);
                MergeConflictDetails details = new MergeConflictDetails();
                details.ChildValue =" 1";
                details.ContentID = 2;
                details.Description = "new";
                List<MergeConflictDetails> conflictDetails = new List<MergeConflictDetails>();
                var Mergerepo = new Mock<MergeConfigurationRepository>();
                if (configId == 18)
                {
                    conflictDetails.Add(details);
                    Mergerepo.Setup(c => c.GetMergeConflictData(taskid)).Returns(Task.FromResult(conflictDetails));
                }
                else if (configId == 19)
                {
                    Mergerepo.Setup(c => c.GetMergeConflictData(taskid)).Returns(Task.FromResult(conflictDetails));
                }
                else if (configId == 0)
                {
                    Mergerepo.Setup(c => c.GetMergeConflictData(taskid)).Returns(Task.FromResult <List<MergeConflictDetails>>(null));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.MergeConfigurationRepository).Returns(Mergerepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                // Act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/MergeConfiguration/" + configId + "/"+taskid+ "/GetMergeConficts");
                var apicontent = await response.Content.ReadAsStringAsync();
                var result = JsonConvert.DeserializeObject<List<MergeConflictDetails>>(apicontent);

                // Assert
                if (configId == 18)
                    result.Count.Should().Be(1);
                else if (configId == 19)
                    result.Should().Should().Be(0);
                else if (configId == 0)
                    result.Should().BeNullOrEmpty();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        [Theory(DisplayName = "get Update MergeConflict Selection")]
        [InlineData(18, "C56A4180-65AA-42EC-A945-5FD21DEC0999","ticker",MergeBuildType.CollinsBuild)]
        [InlineData(19, "C56A4180-65AA-42EC-A945-5FD21DEC0999","views",MergeBuildType.ChildBuild)]
        [InlineData(0, "C56A4180-65AA-42EC-A945-5FD21DEC0999","trigger",MergeBuildType.NotSelected)]
        public async Task UpdateMergeConflictSelectionTest(int configId, Guid taskid, string conflictIds, MergeBuildType buildSelection)
        {
            try
            {
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configId);
                var aircraftRepo = MockAircraftData(configId);
                var collinsContentIds = "";
                var childContentIds = "";
                int mergeStatus = (int)MergeChoice.Conflicted;
                var Mergerepo = new Mock<MergeConfigurationRepository>();
                if (configId == 18)
                {
                    collinsContentIds = conflictIds;
                    mergeStatus = (int)MergeChoice.SelectedParent;
                    Mergerepo.Setup(c => c.UpdateMergeConflictSelection(taskid,collinsContentIds,childContentIds,mergeStatus)).Returns(Task.FromResult(1));
                }
                else if (configId == 19)
                {
                    childContentIds = conflictIds;
                    mergeStatus = (int)MergeChoice.SelectedChild;
                    Mergerepo.Setup(c => c.UpdateMergeConflictSelection(taskid, collinsContentIds, childContentIds, mergeStatus)).Returns(Task.FromResult(1));
                }
                else if (configId == 0)
                {
                    mergeStatus = 2;
                    Mergerepo.Setup(c => c.UpdateMergeConflictSelection(taskid, collinsContentIds, childContentIds, mergeStatus)).Returns(Task.FromResult(0));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.MergeConfigurationRepository).Returns(Mergerepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                // Act
                var client = _factory.CreateAdmin();
                var response = await client.PostAsync("api/MergeConfiguration/" + configId + "/" + taskid +"/"+ conflictIds+"/"+ buildSelection + "/UpdateMergeConflictSelection",null);
                var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configId == 18)
                    result.Message.Should().Be("Merge Conflict Selection Updated!");
                else if (configId == 19)
                    result.Message.Should().Be("Merge Conflict Selection Updated!");
                else if (configId == 0)
                    result.Message.Should().Be("Error Updating the Merge Conflict Selection");
            }
            catch (Exception ex)
            {
                throw ex;
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
