using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Manage
{
    public class FormRemoveClaimToRoleAssignmentDTO
    {
        public Guid RoleID { get; set; }
        public Guid ClaimID { get; set; }
    }
}
