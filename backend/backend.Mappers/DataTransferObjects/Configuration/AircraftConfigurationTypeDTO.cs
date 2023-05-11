using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class AircraftConfigurationTypeDTO
    {
        public Product Product { get; set; }
        public Platform Platform { get; set; }
    }
}
