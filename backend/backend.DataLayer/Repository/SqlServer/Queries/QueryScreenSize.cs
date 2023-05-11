using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryScreenSize
    {

        public static string SQL_GetExportASXi3DScreenSize = @"
select 
	tblScreenSize.ScreenSizeID as id,
	Description as description
from tblScreenSize
	inner join tblScreenSizeMap on tblScreenSizeMap.ScreenSizeID = tblScreenSize.ScreenSizeID
where
	tblScreenSizeMap.ConfigurationID = @configurationId";

    }
}
