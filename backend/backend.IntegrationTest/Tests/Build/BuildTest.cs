using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.SqlServer;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using FluentAssertions;
using Moq;
using Newtonsoft.Json;
using Xunit;

namespace backend.IntegrationTest.Tests.Build
{
    public class BuildTest : IClassFixture<ApplicationFactory<backend.Startup>>
    {
        private readonly ApplicationFactory<backend.Startup> _factory;

        public BuildTest(ApplicationFactory<backend.Startup> factory)
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


        private void SetUpMockRepo(Moq.Mock<TaskRepository> taskRepo)
        {
            var mockRepos = new Moq.Mock<IUnitOfWorkRepository>();
            mockRepos.Setup(c => c.Simple<User>()).Returns(GetMockUserRepo().Object);
            mockRepos.Setup(c => c.TaskRepository).Returns(taskRepo.Object);
            _factory.GetMockDatabase().Setup(c => c.Repositories).Returns(mockRepos.Object);
        }

        [Theory(DisplayName = "Builds - GetCurrentBuildTasksForUser")]
        [InlineData("4dbed025-b15f-4760-b925-34076d13a10a",1)]
        public async Task GetCurrentBuildTasksForUser(string id, int expectedResult)
        {
            IEnumerable<BuildEntry> builds;
            List<BuildEntry> buildInfos = new List<BuildEntry>();
            var build = new BuildEntry();
            build.ID = new Guid();
            build.PercentageComplete = 0;
            build.ConfigurationID = 1;
            build.ConfigurationDefinitionID = 1;
            build.ConfigurationVersion = 1;

            buildInfos.Add(build);
            builds = buildInfos;

            var tasksMockRepo = new Moq.Mock<TaskRepository>();

            var userId = new Guid(id);
            tasksMockRepo.Setup(c => c.GetBuildTasksForUser(It.IsAny<Guid>(), It.IsAny<bool>())).Returns(Task.FromResult(builds));

            SetUpMockRepo(tasksMockRepo);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/user/currentbuilds");
            var result = JsonConvert.DeserializeObject<List<BuildEntry>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Builds - GetAllBuildTasksForUser")]
        [InlineData("4dbed025-b15f-4760-b925-34076d13a10a", 1)]
        public async Task GetAllBuildTasksForUser(string id, int expectedResult)
        {
            IEnumerable<BuildEntry> builds;
            List<BuildEntry> buildInfos = new List<BuildEntry>();
            var build = new BuildEntry();
            build.ID = new Guid();
            build.PercentageComplete = 0;
            build.ConfigurationID = 1;
            build.ConfigurationDefinitionID = 1;
            build.ConfigurationVersion = 1;

            buildInfos.Add(build);
            builds = buildInfos;

            var tasksMockRepo = new Moq.Mock<TaskRepository>();

            var userId = new Guid(id);
            tasksMockRepo.Setup(c => c.GetBuildTasksForUser(It.IsAny<Guid>(), It.IsAny<bool>())).Returns(Task.FromResult(builds));

            SetUpMockRepo(tasksMockRepo);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/user/allbuilds");
            var result = JsonConvert.DeserializeObject<List<BuildEntry>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);

        }

        [Theory(DisplayName = "Builds - GetErrorLog")]
        [InlineData("893252a8-c80d-41ee-81fc-11c5b477d778", "error")]
        public async Task GetErrorLog(string id,string error)
        {
            var tasksMockRepo = new Moq.Mock<TaskRepository>();

            tasksMockRepo.Setup(c => c.GetErrorLog(It.IsAny<Guid>())).Returns(Task.FromResult("error log"));

            SetUpMockRepo(tasksMockRepo);

            var client = _factory.CreateAdmin();
            var response = await client.GetAsync("api/build/"+id+"/errorlog");
            var result = response.Content.ReadAsStringAsync().Result;
            result.Should().Equals(error);
        }

        [Theory(DisplayName = "Builds - CancelBuild")]
        [InlineData("893252a8-c80d-41ee-81fc-11c5b477d778", 1)]
        [InlineData("893252a8-c80d-41ee-81fc-11c5b477d778", 0)]

        public async Task CancelBuild(string id, int expectedResult)
        { 
            var tasksMockRepo = new Moq.Mock<TaskRepository>();

            tasksMockRepo.Setup(c => c.CancelBuild(It.IsAny<Guid>())).Returns(Task.FromResult(expectedResult));

            SetUpMockRepo(tasksMockRepo);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/build/" + id + "/cancel",null);
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

        [Theory(DisplayName = "Builds - DeleteBuild")]
        [InlineData("893252a8-c80d-41ee-81fc-11c5b477d778", 1)]
        [InlineData("893252a8-c80d-41ee-81fc-11c5b477d778", 0)]

        public async Task DeleteBuild(string id, int expectedResult)
        {
            var tasksMockRepo = new Moq.Mock<TaskRepository>();

            tasksMockRepo.Setup(c => c.DeleteBuild(It.IsAny<Guid>())).Returns(Task.FromResult(expectedResult));

            SetUpMockRepo(tasksMockRepo);

            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/build/" + id + "/delete", null);
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

        [Theory(DisplayName = "Builds - BuildProgress")]
        [InlineData(2)]
        [InlineData(0)]

        public async Task BuildProgress( int expectedResult)
        {
            IEnumerable<BuildProgress> builds;

            var progresses = new List<BuildProgress>();
            var progress1 = new BuildProgress();
            progress1.ID = new Guid();
            progress1.PercentageComplete = 0;


            var progress2 = new BuildProgress();
            progress2.ID = new Guid();
            progress2.PercentageComplete = 0;

            progresses.Add(progress1);
            progresses.Add(progress2);
            builds = progresses;

            var taskIds = new List<string>();
            taskIds.Add("893252a8-c80d-41ee-81fc-11c5b477d778");
            taskIds.Add("893252a8-c80d-41ee-81fc-11c5b477d778");

            var tasksMockRepo = new Moq.Mock<TaskRepository>();
            if (expectedResult > 0)
            {
                tasksMockRepo.Setup(c => c.GetBuildProgress(It.IsAny<string[]>())).Returns(Task.FromResult(builds));
            } else 
            {
                progresses.Clear();
                builds = progresses;
                tasksMockRepo.Setup(c => c.GetBuildProgress(It.IsAny<string[]>())).Returns(Task.FromResult(builds));

            }

            SetUpMockRepo(tasksMockRepo);


            var httpContent = JsonConvert.SerializeObject(taskIds);
            var buffer = System.Text.Encoding.UTF8.GetBytes(httpContent);
            var byteContent = new ByteArrayContent(buffer);
            byteContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");


            var client = _factory.CreateAdmin();
            var response = await client.PostAsync("api/build/buildprogress", byteContent);
            var result = JsonConvert.DeserializeObject<List<BuildProgress>>(await response.Content.ReadAsStringAsync());
            result.Count.Should().Be(expectedResult);
        }



    }
}
