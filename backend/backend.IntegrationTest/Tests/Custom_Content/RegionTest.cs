using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using FluentAssertions;
using Moq;
using Newtonsoft.Json;
using Xunit;

namespace backend.IntegrationTest.Tests.Custom_Content
{
    public class RegionTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public RegionTest(ApplicationFactory<backend.Startup> factory)
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

        private void SetUpMockRepo(Moq.Mock<RegionRepository> regionRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.RegionRepository).Returns(regionRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }


        [Theory(DisplayName = "Region - GetAllRegions")]
        [InlineData(1, 1)]

        public async Task GetAllRegions(int configId, int expectedResult)
        {
            IEnumerable<Region> regions;
            List<Region> regionInfo = new List<Region>();
            var region = new Region();
            region.RegionID = 1;
            region.RegionName = "Asia";



            regionInfo.Add(region);
            regions = regionInfo;

            var countryMockrepo = new Moq.Mock<RegionRepository>();

            countryMockrepo.Setup(c => c.GetAllRegions(configId)).Returns(Task.FromResult(regions));

            SetUpMockRepo(countryMockrepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/region/" + configId.ToString() + "/all");
            var result = JsonConvert.DeserializeObject<List<Country>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);


        }

        [Theory(DisplayName = "Region - GetRegionInfo")]
        [InlineData(1)]

        public async Task GetRegionInfo(int configId)
        {
            var regionInfo = new RegionInfo();
            regionInfo.RegionID = 1;
            regionInfo.names = new List<RegionNameInfo>();

            var countryMockrepo = new Moq.Mock<RegionRepository>();

            countryMockrepo.Setup(c => c.GetRegionInfo(configId, regionInfo.RegionID)).Returns(Task.FromResult(regionInfo));

            SetUpMockRepo(countryMockrepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/region/" + configId.ToString() + "/details/" + regionInfo.RegionID);
            var result = JsonConvert.DeserializeObject<RegionInfo>(await response.Content.ReadAsStringAsync());
            result.RegionID.Should().Be(regionInfo.RegionID);

        }


        [Theory(DisplayName = "Region - Update")]
        [InlineData(1, 1)]
        [InlineData(1, 0)]

        public async Task Update(int configId, int expectedResult)
        {

            var regionInfo = new RegionInfo();
            regionInfo.RegionID = 1;

            List<RegionNameInfo> regionNameInfos = new List<RegionNameInfo>();

            var regionNameInfo = new RegionNameInfo();
            regionNameInfo.SpellingID = 1;
            regionNameInfo.LanguageID = 1;
            regionNameInfo.Language = "English";
            regionNameInfo.RegionName = "Asia";
            regionNameInfos.Add(regionNameInfo);
            regionInfo.names = regionNameInfos;


            var airportsMockRepo = new Moq.Mock<RegionRepository>();

            airportsMockRepo.Setup(c => c.UpdateRegion(configId, regionInfo.RegionID, regionInfo.names[0].LanguageID, regionInfo.names[0].RegionName))
               .Returns(Task.FromResult(expectedResult));
            SetUpMockRepo(airportsMockRepo, configId);

            var httpContent = JsonConvert.SerializeObject(regionInfo);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/region/" + configId.ToString() + "/update", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            if (expectedResult == 1)
            {
                result.IsError.Should().Be(false);
            }
            else
            {
                result.IsError.Should().Be(true);

            }
        }


        [Theory(DisplayName = "Region - Add")]
        [InlineData(1, 1)]
        [InlineData(1, 0)]

        public async Task Add(int configId, int expectedResult)
        {

            var region = new Region();
            region.RegionName = "Asia";

            var regionInfo = new RegionInfo();
            List<RegionNameInfo> regionNameInfos = new List<RegionNameInfo>();

            var regionNameInfo = new RegionNameInfo();
            regionNameInfo.SpellingID = 1;
            regionNameInfo.LanguageID = 1;
            regionNameInfo.Language = "English";
            regionNameInfo.RegionName = "Asia";
            regionNameInfos.Add(regionNameInfo);
            regionInfo.names = regionNameInfos;


            var regionId = 1;
            var airportsMockRepo = new Moq.Mock<RegionRepository>();

            airportsMockRepo.Setup(c => c.AddRegion(configId, region.RegionName)).Returns(Task.FromResult(regionId));

            airportsMockRepo.Setup(c => c.AddRegionDetails(configId, regionInfo.RegionID, regionInfo.names[0].LanguageID, regionInfo.names[0].RegionName))
               .Returns(Task.FromResult(expectedResult));
            SetUpMockRepo(airportsMockRepo, configId);

            var httpContent = JsonConvert.SerializeObject(regionInfo);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/region/" + configId.ToString() + "/add", byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            if (expectedResult == 1)
            {
                result.IsError.Should().Be(false);
            }
            else
            {
                result.IsError.Should().Be(true);

            }
        }
        }
}
