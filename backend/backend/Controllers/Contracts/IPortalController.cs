using backend.DataLayer.Authentication;
using backend.DataLayer.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using backend.Mappers.DataTransferObjects.User;

namespace backend.Controllers
{
    public interface IPortalController
    {
        public UserListDTO GetCurrentUser();

        public PortalJWTPayload GetToken();

        public bool HasClaim(string claimType, string scope = "");

        public bool HasInstanceOfClaim(string claimType);

    }
}
