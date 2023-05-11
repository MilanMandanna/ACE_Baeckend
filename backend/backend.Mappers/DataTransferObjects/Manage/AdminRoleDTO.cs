using backend.DataLayer.Models.Roles_Claims;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Manage
{
    public class AdminRoleDTO
    {
        public Guid ID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public bool Hidden { get; set; }
        public bool ThirdParty { get; set; }
        public IEnumerable<AdminClaimDTO> Claims { get; set; }
    }
}
