using CsvHelper.Configuration;


namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class AllAirportsDTO
    {
        public string Ident { get; set; }
        public string IataCode { get; set; }
        public string LocalCode { get; set; }
        public string Name { get; set; }
        public string Type { get; set; }
        public string Municipality { get; set; }
    }

    public class AllAirportsDTOMap : ClassMap<AllAirportsDTO>
    {
        public AllAirportsDTOMap()
        {
            Map(m => m.Ident).Name("ident");
            Map(m => m.IataCode).Name("iata_code");
            Map(m => m.LocalCode).Name("local_code");
            Map(m => m.Name).Name("name");
            Map(m => m.Type).Name("type");
            Map(m => m.Municipality).Name("municipality");
        }
    }
}
