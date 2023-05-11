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
using System.Net.Http;
using Moq;
using Ace.DataLayer.Models;
using System.Net.Http.Headers;
using System.Linq;
using backend.DataLayer.Models.Fleet;
using backend.Mappers.DataTransferObjects.Aircraft;
using Microsoft.AspNetCore.Mvc;

namespace backend.IntegrationTest.Tests.msu_configuration
{
    public class MsuConfigurationTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public MsuConfigurationTest(ApplicationFactory<backend.Startup> factory)
        {
            _factory = factory;
            _factory.EnableMockDatabase(true);
        }

       

        [Theory(DisplayName = "get active msu configuration")]
        [InlineData(18, "37abfc59-d95e-49f6-9289-2b3abad33132")]
        [InlineData(19, "3cd9aeb9-564f-41a4-ac03-00ef897f29f7")]
        public async Task GetActiveTest(int configid, Guid aircraftid)
        {

            // arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configid);
            var airRepo = new Mock<AircraftRepository>();
            Aircraft air = new Aircraft();
            air.TailNumber = "str145";
            air.SerialNumber = "12e2";
            air.ConnectivityTypes = "1; 2; 3";
            air.Id = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
            air.InstallationTypeID = Guid.Parse("92632C1C-D321-44FC-AB51-C318248801DB");
            air.IsDeleted = false;
            air.Manufacturer = "boeing";
            air.Model = "LSX800";
            air.CreatedByUserId = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
            air.DateCreated = DateTimeOffset.Now;
            air.OperatorId = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
            air.ThirdPartyRoleID = Guid.Parse("92632C1C-D321-44FC-AB51-C318248801DB");
            if (configid == 18)
            {
                airRepo.Setup(c => c.Find(aircraftid.ToString())).Returns(air);

            }
            else if (configid == 19)
            {
                airRepo.Setup(c => c.Find(aircraftid.ToString())).Returns<Aircraft>(null);
            }

            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(airRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);

            // act

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/MsuConfiguration/aircraft/" + aircraftid + "/activemsuconfiguration");
            var result = JsonConvert.DeserializeObject<Aircraft>(await response.Content.ReadAsStringAsync());


            // assert
            if (configid == 18)
                result.Manufacturer = "boeing";
            else if (configid == 19)
                result.Manufacturer = null;

        }
        
        [Theory(DisplayName = "get all test msu configuration")]
        [InlineData(18, "37abfc59-d95e-49f6-9289-2b3abad33132")]
        [InlineData(19, "3cd9aeb9-564f-41a4-ac03-00ef897f29f7")]
        public async Task GetAllTest(int configid, Guid aircraftid)
        {

            // arrange
            var userRepo = MockUserData();
            var configRepo = MockConfigData(configid);
            var airRepo = new Mock<AircraftRepository>();
            var msuRepo = new Mock<IMsuConfigurationRepository>();
            List<Aircraft> airlist = new List<Aircraft>();
            Aircraft air = new Aircraft();
            air.TailNumber = "str145";
            air.SerialNumber = "12e2";
            air.ConnectivityTypes = "1; 2; 3";
            air.Id = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
            air.InstallationTypeID = Guid.Parse("92632C1C-D321-44FC-AB51-C318248801DB");
            air.IsDeleted = false;
            air.Manufacturer = "boeing";
            air.Model = "LSX800";
            air.CreatedByUserId = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
            air.DateCreated = DateTimeOffset.Now;
            air.OperatorId = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
            air.ThirdPartyRoleID = Guid.Parse("92632C1C-D321-44FC-AB51-C318248801DB");

            List<MsuConfiguration> list = new List<MsuConfiguration>();
            MsuConfiguration msu = new MsuConfiguration();
            msu.Id= Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
            msu.TailNumber = "str145";
            msu.FileName = "new File";
            msu.DateCreated = DateTimeOffset.Now;
            list.Add(msu);

            if (configid == 18)
            {
                airRepo.Setup(c => c.Find(aircraftid.ToString())).Returns(air);
                msuRepo.Setup(c => c.GetAll(aircraftid.ToString())).Returns(Task.FromResult(list));

            }
            else if (configid == 19)
            {
                airRepo.Setup(c => c.Find(aircraftid.ToString())).Returns<Aircraft>(null);
                msuRepo.Setup(c => c.GetAll(aircraftid.ToString())).Returns(Task.FromResult<List<MsuConfiguration>>(null));
            }

            var mockRepos = new Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
            mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
            mockRepos.Setup(c => c.AircraftRepository).Returns(airRepo.Object);
            mockRepos.Setup(c => c.MsuConfigurationRepository).Returns(msuRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);


            // act

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/MsuConfiguration/aircraft/" + aircraftid + "/msuconfigurationslist");
            var result = JsonConvert.DeserializeObject<List<MsuConfigurationDto>>(await response.Content.ReadAsStringAsync());

            //assert
            if (configid == 18)
                result.Count.Should().Be(1);
            else if (configid == 19)
                result.Should().BeNullOrEmpty();

        }


