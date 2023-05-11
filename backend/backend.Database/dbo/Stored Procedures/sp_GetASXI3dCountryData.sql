GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetASXI3dCountryData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetASXI3dCountryData]
END
GO
CREATE PROC sp_GetASXI3dCountryData
@configurationId INT,
@languages VARCHAR(MAX)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)
SET @sql='select 
	*
from (
    select 
		tblcountry.CountryID,
		tblcountry.CustomChangeBitMask as CustomChangeBit,
		tblCountrySpelling.CountryName,
		tblLanguages.[2LetterID_ASXi] as code
    from tblcountry
		inner join tblCountrySpelling on tblcountry.CountryID = tblcountryspelling.CountryID
		inner join tblLanguages on tblLanguages.LanguageID = tblCountrySpelling.LanguageID
		inner join tblcountrymap as cmap on cmap.CountryID = tblcountry.CountryID
		inner join tblCountrySpellingMap as csmap on csmap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
		inner join tbllanguagesmap as lmap on lmap.languageid = tbllanguages.id
    where
		cmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and cmap.IsDeleted=0 and
		csmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and csmap.IsDeleted=0 and
		lmap.ConfigurationID = '+Cast(@configurationId AS NVARCHAR)+' and lmap.IsDeleted=0
) as sourcetable
pivot(
    max(CountryName)
    for code in ('+@languages+')
) as pivottable
order by CountryID'

EXECUTE sp_executesql @sql;

END

GO