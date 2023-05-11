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

namespace backend.IntegrationTest.Tests.Manage
{

    [Collection("sequential")]
    public class ManageControllerTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public ManageControllerTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

        [Theory(DisplayName = "get claims by role id")]
        [InlineData(1, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", 0)]
        [InlineData(18, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", 1)]
        public async Task GetClaimsByRoleIdTest(int configId, Guid roleId, int expectedresult)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            IEnumerable<UserClaims> userClaims;
            List<UserClaims> userlist = new List<UserClaims>();
            var claimsrepo = new Mock<UserClaimsRepository>();
            if (configId == 18)
            {
                UserClaims user = new UserClaims();
                user.Description = "hi";
                user.ID = Guid.Parse("3A638B85-7F31-4E6A-BFA1-40C6003AC404");
                user.Name = "new claim";
                userlist.Add(user);
                userClaims = userlist;
                claimsrepo.Setup(c => c.GetClaimsByRoleId(roleId)).Returns(Task.FromResult(userClaims));
            }
            else if (configId == 1)
            {
                userClaims = null;
                claimsrepo.Setup(c => c.GetClaimsByRoleId(roleId)).Returns(Task.FromResult(userClaims));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.UserClaimsRepository).Returns(claimsrepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Manage/roles/" + roleId + "/rights");
            var result = JsonConvert.DeserializeObject<IEnumerable<ClaimsListDTO>>(await response.Content.ReadAsStringAsync());
            // Assert
            if (configId == 18)
            {
                result.ToList().Count.Should().Be(1);
            }
            else
            {
                result.Should().BeNullOrEmpty();
            }


        }
            

        [Theory(DisplayName = "get user by role id")]
        [InlineData(1, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", 0)]
        [InlineData(18, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", 1)]
        public async Task GetUserByRoleIdTest(int configId, Guid Roleid, int expectedresult)
        {
           // Arrange
           var userRepo = MockUserData();
           var configRepo = MockConfigData(configId);
           var aircraftRepo = MockAircraftData(configId);
           var rolerepo = new Mock<UserRoleAssignmentsRepository>();
           IEnumerable<User> users;
           List<User> list = new List<User>();
           if (configId == 18)
           {
                User user = new User();
                user.Company = "collins";
                user.DateCreated = DateTimeOffset.Now;
                user.Email = "abc @collins.com";
                list.Add(user);
                users = list;
                rolerepo.Setup(c => c.GetUsersByRoleId(Roleid)).Returns(Task.FromResult(users));
           }
           else if (configId == 1)
           {
                users = null;
                rolerepo.Setup(c => c.GetUsersByRoleId(Roleid)).Returns(Task.FromResult(users));
           }
           var mockRepos = new Mock<IUnitOfWorkRepository>();
           mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
           mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
           mockRepos.Setup(c => c.UserRoleAssignmentsRepository).Returns(rolerepo.Object);
           mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
           _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // Act
            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/Manage/roles/" + Roleid + "/users");
            var result = JsonConvert.DeserializeObject<List<UserListDTO>>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
            {
               result.Count.Should().Be(1);
            }
            else if (configId == 1)
            {
                result.Should().BeNullOrEmpty();
            }
        }


        [Theory(DisplayName = "remove user from role")]
        [InlineData(18, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", "3A638B85-7F31-4E6A-BFA1-40C6003AC404")]
        [InlineData(1, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", "3A638B85-7F31-4E6A-BFA1-40C6003AC404")]
        [InlineData(2, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", "3A638B85-7F31-4E6A-BFA1-40C6003AC404")]

        public async Task RemoveUserFromRoleTest(int configId, Guid Roleid, Guid userId)
        {
            // Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var rolerepo = new Mock<UserRoleAssignmentsRepository>();
            if (configId == 18)
            {
                  rolerepo.Setup(c => c.GetCountByUserIdRoleId(userId, Roleid)).Returns(Task.FromResult(1));
                  rolerepo.Setup(c => c.RemoveRoleAssignmentByUserId(userId, Roleid)).Returns(Task.FromResult(1));
            }
            else if (configId == 1)
            {
                 rolerepo.Setup(c => c.GetCountByUserIdRoleId(userId, Roleid)).Returns(Task.FromResult(1));
                 rolerepo.Setup(c => c.RemoveRoleAssignmentByUserId(userId, Roleid)).Returns(Task.FromResult(0));
            }
            else if (configId == 2)
            {
                 rolerepo.Setup(c => c.GetCountByUserIdRoleId(userId, Roleid)).Returns(Task.FromResult(0));
                 rolerepo.Setup(c => c.RemoveRoleAssignmentByUserId(userId, Roleid)).Returns(Task.FromResult(0));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.UserRoleAssignmentsRepository).Returns(rolerepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
             _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            //Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/Manage/roles/" + Roleid + "/remove/user/" + userId, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            //Assert
            if (configId == 18)
            {
               result.Message.Should().Be("User has been Deleted Successfully!");
            }
            else if (configId == 1)
            {
               result.Message.Should().Be("Delete Failed!");
            }
            else if (configId == 2)
            {
               result.Message.Should().Be("UserToRole Assignment doesn't exists!");
            }
        }


        //Extension method
        [Theory(DisplayName = "add user to role")]
        [InlineData(18, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", "3A638B85-7F31-4E6A-BFA1-40C6003AC404", 1, 0)]
        [InlineData(19, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", "3A638B85-7F31-4E6A-BFA1-40C6003AC404", 0, 1)]
        [InlineData(0, "3CD9AEB9-564F-41A4-AC03-00EF897F29F7", "3A638B85-7F31-4E6A-BFA1-40C6003AC404", 0, 0)]
        public async Task addUserToRoleTest(int configId, Guid roleID, Guid userId, int resultValue, int addingvalue)
        {
            //Arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configId);
            var aircraftRepo = MockAircraftData(configId);
            var rolerepo = new Mock<UserRoleAssignmentsRepository>();
            UserRoleAssignments user = new UserRoleAssignments { RoleID = roleID, UserID = userId };
            if (configId == 18)
            {
                rolerepo.Setup(c => c.GetCountByUserIdRoleId(userId, roleID)).Returns(Task.FromResult(1));

            }
            else if (configId == 19)
            {
                rolerepo.Setup(c => c.GetCountByUserIdRoleId(userId, roleID)).Returns(Task.FromResult(0));
                rolerepo.Setup(c => c.InsertAsync(user)).Returns(Task.FromResult(1));
            }
            else if (configId == 0)
            {
                rolerepo.Setup(c => c.GetCountByUserIdRoleId(userId, roleID)).Returns(Task.FromResult(0));
                rolerepo.Setup(c => c.InsertAsync(user)).Returns(Task.FromResult(0));
            }
            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.UserRoleAssignmentsRepository).Returns(rolerepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            //Act
            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/Manage/roles/" + roleID + "/add/user/" + userId, null);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());

            // Assert
            if (configId == 18)
                result.Message.Should().Be("User is already existing in the Role");
            else if (configId == 19)
                result.Message.Should().Be("User has been assigned to the Role");
            else if (configId == 0)
                result.Message.Should().Be("Addition Faild");
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




    

