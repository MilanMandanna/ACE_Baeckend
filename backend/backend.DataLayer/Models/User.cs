using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Authorization;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models
{
    [DataProperty(TableName = "dbo.AspNetUsers")]
    public class User
    {
        [DataProperty(PrimaryKey = true)]
        public Guid Id { get; set; }
        [DataProperty]
        public DateTimeOffset DateCreated { get; set; }
        [DataProperty]
        public DateTimeOffset DateModified { get; set; }
        [DataProperty]
        public string Fax { get; set; }
        [DataProperty]
        public string FirstName { get; set; }
        [DataProperty]
        public bool IsDeleted { get; set; }
        [DataProperty]
        public bool IsPasswordChangeRequired { get; set; }
        [DataProperty]
        public bool IsRememberMe { get; set; }
        [DataProperty]
        public bool IsSubscribedForNewsLetter { get; set; }
        [DataProperty]
        public bool IsSystemUser { get; set; }
        [DataProperty]
        public string LastName { get; set; }
        [DataProperty]
        public string Company { get; set; }
        [DataProperty]
        public DateTimeOffset LastResetDate { get; set; }
        [DataProperty]
        public string ModifiedBy { get; set; }
        [DataProperty]
        public Guid ResetToken { get; set; }
        [DataProperty]
        public int ResetTokenExpirationTime { get; set; }
        [DataProperty]
        public Guid SelectedOperatorId { get; set; }
        [DataProperty]
        public string Email { get; set; }
        [DataProperty]
        public bool EmailConfirmed { get; set; }
        [DataProperty]
        public string PasswordHash { get; set; }
        [DataProperty]
        public string SecurityStamp { get; set; }
        [DataProperty]
        public string PhoneNumber { get; set; }
        [DataProperty]
        public bool PhoneNumberConfirmed { get; set; }
        [DataProperty]
        public bool TwoFactorEnabled { get; set; }
        [DataProperty]
        public DateTime LockoutEndDateUtc { get; set; }
        [DataProperty]
        public bool LockoutEnabled { get; set; }
        [DataProperty]
        public int AccessFailedCount { get; set; }
        [DataProperty]
        public string UserName { get; set; }

        public PortalClaimsCollection Claims;

    }
}
