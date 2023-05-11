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
    public class CountryTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
     
        private readonly ApplicationFactory<backend.Startup> _factory;

        public CountryTest(ApplicationFactory<backend.Startup> factory)
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

        private void SetUpMockRepo(Moq.Mock<CountryRepository> countryRepo, int configId)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(MockConfigData(configId).Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(MockAircraftData(configId).Object);
            mockRepos.Setup(c => c.CountryRepository).Returns(countryRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }


        [Theory(DisplayName = "Country - GetAllCountries")]
        [InlineData(1, 1)]

        public async Task GetAllCountries(int configId, int expectedResult)
        {
            IEnumerable<Country> countries;
            List<Country> countryInfo = new List<Country>();
            var country = new Country();
            country.CountryID = 1;
            country.Description = "USA";
            country.CountryCode = "US";
            country.ISO3166Code = "";
            country.RegionID = 6;


            countryInfo.Add(country);
            countries = countryInfo;

            var countryMockrepo = new Moq.Mock<CountryRepository>();

            countryMockrepo.Setup(c => c.GetAllCountries(configId)).Returns(Task.FromResult(countries));

            SetUpMockRepo(countryMockrepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/country/" + configId.ToString() + "/all");
            var result = JsonConvert.DeserializeObject<List<Country>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);


        }

        

        [Theory(DisplayName = "Country - GetCountryInfo")]
        [InlineData(1)]

        public async Task GetCountryInfo(int configId)
        {
            var countryInfo = new CountryInfo();
            countryInfo.CountryID = 1;
            countryInfo.Description = "USA";
            countryInfo.names = new List<CountryNameInfo>();
        

            var countryMockrepo = new Moq.Mock<CountryRepository>();

            countryMockrepo.Setup(c => c.GetCountryInfo(configId, countryInfo.CountryID)).Returns(Task.FromResult(countryInfo));

            SetUpMockRepo(countryMockrepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/country/" + configId.ToString() + "/details/"+countryInfo.CountryID);
            var result = JsonConvert.DeserializeObject<CountryInfo>(await response.Content.ReadAsStringAsync());
            result.CountryID.Should().Be(countryInfo.CountryID);


        }

        [Theory(DisplayName = "Country - GetSelectedLanguages")]
        [InlineData(1, 2)]
        [InlineData(2, 0)]
        public async Task GetSelectedLanguages(int configId, int expectedResult)
        {
            IEnumerable<Language> languages;
            List<Language> languageList = new List<Language>();
            var language = new Language();
            language.LanguageID = 1;
            language.Description = "English";
            language.Name = "English";

            var language1 = new Language();
            language1.LanguageID = 1;
            language1.Description = "Spanish";
            language1.Name = "Spanish";
          
            if(expectedResult > 0)
            {
                languageList.Add(language);
                languageList.Add(language1);
            }
            languages = languageList;

            var countryMockrepo = new Moq.Mock<CountryRepository>();

            countryMockrepo.Setup(c => c.GetSelectedLanguages(configId)).Returns(Task.FromResult(languages));

            SetUpMockRepo(countryMockrepo, configId);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/country/" + configId.ToString() + "/languages/selected");
            var result = JsonConvert.DeserializeObject<List<Language>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);


        }

        [Theory(DisplayName = "Country - Update")]
        [InlineData(1, 1)]
        [InlineData(1, 0)]

        public async Task Update(int configId, int expectedResult)
        {

            var countryInfo = new CountryInfo();
            countryInfo.CountryID = 1;
            countryInfo.Description = "USA";
            countryInfo.RegionID = 6;

            List<CountryNameInfo> countryNameInfos = new List<CountryNameInfo>();

            var countryNameInfo = new CountryNameInfo();
            countryNameInfo.CountrySpellingID = 1;
            countryNameInfo.LanguageID = 1;
            countryNameInfo.Language = "English";
            countryNameInfo.CountryName = "English";
            countryNameInfos.Add(countryNameInfo);
            countryInfo.names = countryNameInfos;

         
            var airportsMockRepo = new Moq.Mock<CountryRepository>();

            airportsMockRepo.Setup(c => c.UpdateCountry(configId,countryInfo.CountryID,countryInfo.Description,countryInfo.RegionID))
               .Returns(Task.FromResult(expectedResult));
            SetUpMockRepo(airportsMockRepo, configId);

            var httpContent = JsonConvert.SerializeObject(countryInfo);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/country/" + configId.ToString() + "/update", byteContent);
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

        [Theory(DisplayName = "Country - Add")]
        [InlineData(1, 1)]
        [InlineData(1, 0)]

        public async Task Add(int configId, int expectedResult)
        {

            var countryInfo = new CountryInfo();
            countryInfo.Description = "USA";
            countryInfo.RegionID = 6;

            List<CountryNameInfo> countryNameInfos = new List<CountryNameInfo>();

            var countryNameInfo = new CountryNameInfo();
            countryNameInfo.CountrySpellingID = 1;
            countryNameInfo.LanguageID = 1;
            countryNameInfo.Language = "English";
            countryNameInfo.CountryName = "English";
            countryNameInfos.Add(countryNameInfo);
            countryInfo.names = countryNameInfos;

            var countryId = 1;
            var airportsMockRepo = new Moq.Mock<CountryRepository>();

            airportsMockRepo.Setup(c => c.AddCountry(configId, countryInfo.Description, countryInfo.RegionID))
               .Returns(Task.FromResult(countryId));
            SetUpMockRepo(airportsMockRepo, configId);

            airportsMockRepo.Setup(c => c.AddCountryDetails(configId,countryId, countryInfo.names[0].LanguageID, countryInfo.names[0].CountryName))
          .Returns(Task.FromResult(expectedResult));
            SetUpMockRepo(airportsMockRepo, configId);

            var httpContent = JsonConvert.SerializeObject(countryInfo);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/country/" + configId.ToString() + "/add", byteContent);
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
