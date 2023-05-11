using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.CollinsAdminOnlyFeatures
{
    public class GlobalPlaceNamesDataDTO
    {
        public string Lat { get; set; }
        public string Long { get; set; }

        public string CityName { get; set; }

        //This will provide a base set of BGN (Board of Geographic Names) standard names only.
        //This will be the primary dataset from which placenames will be selected.  It may be helpful to completely delete records that do not have “N”.
        public string BGNFilter { get; set; }
    }
}
