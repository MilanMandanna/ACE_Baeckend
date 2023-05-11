using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryGeoRef
    {

        public static string SQL_GetExportASXInfoGeoRefSpellings = @"
select 
	* 
from (
    select 
		tblgeoref.*, 
		tbllanguages.[2LetterID_ASXi] as code, 
		tblspelling.unicodestr as spelling,
		tblcitypopulation.population,
		tblelevation.elevation
    from tblgeoref
		inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
		inner join tblspelling on tblspelling.georefid = tblgeoref.georefid
		inner join tblspellingmap on tblspellingmap.spellingid = tblspelling.spellingid
		inner join tbllanguages on tbllanguages.languageid = tblspelling.languageid
		inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.id
		left join tblelevation on tblelevation.georefid = tblgeoref.georefid
		left join tblelevationmap on tblelevationmap.elevationid = tblelevation.id
		left join tblcitypopulation on tblcitypopulation.georefid = tblgeoref.georefid
		left join tblcitypopulationmap on tblcitypopulationmap.citypopulationid = tblcitypopulation.citypopulationid
    where tblgeorefmap.configurationid = @configurationId and tblgeorefmap.isDeleted=0 and
		tblspellingmap.configurationid = @configurationId and tblspellingmap.isDeleted=0 and
		tbllanguagesmap.configurationid = @configurationId and tbllanguagesmap.isDeleted=0 and
		((tblelevationmap.configurationid = @configurationId and tblelevationmap.isDeleted=0) or tblelevationmap.configurationid is null) and
		((tblcitypopulationmap.configurationid = @configurationId and tblcitypopulationmap.isDeleted=0) or tblcitypopulationmap.configurationid is null)
) as sourcetable
pivot(
    max(spelling)
    for code in ({languageCodes})
) as pivottable
order by georefid";

	}
}
