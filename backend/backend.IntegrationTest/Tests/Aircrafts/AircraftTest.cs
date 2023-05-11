using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Models.DownloadPreferences;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Aircraft;
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


namespace backend.IntegrationTest.Tests.Aircrafts
{
    [Collection("sequential")]
    public class AircraftTest: IClassFixture<ApplicationFactory<Startup>>
    {
       
        private ApplicationFactory<Startup> _factory;
        public AircraftTest(ApplicationFactory<Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

      
        [Theory(DisplayName = "Find all the aircraft")]
        [InlineData(107)]
        [InlineData(0)]
        public async Task FindAllAircraftTest(int configurationId)
        {
            // Arrange
           
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                IEnumerable<Aircraft> aircraft;
                List<Aircraft> air = new List<Aircraft>();
                Aircraft aircraft1 = new Aircraft();
                aircraft1.DateCreated = DateTimeOffset.Now;
                aircraft1.CreatedByUserId = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                aircraft1.ContentDiskSpace = 2;
                aircraft1.Id = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                air.Add(aircraft1);
                aircraft = air;
                var aircraftsRepo = new Mock<AircraftRepository>();
                if (configurationId == 107)
                {
                    aircraftsRepo.Setup(c => c.FindAll()).Returns(Task.FromResult(aircraft));

                }
                else if (configurationId == 0)
                {
                    aircraftsRepo.Setup(c => c.FindAll()).Returns(Task.FromResult<IEnumerable<Aircraft>>(null));

                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftsRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                //Act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/Aircraft/all");
                var result = JsonConvert.DeserializeObject<List<AircraftDTO>>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configurationId == 107)
                    result[0].Id.Equals("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                else if (configurationId == 0)
                    result[0].Id.Equals(Guid.Empty);
        }

        [Theory(DisplayName = "get download preference")]
        [InlineData(107, "1221")]
        [InlineData(0,"0")]
        public async Task GetDownloadPreferencesTest(int configurationId,string Tailnumber)
        {
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                var aircraftRepo = MockAircraftData(configurationId);
                IEnumerable<Aircraft> aircraft;
                List<DownloadPreference> down = new List<DownloadPreference>();
                DownloadPreference dow = new DownloadPreference();
                dow.AssetType = 1;
                down.Add(dow);
                var downloadRepo = new Mock<DownloadPreferenceRepository>();
                if (configurationId == 107)
                {
                    downloadRepo.Setup(c => c.GetAll()).Returns(Task.FromResult(down));
                }
                else if (configurationId == 0)
                {
                    downloadRepo.Setup(c => c.GetAll()).Returns(Task.FromResult<List<DownloadPreference>>(null));

                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                mockRepos.Setup(c => c.DownloadPreferences).Returns(downloadRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                //Act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/aircraft/downloadpreferences");
                var result = JsonConvert.DeserializeObject<List<DownloadPreference>>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configurationId == 107)
                    result.Count.Should().Be(1);
                else if(configurationId ==0)
                    result.Should().BeNullOrEmpty();
        }

        [Theory(DisplayName = "get download preference")]
        [InlineData(107, "1221")]
        [InlineData(0, "0")]
        public async Task GetAircraftDownloadPreferencesTest(int configurationId, string tailNumber)
        {
            // Arrange
           
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                Aircraft air = new Aircraft();
                air.CreatedByUserId = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                air.DateCreated = DateTimeOffset.Now;
                air.Id = Guid.Parse("3A638B85-7F31-4E6A-BFA1-40C6003AC404");
                air.ConnectivityTypes = "1; 2; 3";

                List<DownloadPreferenceAssignment> assignments = new List<DownloadPreferenceAssignment>();
                DownloadPreferenceAssignment ds = new DownloadPreferenceAssignment();
                ds.Id = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                assignments.Add(ds);

                List<DownloadPreference> dp = new List<DownloadPreference>();
                DownloadPreference dp1 = new DownloadPreference();
                dp1.Id = Guid.Parse("3A638B85-7F31-4E6A-BFA1-40C6003AC404");
                dp1.Name = "new preference";
                dp1.Title = "download prefrence";
                dp.Add(dp1);


                var downloadRepo = new Mock<DownloadPreferenceRepository>();
                var airRepo = new Mock<AircraftRepository>();
                if (configurationId == 107)
                {
                    airRepo.Setup(c => c.FindByTailNumber(tailNumber)).Returns(air);
                    downloadRepo.Setup(c => c.GetAll()).Returns(Task.FromResult(dp));
                    downloadRepo.Setup(c => c.GetAircraftDownloadPreferences(tailNumber)).Returns(Task.FromResult(assignments));

                }
                else if (configurationId == 0)
                {
                    downloadRepo.Setup(c => c.GetAll()).Returns(Task.FromResult<List<DownloadPreference>>(null));

                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(airRepo.Object);
                mockRepos.Setup(c => c.DownloadPreferences).Returns(downloadRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                //act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/aircraft/" + tailNumber + "/downloadpreferences");
                var result = JsonConvert.DeserializeObject<List<DownloadPreference>>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configurationId == 107)
                    result.Count.Should().Be(1);
                else if (configurationId == 0)
                    result.Should().BeNullOrEmpty();
            
        }

        [Theory(DisplayName = "get download preference")]
        [InlineData(107, "1221",true, "Episode","1")]
        [InlineData(0, "0", false, "Episode", "1")]
        public async Task SelectAircraftDownloadPreferenceTest(int configurationId, string tailNumber, bool selected, string downloadPreferenceName, string type)
        {
            // Arrange
           
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                Aircraft air = new Aircraft();
                air.CreatedByUserId = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                air.DateCreated = DateTimeOffset.Now;
                air.Id = Guid.Parse("3A638B85-7F31-4E6A-BFA1-40C6003AC404");
                air.ConnectivityTypes = "1; 2; 3";

                DownloadPreferenceAssignment ds = new DownloadPreferenceAssignment();
                ds.Id = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                ds.PreferenceList = "2;1";

                DownloadPreference dp1 = new DownloadPreference();
                dp1.Id = Guid.Parse("3A638B85-7F31-4E6A-BFA1-40C6003AC404");
                dp1.Name = "new preference";
                dp1.Title = "download prefrence";
                
                var downloadRepo = new Mock<DownloadPreferenceRepository>();
                var airRepo = new Mock<AircraftRepository>();
                if (configurationId == 107)
                {
                    airRepo.Setup(c => c.FindByTailNumber(tailNumber)).Returns(air);
                    downloadRepo.Setup(c => c.GetByName(downloadPreferenceName)).Returns(Task.FromResult(dp1));
                    downloadRepo.Setup(c => c.GetAircraftDownloadPreference(tailNumber,dp1.Id)).Returns(Task.FromResult(ds));
                }
                else if (configurationId == 0)
                {
                    downloadRepo.Setup(c => c.GetAll()).Returns(Task.FromResult<List<DownloadPreference>>(null));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(airRepo.Object);
                mockRepos.Setup(c => c.DownloadPreferences).Returns(downloadRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                //act
                var client = _factory.CreateAdmin();
                var response = await client.PostAsync("api/aircraft/" +tailNumber+"/select/"+selected+"/downloadpreference/"+downloadPreferenceName+"/type/"+type,null);
                var result = JsonConvert.DeserializeObject<SelectionResultDTO>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configurationId == 107)
                    result.IsSelected = DataLayer.Models.DataStructure.SelectionState.Selected;
                else if (configurationId == 0)
                    result.IsSelected = DataLayer.Models.DataStructure.SelectionState.NotSelected;
        }


        [Theory(DisplayName = "get configuration defnition partNumber")]
        [InlineData(107, 1)]
        [InlineData(0, 0)]
        public async Task ConfigurationDefinitionPartNumberTest(int configurationId, int configurationDefnitionId )
        {
            // Arrange
           
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                var aircraftRepo = MockAircraftData(configurationId);
               
                List<BuildDefaultPartnumber> build = new List<BuildDefaultPartnumber>();

                BuildDefaultPartnumber bp = new BuildDefaultPartnumber();
                bp.DefaultPartNumber = "45GV678";
                bp.Description = "new part number";
                bp.Name = "venue hybrid";
                bp.PartNumberID =1;
                bp.PartNumberCollectionID = 2;
                build.Add(bp);
                var AircraftsRepo = new Mock<AircraftRepository>();
                if (configurationId == 107)
                {
                    AircraftsRepo.Setup(c => c.ConfigurationDefinitionPartNumber(configurationDefnitionId,2,"")).Returns(Task.FromResult(build));

                }
                else if (configurationId == 0)
                {
                    AircraftsRepo.Setup(c => c.ConfigurationDefinitionPartNumber(configurationDefnitionId,2,"")).Returns(Task.FromResult<List<BuildDefaultPartnumber>>(null));

                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(AircraftsRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/Aircraft/PartNumber/" + configurationDefnitionId);
                var result = JsonConvert.DeserializeObject<List<BuildDefaultPartnumber>>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configurationId == 107)
                    result.Count.Should().Be(1);
                else if(configurationId == 0)
                    result.Should().BeNullOrEmpty();
           
        }

        [Theory(DisplayName = "configuration defnition update partnumber")]
        [InlineData(107, 1)]
        [InlineData(0, 0)]
        public async Task ConfigurationDefinitionUpdatePartNumberTest(int configurationId, int expected )
        {
            // Arrange
            
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                PartNumber part = new PartNumber();
                part.ConfigurationDefinitionID = 1;
                part.PartNumberID = 1;
                part.Value = "10RGV";

                var AircraftsRepo = new Mock<AircraftRepository>();
                if (configurationId == 107)
                {
                    AircraftsRepo.Setup(c => c.ConfigurationDefinitionUpdatePartNumber(part)).Returns(Task.FromResult(1));

                }
                else if (configurationId == 0)
                {
                    AircraftsRepo.Setup(c => c.ConfigurationDefinitionUpdatePartNumber(part)).Returns(Task.FromResult(0));

                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(AircraftsRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                var client = _factory.CreateAdmin();
                var httpContent = JsonConvert.SerializeObject(part);
                var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
                var byteContent = new ByteArrayContent(buffer);
                byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                var response = await client.PostAsync("api/Aircraft/update/partNumber",byteContent);
                var result = JsonConvert.DeserializeObject< DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configurationId == 107)
                    result.Message.Should().Be("Partnumber updated successfully");
                else if (configurationId == 0)
                    result.Message.Should().Be("Partnumber updation failed");
        }

       
        [Theory(DisplayName = "GetAircraftConectivity")]
        [InlineData(107, "54ERAS")]
        [InlineData(0, "54ERAS")]
        public async Task GetAircraftConnectivityTypesTest(int configurationId, string tailNumber)
        {
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                IEnumerable<Aircraft> aircraft;
                List<Aircraft> air = new List<Aircraft>();
                Aircraft aircraft1 = new Aircraft();
                aircraft1.DateCreated = DateTimeOffset.Now;
                aircraft1.CreatedByUserId = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                aircraft1.ContentDiskSpace = 2;
                aircraft1.ConnectivityTypes = "1; 2; 3";
                air.Add(aircraft1);
                aircraft = air;
                var aircraftsRepo = new Mock<AircraftRepository>();
                if (configurationId == 107)
                {
                   aircraftsRepo.Setup(c => c.FindByTailNumber(tailNumber)).Returns(aircraft1);

                }
                else if (configurationId == 0)
                {
                    aircraftsRepo.Setup(c => c.FindByTailNumber(tailNumber)).Returns<Aircraft>(null);

                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftsRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
                
                //Act
                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/Aircraft/"+tailNumber+ "/connectivity_types");
                var result = JsonConvert.DeserializeObject<List<ItemWithSelectionDTO>>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configurationId == 107)
                    result.Count.Should().Be(3);
                else if (configurationId == 0)
                    result.Should().BeNullOrEmpty();
        }


        [Theory(DisplayName = "GetAircraftConectivity")]
        [InlineData(107, "54ERAS",true,"0")]
        [InlineData(0, "54ERAS",false,"4")]
        public async Task SetAircraftConnectivityTypeTest(int configurationId, string tailNumber, bool isSelected, string connectionTypeName)
        {
            try
            {
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configurationId);
                IEnumerable<Aircraft> aircraft;
                List<Aircraft> air = new List<Aircraft>();
                Aircraft aircraft1 = new Aircraft();
                aircraft1.DateCreated = DateTimeOffset.Now;
                aircraft1.CreatedByUserId = Guid.Parse("3CD9AEB9-564F-41A4-AC03-00EF897F29F7");
                aircraft1.ContentDiskSpace = 2;
                aircraft1.ConnectivityTypes = "1; 2; 3";
                air.Add(aircraft1);
                aircraft = air;
                var aircraftsRepo = new Mock<AircraftRepository>();
                if (configurationId == 107)
                {
                    aircraftsRepo.Setup(c => c.FindByTailNumber(tailNumber)).Returns(aircraft1);
                }
                else if (configurationId == 0)
                {
                    aircraftsRepo.Setup(c => c.FindByTailNumber(tailNumber)).Returns<Aircraft>(null);

                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftsRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                //Act
                var client = _factory.CreateAdmin();
                var response = await client.PostAsync("api/Aircraft/" + tailNumber + "/connectivity_types/select/" + isSelected + "/connectiontype/" + connectionTypeName, null);
                var result = JsonConvert.DeserializeObject<SelectionResultDTO>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configurationId == 107)
                    result.IsSelected = DataLayer.Models.DataStructure.SelectionState.Selected;
                else if (configurationId == 0)
                    result.IsSelected = DataLayer.Models.DataStructure.SelectionState.NotSelected;
            }
            catch(Exception ex)
            {
                throw ex;
            }
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
