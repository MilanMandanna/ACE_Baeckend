using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using FluentAssertions;
using Moq;
using Newtonsoft.Json;
using Xunit;

namespace backend.IntegrationTest.Tests.Custom_Content
{
    public class AirportTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
      
        private readonly ApplicationFactory<backend.Startup> _factory;

        public AirportTest(ApplicationFactory<backend.Startup> factory)
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



        private void SetUpMockRepo(Moq.Mock<AirportInfoRepository> airportRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.AirportInfo).Returns(MockAirportData(configId).Object);
            mockRepos.Setup(c => c.AirportInfo).Returns(airportRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }


        [Theory(DisplayName = "Airports - GetAllAirports")]
        [InlineData(1, 1)]

        public async Task GetAllAirports(int configId, int expectedResult)
        {
            IEnumerable<Airport> airports;
            List<Airport> airportInfos = new List<Airport>();
            var airport = new Airport();
            airport.AirportInfoID = 1;
            airport.FourLetID = "00S";
            airport.ThreeLetID = "";
            airport.CityName = "Blue River";
            airport.GeoRefID = 6;
            airport.Lat = (decimal)45.655556;
            airport.Lon = (decimal)-122.305556;

            airportInfos.Add(airport);
            airports = airportInfos;

            var airportsMockRepo = new Moq.Mock<AirportInfoRepository>();
            
            airportsMockRepo.Setup(c => c.GetAllAirports(1)).Returns(Task.FromResult(airports));
          
            SetUpMockRepo(airportsMockRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/airport/" + configId.ToString() + "/airports/all");
            var result = JsonConvert.DeserializeObject<List<Airport>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
            

        }

        [Theory(DisplayName = "Airports - Update")]
        [InlineData(1, 1,"success")]
        [InlineData(1, 0,"Failed")]

        public async Task Update(int configId, int expectedResult, string message)
        {
            IEnumerable<Airport> airports;
            List<Airport> airportInfos = new List<Airport>();
            var airport = new Airport();
            airport.AirportInfoID = 1;
            airport.FourLetID = "00S";
            airport.ThreeLetID = "";
            airport.CityName = "Blue River";
            airport.GeoRefID = 6;
            airport.Lat = (decimal)45.655556;
            airport.Lon = (decimal)-122.305556;

            airportInfos.Add(airport);
            airports = airportInfos;

            var airportsMockRepo = new Moq.Mock<AirportInfoRepository>();

            Tuple<int, string> mockresult = Tuple.Create(expectedResult, message);
            airportsMockRepo.Setup(c => c.UpdateAirport(It.IsAny<int>(), It.IsAny<ListModlistInfo>())).Returns(Task.FromResult(mockresult.ToValueTuple()));


            SetUpMockRepo(airportsMockRepo, configId);

            var httpContent = JsonConvert.SerializeObject(airport);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/airport/" + configId.ToString() + "/airport/update",byteContent);
            var result = JsonConvert.DeserializeObject<DataCreationResultDTO>(await response.Content.ReadAsStringAsync());
            if(expectedResult == 1)
            {
                result.IsError.Should().Be(false);
            } else
            {
                result.IsError.Should().Be(true);

            }
        }

        [Theory(DisplayName = "Airports - Add")]
        [InlineData(1, 1, "success")]
        [InlineData(1, 0, "Failed")]

        public async Task Add(int configId, int expectedResult, string message)
        {
            IEnumerable<Airport> airports;
            List<Airport> airportInfos = new List<Airport>();
            var airport = new Airport();
            airport.AirportInfoID = 1;
            airport.FourLetID = "00S";
            airport.ThreeLetID = "";
            airport.CityName = "Blue River";
            airport.GeoRefID = 6;
            airport.Lat = (decimal)45.655556;
            airport.Lon = (decimal)-122.305556;

            airportInfos.Add(airport);
            airports = airportInfos;

            var airportsMockRepo = new Moq.Mock<AirportInfoRepository>();

            Tuple<int, string> mockresult = Tuple.Create(expectedResult, message);
            airportsMockRepo.Setup(c => c.AddAirport(It.IsAny<int>(), It.IsAny<Airport>())).Returns(Task.FromResult(mockresult.ToValueTuple()));


            SetUpMockRepo(airportsMockRepo, configId);

            var httpContent = JsonConvert.SerializeObject(airport);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/airport/" + configId.ToString() + "/airport/add", byteContent);
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


        [Theory(DisplayName = "Airports - GetAllCities")]
        [InlineData(1, 1)]

        public async Task GetAllCities(int configId, int expectedResult)
        {
            IEnumerable<CityInfo> cities;
            List<CityInfo> cityInfos = new List<CityInfo>();
            var city = new CityInfo();
            city.GeoRefId = 1;
            city.Name = "Bangalore";
            city.Country = "India";


            cityInfos.Add(city);
            cities = cityInfos;

            var airportsMockRepo = new Moq.Mock<AirportInfoRepository>();

            airportsMockRepo.Setup(c => c.getAllCities(1)).Returns(Task.FromResult(cities));

            SetUpMockRepo(airportsMockRepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/airport/" + configId.ToString() + "/airport/cities/all");
            var result = JsonConvert.DeserializeObject<List<Airport>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }
       

    }
}
