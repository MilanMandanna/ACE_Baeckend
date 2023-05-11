using backend.DataLayer.Authentication;
using backend.DataLayer.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using backend.Mappers.DataTransferObjects.User;

namespace backend.Controllers
{
    /**
     * Base controller class that most of the controllers should inherit from. Subclassed controllers
     * will get easier access to to the CurrentUser that was authenticated for authorized apis as well
     * as can access the authorization token. Not necessary to subclass but these provide easier to use
     * APIs for that information.
     **/
    public abstract class PortalController : Controller, IPortalController
    {
        public UserListDTO GetCurrentUser()
        {
            return (UserListDTO) HttpContext.Items["InternalUser"];
        }

        public PortalJWTPayload GetToken()
        {
            return (PortalJWTPayload) HttpContext.Items["JWTPayload"];
        }

        public bool HasClaim(string claimType, string scope = "")
        {
            return false;
        }   
        
        public bool HasInstanceOfClaim(string claimType) 
        {
            if (!IsAuthenticated()) return false;
            UserListDTO user = GetCurrentUser();
            return user.Claims.HasInstanceOfClaim(claimType);
        }

        public bool IsAuthenticated()
        {
            return GetCurrentUser() != null && GetToken() != null;
        }
    }


}
