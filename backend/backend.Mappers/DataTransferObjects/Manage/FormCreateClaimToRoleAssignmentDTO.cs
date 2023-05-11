using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Manage
{
    public class FormCreateClaimToRoleAssignmentDTO
    {
        public Guid RoleID { get; set; }
        public Guid ClaimID { get; set; }
    }
}
