using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.User
{
    public class FormCreateUserDTO
    {
        public string Company { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public bool IsSubscribedForNewsLetter { get; set; }
        public string LastName { get; set; }
        public DateTimeOffset LastResetDate { get; set; }
        public string UserName { get; set; }
    }
}
