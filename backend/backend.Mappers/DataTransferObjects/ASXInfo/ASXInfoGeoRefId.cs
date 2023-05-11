using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXInfo
{
    [DataProperty(TableName = "tbgeorefid")]
    public class ASXInfoGeoRefId
    {
        [DataProperty(PrimaryKey = true)]
        public int GeoRefId { get; set; }

        [DataProperty] 
        public int GeoRefIdCatTypeId { get; set; }
        
        [DataProperty]
        public int RegionId { get; set; }
        
        [DataProperty(NullValue = 0)]
        public int CountryId { get; set; }
        
        [DataProperty(NullValue = 0)] 
        public int Elevation { get; set; }
        
        [DataProperty(NullValue = 0)]
        public int Population { get; set; }

        [DataProperty(NullValue = 0)] 
        public int LayerDisplay { get; set; }
        [DataProperty] 
        public int ISearch { get; set; }

        [DataProperty]
        public int RLIPOI { get; set; }

        [DataProperty] 
        public int IPOI { get; set; }

        [DataProperty] 
        public int WCPOI { get; set; }

        [DataProperty] 
        public int MakkahPOI { get; set; }

        [DataProperty] 
        public int ClosestPOI { get; set; }

        [DataProperty] 
        public double Lat { get; set; }

        [DataProperty] 
        public double Lon { get; set; }

        [DataProperty] 
        public int Inclusion { get; set; }

    }
}
