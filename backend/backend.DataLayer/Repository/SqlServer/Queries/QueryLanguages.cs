using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryLanguages
    {
		public static string SQL_GetExportAS4000Languages = @"
select
	tblLanguages.LanguageID,
	Name,
	tblLanguages.[2LetterID_4xxx] as '2LetterID',
	tblLanguages.[3LetterID_4xxx] as '3LetterID',
	HorizontalOrder,
	HorizontalScroll,
	VerticalOrder,
	VerticalScroll,
	case 
		when tblLanguages.LanguageID = 1 then 'ENGLISH'
		else 'METRIC'
	end as UnitType,
	case
		when tblLanguages.LanguageID = 1 then 'HOUR12'
		else 'HOUR24'
	end as TimeType
from tblLanguages
	inner join tblLanguagesMap as lmap on lmap.LanguageID = tblLanguages.ID
where
	lmap.ConfigurationID = @configurationId
order by tblLanguages.LanguageID";

		public static string SQL_GetExportASXi3DLanguages = @"
select 
	tblLanguages.LanguageID,
	tblLanguages.Name,
	tblLanguages.[2LetterID_ASXi] as TwoLetterID,
	tblLanguages.[3LetterID_ASXi] as ThreeLetterID,
	HorizontalOrder,
	HorizontalScroll,
	VerticalOrder,
	VerticalScroll
from tbllanguages
	inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.ID
where
	lmap.ConfigurationID = @configurationId
order by tbllanguages.languageid";

	}
}
