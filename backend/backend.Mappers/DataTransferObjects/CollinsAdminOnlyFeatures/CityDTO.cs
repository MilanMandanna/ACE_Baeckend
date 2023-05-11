using System;
using System.Collections.Generic;
using System.Text;
using CsvHelper.Configuration;

namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class CityDTO
    {
        public string City { get; set; }
        public string Population { get; set; }
    }
    public class CityDTOMap : ClassMap<CityDTO>    {
        public CityDTOMap()
        {
            Map(m => m.City).Name("City");
            Map(m => m.Population).Name("Population");
        }
    }
}
