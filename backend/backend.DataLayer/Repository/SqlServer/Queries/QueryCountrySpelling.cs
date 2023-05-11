using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryCountrySpelling
    {
		public static string SQL_GetAllCountrySpellings = @"
select
	*
from 
(
	select 
		CountryID, 
		tblLanguages.[2LetterID_ASXi] AS Code, 
		CountryName 
	from dbo.tblCountrySpelling 
		inner join tblCountrySpellingMap as csmap on csmap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
		inner join tblLanguages on tblLanguages.LanguageID = dbo.tblCountrySpelling.LanguageID 
		inner join tblLanguagesMap as lmap on lmap.LanguageID = tblLanguages.ID
	where
		csmap.ConfigurationID = @configurationId and csmap.isDeleted=0
		and lmap.ConfigurationID = @configurationId and lmap.isDeleted=0
) as sourcetable 
pivot(max(countryname) for Code in ({languageCodes})) as pivottable 
order by countryid;";

	}
}
