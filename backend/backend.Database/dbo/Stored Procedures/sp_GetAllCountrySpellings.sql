GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetAllCountrySpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetAllCountrySpellings]
END
GO
CREATE PROC sp_GetAllCountrySpellings
@configurationId INT,
@languageCodes NVARCHAR(MAX)
AS
BEGIN

DECLARE @sql NVARCHAR(MAX)
SET @sql = 'select
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
		csmap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ' and csmap.isDeleted=0
		and lmap.ConfigurationID = ' + CAST(@configurationId AS NVARCHAR) + ' and lmap.isDeleted=0
) as sourcetable 
pivot(max(countryname) for Code in (' + @languageCodes + ')) as pivottable 
order by countryid;'

EXEC (@sql)

END

GO