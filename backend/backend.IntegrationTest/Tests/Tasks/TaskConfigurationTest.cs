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
using backend.Controllers;

namespace backend.IntegrationTest.Tests.Tasks
{

    [Collection("sequential")]
    public class TaskConfigurationTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public TaskConfigurationTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }
       

        [Theory(DisplayName = "create Task")]
        [InlineData(18)]
        [InlineData(19)]
        public async Task createTaskTest(int configId)
        {
           
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configId);
                var aircraftRepo = MockAircraftData(configId);
                var taskRepo = new Mock<TaskRepository>();
                TaskInput tasks = new TaskInput();
                tasks.PercentageComplete = 98;
                tasks.TaskID = Guid.Parse("3FF21C44-194A-4139-8E65-0BC2A56516CA");
                tasks.TaskTypeID = Guid.Parse("3FF21C44-194A-4139-8E65-0BC2A56516CA");
                tasks.UserID = Guid.Parse("25D25944-338A-42F5-B603-00317DDDE130");
                tasks.DetailedStatus = "in progress";

                if (configId == 18)
                {
                    DataLayer.Models.Task.Task t = new DataLayer.Models.Task.Task();
                    t.DetailedStatus = "In Progress";
                    t.ID = Guid.Parse("3FF21C44-194A-4139-8E65-0BC2A56516CA");
                    taskRepo.Setup(c => c.createTask(tasks.TaskTypeID, tasks.UserID, tasks.TaskStatusID, tasks.PercentageComplete, tasks.DetailedStatus, tasks.AzureBuildID)).Returns(Task.FromResult(t));

                }
                else if (configId == 19)
                {
                    DataLayer.Models.Task.Task ts = new DataLayer.Models.Task.Task();
                    ts.DetailedStatus = "Failed";
                    ts.ID = Guid.Parse("3FF21C44-194A-4139-8E65-0BC2A56516CA");
                    taskRepo.Setup(c => c.createTask(tasks.TaskTypeID, tasks.UserID, tasks.TaskStatusID, tasks.PercentageComplete, tasks.DetailedStatus, tasks.AzureBuildID)).Returns(Task.FromResult(ts));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.TaskRepository).Returns(taskRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                // Act

                var httpContent = JsonConvert.SerializeObject(tasks);
                var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
                var byteContent = new ByteArrayContent(buffer);
                byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                var client = _factory.CreateAdmin();
                var response = await client.PostAsync("api/Task/create", byteContent);
                var result = JsonConvert.DeserializeObject<backend.DataLayer.Models.Task.Task>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configId == 18)
                    result.DetailedStatus = "In progress";
                else if (configId == 19)
                    result.DetailedStatus = "failed";
           
        }
        [Theory(DisplayName = "update task ")]
        [InlineData(18)]
        [InlineData(19)]
        
        public async Task updateTaskTest(int configId)
        {
            
                // Arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configId);
                var aircraftRepo = MockAircraftData(configId);
                var taskRepo = new Mock<TaskRepository>();

                TaskInput tasks = new TaskInput();
                tasks.PercentageComplete = 98;
                tasks.TaskID = Guid.Parse("3FF21C44-194A-4139-8E65-0BC2A56516CA");
                tasks.TaskTypeID = Guid.Parse("3FF21C44-194A-4139-8E65-0BC2A56516CA");
                tasks.UserID = Guid.Parse("25D25944-338A-42F5-B603-00317DDDE130");
                tasks.DetailedStatus = "in progress";

                if (configId == 18)
                {
                    DataLayer.Models.Task.Task t = new DataLayer.Models.Task.Task();
                    t.DetailedStatus = "In Progress";
                    t.ID = Guid.Parse("3FF21C44-194A-4139-8E65-0BC2A56516CA");

                    taskRepo.Setup(c => c.updateTask(tasks.TaskTypeID, tasks.TaskStatusID, tasks.PercentageComplete, tasks.DetailedStatus)).Returns(Task.FromResult(t));

                }
                else if (configId == 19)
                {
                    DataLayer.Models.Task.Task ts = new DataLayer.Models.Task.Task();
                    ts.DetailedStatus = "Failed";
                    ts.ID = Guid.Parse("3FF21C44-194A-4139-8E65-0BC2A56516CA");
                    taskRepo.Setup(c => c.updateTask(tasks.TaskTypeID, tasks.TaskStatusID, tasks.PercentageComplete, tasks.DetailedStatus)).Returns(Task.FromResult(ts));
                }
                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.TaskRepository).Returns(taskRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(aircraftRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

                // Act
                var httpContent = JsonConvert.SerializeObject(tasks);
                var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
                var byteContent = new ByteArrayContent(buffer);
                byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

                var client = _factory.CreateAdmin();
                var response = await client.PostAsync("api/Task/update", byteContent);
                var result = JsonConvert.DeserializeObject<backend.DataLayer.Models.Task.Task>(await response.Content.ReadAsStringAsync());

                // Assert
                if (configId == 18)
                    result.DetailedStatus = "In progress";
                else if (configId == 19)
                    result.DetailedStatus = "failed";
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