        [Theory(DisplayName = "get  configuration file test")]
        [InlineData(18, "37abfc59-d95e-49f6-9289-2b3abad33132")]
        [InlineData(19, "3cd9aeb9-564f-41a4-ac03-00ef897f29f7")]
        public async Task GetConfigurationFileTest(int configid, Guid aircraftid)
        {
           
                // arrange
                var userRepo = MockUserData();
                var configRepo = MockConfigData(configid);
                var airRepo = new Mock<AircraftRepository>();
                var msuRepo = new Mock<IMsuConfigurationRepository>();
                List<Aircraft> airlist = new List<Aircraft>();
                Aircraft air = new Aircraft();
                air.TailNumber = "str145";
                air.SerialNumber = "12e2";
                air.ConnectivityTypes = "1; 2; 3";
                air.Id = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
                air.InstallationTypeID = Guid.Parse("92632C1C-D321-44FC-AB51-C318248801DB");
                air.IsDeleted = false;
                air.Manufacturer = "boeing";
                air.Model = "LSX800";
                air.CreatedByUserId = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
                air.DateCreated = DateTimeOffset.Now;
                air.OperatorId = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
                air.ThirdPartyRoleID = Guid.Parse("92632C1C-D321-44FC-AB51-C318248801DB");
                List<MsuConfiguration> list = new List<MsuConfiguration>();
                MsuConfiguration msu = new MsuConfiguration();
                msu.Id = Guid.Parse("82C236D7-97FD-4E40-B6C1-021406599BF6");
                msu.TailNumber = "str145";
                msu.FileName = "new File";
                msu.DateCreated = DateTimeOffset.Now;
                list.Add(msu);
                string config = configid.ToString();
                if (configid == 18)
                {
                    airRepo.Setup(c => c.Find(aircraftid.ToString())).Returns(air);
                    msuRepo.Setup(c => c.Find(config)).Returns(msu);

                }
                else if (configid == 19)
                {
                    MsuConfiguration msu1 = new MsuConfiguration();
                    airRepo.Setup(c => c.Find(aircraftid.ToString())).Returns(air);
                    msuRepo.Setup(c => c.Find(config)).Returns(msu1);
                }

                var mockRepos = new Mock<IUnitOfWorkRepository>();
                mockRepos.Setup(c => c.Simple<User>()).Returns(userRepo.Object);
                mockRepos.Setup(c => c.ConfigurationDefinitions).Returns(configRepo.Object);
                mockRepos.Setup(c => c.AircraftRepository).Returns(airRepo.Object);
                mockRepos.Setup(c => c.MsuConfigurationRepository).Returns(msuRepo.Object);
                _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);


                // act

                var client = _factory.CreateAdmin();
                var response = await client.GetAsync("api/MsuConfiguration/aircraft/" + aircraftid + "/msuconfiguration/" + configid);
                var result = JsonConvert.DeserializeObject<MsuConfigurationBody>(await response.Content.ReadAsStringAsync());

                //assert
                if (configid == 18)
                    result.FileName = "new file";
                else if (configid == 19)
                    result.FileName = null;
            
        }
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


    }
}