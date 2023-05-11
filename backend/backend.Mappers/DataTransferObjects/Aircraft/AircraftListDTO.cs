using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Aircraft
{
    public class AircraftListDTO
    {
        public Guid Id { get; set; }
        public string Manufacturer { get; set; }
        public string Model { get; set; }
        public string SerialNumber { get; set; }
        public string TailNumber { get; set; }
        public Guid OperatorId { get; set; }
        public string ImageURL { get; set; }
        public bool isReadOnly { get; set; }
        public Guid CreatedByUserId { get; set; }
        public Guid ThirdPartyRoleID { get; set; }
        public Guid InstallationTypeID { get; set; }

    }
}
