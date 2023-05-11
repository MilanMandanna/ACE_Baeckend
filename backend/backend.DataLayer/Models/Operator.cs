using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models
{
    [DataProperty(TableName = "dbo.Operator")]
    public class Operator
    {
        [DataProperty(PrimaryKey = true)]
        public Guid Id { get; set; }
        [DataProperty]
        public string City { get; set; }
        [DataProperty]
        public int? Code { get; set; }
        [DataProperty]
        public string Company { get; set; }
        [DataProperty]
        public string Country { get; set; }
        [DataProperty]
        public Guid CreatedByUserId { get; set; }
        [DataProperty]
        public DateTimeOffset DateCreated { get; set; }
        [DataProperty]
        public DateTimeOffset DateModified { get; set; }
        [DataProperty]
        public string Email { get; set; }
        [DataProperty]
        public string Fax { get; set; }
        [DataProperty]
        public string FirstName { get; set; }
        [DataProperty]
        public bool IsDeleted { get; set; }
        [DataProperty]
        public string JobTitle { get; set; }
        [DataProperty]
        public string LastName { get; set; }
        [DataProperty]
        public string ModifiedBy { get; set; }
        [DataProperty]
        public string Name { get; set; }
        [DataProperty]
        public string PhoneNumber { get; set; }
        [DataProperty]
        public string PostalCode { get; set; }
        [DataProperty]
        public int? Salutation { get; set; }
        [DataProperty]
        public string SecondaryCity { get; set; }
        [DataProperty]
        public string SecondaryCompany { get; set; }
        [DataProperty]
        public string SecondaryCountry { get; set; }
        [DataProperty]
        public string SecondaryEmail { get; set; }
        [DataProperty]
        public string SecondaryFax { get; set; }
        [DataProperty]
        public string SecondaryFirstName { get; set; }
        [DataProperty]
        public string SecondaryJobTitle { get; set; }
        [DataProperty]
        public string SecondaryLastName { get; set; }
        [DataProperty]
        public string SecondaryPhoneNumber { get; set; }
        [DataProperty]
        public string SecondaryPostalCode { get; set; }
        [DataProperty]
        public int SecondarySalutation { get; set; }
        [DataProperty]
        public string SecondaryState { get; set; }
        [DataProperty]
        public string State { get; set; }
        [DataProperty]
        public string AddressLine2 { get; set; }
        [DataProperty]
        public string SecondaryAddressLine1 { get; set; }
        [DataProperty]
        public string SecondaryAddressLine2 { get; set; }
        [DataProperty]
        public string AddressLine1 { get; set; }
        [DataProperty]
        public bool IsTest { get; set; }
        [DataProperty]
        public Guid ManageRoleID { get; set; }
        [DataProperty]
        public Guid ViewRoleID { get; set; }
    }
}
