using CsvHelper.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class UnCityPopulationDTO
    {
            public string Country { get; set; }

            public int Year { get; set; }

            public string Sex { get; set; }

            public int CityCode { get; set; }

            public string City { get; set; }

            public string CityType { get; set; }

            public double Population { get; set; }

        }
        public class UnCityPopulationDTOMap : ClassMap<UnCityPopulationDTO>
        {
            public UnCityPopulationDTOMap()
            {
                Map(m => m.Country).Name("Country or Area");
                Map(m => m.Year).Name("Year");
                Map(m => m.Sex).Name("Sex");
                Map(m => m.CityCode).Name("Code of City");
                Map(m => m.City).Name("City");
                Map(m => m.Population).Name("Value");
                Map(m => m.CityType).Name("City type");
            }
        }
}
