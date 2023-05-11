GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetAS4000CountrySpellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetAS4000CountrySpellings]
END
GO
CREATE PROC sp_GetAS4000CountrySpellings
@configurationId INT
AS
BEGIN

select 
	tblCountry.CountryID, 
	CountryCode,
    CountryName, 
	LanguageId
from dbo.tblCountrySpelling 
	inner join tblcountryspellingmap on tblcountryspellingmap.CountrySpellingID = dbo.tblCountrySpelling.CountrySpellingID
	RIGHT JOIN dbo.tblCountry ON dbo.tblCountrySpelling.CountryId = dbo.tblCountry.CountryId
	inner join dbo.tblCountryMap on dbo.tblCountryMap.CountryID = dbo.tblCountry.CountryID
where
	tblCountrySpellingMap.ConfigurationID = @configurationId and tblCountrySpellingMap.IsDeleted=0
	and tblCountryMap.ConfigurationID = @configurationId and tblCountryMap.IsDeleted=0

END

GO