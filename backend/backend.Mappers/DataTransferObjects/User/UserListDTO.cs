using backend.DataLayer.Models.Authorization;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.User
{
    public class UserListDTO
    {
        public Guid Id { get; set; }
        public DateTimeOffset DateCreated { get; set; }
        public string Fax { get; set; }
        public string FirstName { get; set; }
        public bool IsDeleted { get; set; }
        public bool IsPasswordChangeRequired { get; set; }
        public bool IsRememberMe { get; set; }
        public bool IsSubscribedForNewsLetter { get; set; }
        public bool IsSystemUser { get; set; }
        public string LastName { get; set; }
        public string Company { get; set; }
        public Guid SelectedOperatorId { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public string UserName { get; set; }

        public PortalClaimsCollection Claims;
    }
}
