using backend.BusinessLayer.Contracts;
using backend.Controllers;
using backend.DataLayer.Models;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.User;
using Moq;
using NUnit.Framework;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.Test
{
    public class UserControllerTest
    {
        private UserController _userController;

        //Mock objects for Dependencies
        private Mock<IUserService> _userServiceMock;
        private Mock<ILoggerManager> _loggerManagerMock;

        //Mock objects for Models
        private Mock<UserListDTO> _userMock;
        private Task<IEnumerable<UserListDTO>> _users;

        //Setup the common initializations & mocking
        [SetUp]
        public void Setup()
        {
            _userServiceMock = new Mock<IUserService>();
            _loggerManagerMock = new Mock<ILoggerManager>();

            //Prepare mock data
            _userMock = new Mock<UserListDTO>();
            _userMock.Object.FirstName = "Test User";
            var users = new List<UserListDTO>()
            {
                _userMock.Object
            };
            _users = new Task<IEnumerable<UserListDTO>>(users.AsEnumerable);
            //Mock the service method
            _userServiceMock.Setup(c => c.GetAllUsers()).Returns(_users);

            //Create Controller Instance
            _userController = new UserController(_userServiceMock.Object, _loggerManagerMock.Object);
        }

        //Test Method
        [Test]
        public void ShouldReturnUsers()
        {
            //setup

            //act
            var result = _userController.GetAllUsers();

            //assert
            Assert.AreEqual("Test User", result.Result);
        }
    }
}