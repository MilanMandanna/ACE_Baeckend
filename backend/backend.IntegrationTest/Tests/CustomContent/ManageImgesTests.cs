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

namespace backend.IntegrationTest.Tests.CustomContent
{
    [Collection("sequential")]
    public class ManageImgesTests : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public ManageImgesTests(ApplicationFactory<backend.Startup> factory)
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



        private void SetUpMockRepo(Moq.Mock<CustomContentRepository> customConfigRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.CustomContentRepository).Returns(customConfigRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }

        [Theory(DisplayName = "Custom Content - DeleteImage")]
        [InlineData(18, 0,2, true)]
        [InlineData(0, 1,1, true)]
        [InlineData(0, 0,3, true)]
        public async Task DeleteImage(int configId, int imageId,int type, bool expected)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            customContentRepo.Setup(c => c.DeleteImage(configId, imageId)).Returns(Task.FromResult(Convert.ToInt32(expected)));
            customContentRepo.Setup(c => c.GetImageDetails(configId, imageId)).Returns(Task.FromResult((new ImageDetails())));
            customContentRepo.Setup(c => c.GetResolutions()).Returns(Task.FromResult((new Dictionary<int, string>())));
            
            //scriptRepo.Setup(c => c.DeleteImage(configId, imageId)).Returns(Task.FromResult(0));
            //scriptRepo.Setup(c => c.DeleteImage(configId, imageId)).Returns(Task.FromResult(0));

            SetUpMockRepo(customContentRepo, configId);

            //var name= System.Reflection.MethodBase.GetCurrentMethod().Name;

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/removeimage/" + imageId+"/"+type);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            result.IsError.Should().Be(expected);
        }

        [Theory(DisplayName = "Custom Content - GetConfigImages")]
        [InlineData(18, 2, 1)]
        [InlineData(0,  1, 0)]
        [InlineData(1, 3, 1)]
        [InlineData(0, 0, 0)]

        public async Task GetConfigImagesTest(int configId, int type, int expected)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            customContentRepo.Setup(c => c.GetConfigImages(18, 2)).Returns(Task.FromResult(new List<ImageDetails>() { (new ImageDetails()) }));
            customContentRepo.Setup(c => c.GetConfigImages(0, 1)).Returns(Task.FromResult(new List<ImageDetails>()));
            customContentRepo.Setup(c => c.GetConfigImages(0, 0)).Returns(Task.FromResult(new List<ImageDetails>()));
            customContentRepo.Setup(c => c.GetConfigImages(1, 3)).Returns(Task.FromResult(new List<ImageDetails>() { (new ImageDetails()) }));

            SetUpMockRepo(customContentRepo, configId);

            //var name= System.Reflection.MethodBase.GetCurrentMethod().Name;

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getconfigimages/" + type);
            var result = JsonConvert.DeserializeObject<List<ImageDetails>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expected);
        }

        [Theory(DisplayName = "Custom Content - GetImageCount")]
        [InlineData(2, 1, 1)]
        [InlineData(2, 2, 1)]
        [InlineData(2, 3, 3)]

        public async Task GetImageCountTest(int configId, int type, int expected)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            var imageCount = new Dictionary<string, int>();
            imageCount.Add("1", 1);
            imageCount.Add("2", 1);
            imageCount.Add("3", 3);

      
            customContentRepo.Setup(c => c.GetImageCount(18)).Returns(Task.FromResult(new Dictionary<string, int>()));
            customContentRepo.Setup(c => c.GetImageCount(2)).Returns(Task.FromResult(imageCount));
            SetUpMockRepo(customContentRepo, configId);

            //var name= System.Reflection.MethodBase.GetCurrentMethod().Name;

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getImageCount");
            var result = JsonConvert.DeserializeObject<Dictionary<string, int>>(await response.Content.ReadAsStringAsync());
            result[type.ToString()].Should().Be(expected);
        }

        [Theory(DisplayName = "Custom Content - PreviewImages")]
        [InlineData(18, 2, 1, 1)]
        [InlineData(0, 1, 0, 0)]
        [InlineData(1, 3, 1, 1)]
        [InlineData(0, 0, 1, 0)]

        public async Task PreviewImagesTest(int configId, int imageId, int type, int expected)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            customContentRepo.Setup(c => c.PreviewImages(18, 2, 1)).Returns(Task.FromResult(new List<ImageDetails>() { (new ImageDetails()) }));
            customContentRepo.Setup(c => c.PreviewImages(0, 1, 0)).Returns(Task.FromResult(new List<ImageDetails>()));
            customContentRepo.Setup(c => c.PreviewImages(0, 0, 1)).Returns(Task.FromResult(new List<ImageDetails>()));
            customContentRepo.Setup(c => c.PreviewImages(1, 3, 1)).Returns(Task.FromResult(new List<ImageDetails>() { (new ImageDetails()) }));

            SetUpMockRepo(customContentRepo, configId);

            //var name= System.Reflection.MethodBase.GetCurrentMethod().Name;

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getImagePreview/" + imageId + "/" + type);
            var result = JsonConvert.DeserializeObject<List<ImageDetails>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expected);
        }

        [Theory(DisplayName = "Custom Content - GetDefaultResolution")]
        [InlineData(18, 1)]
        [InlineData(0, 0)]
        [InlineData(1, 1)]
        public async Task GetDefaultResolutionTest(int configId, int expected)
        {
            var customContentRepo = new Moq.Mock<CustomContentRepository>();
            customContentRepo.Setup(c => c.GetResolutionText(18, "1")).Returns(Task.FromResult(new List<string>() { "1080X720" }));
            customContentRepo.Setup(c => c.GetResolutionText(0, "1")).Returns(Task.FromResult(new List<string>()));
            customContentRepo.Setup(c => c.GetResolutionText(1, "1")).Returns(Task.FromResult(new List<string>() { "1200X600" }));

            SetUpMockRepo(customContentRepo, configId);

            //var name= System.Reflection.MethodBase.GetCurrentMethod().Name;

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/CustomContent/" + configId + "/getdefaultresolution/1");
            var result = JsonConvert.DeserializeObject<List<string>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expected);
        }
    }
}
