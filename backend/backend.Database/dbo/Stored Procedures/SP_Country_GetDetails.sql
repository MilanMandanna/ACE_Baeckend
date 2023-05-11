-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns Details of the country as name of the country in all the selected languages
-- =============================================
IF OBJECT_ID('[dbo].[SP_Country_GetDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_GetDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_GetDetails]
	@configurationId int,
    @countryId int
AS
BEGIN
   
   CREATE TABLE #tmpSelectedLanguages
(	[RowNum] int not null,
    [ID] int NOT NULL ,
	[LanguageID] int NOT NULL,	
	[Name] nvarchar(100) NULL,	
	[NativeName] nvarchar(100) NULL,
	[Description] nvarchar(255) NULL,
	[ISLatinScript] bit NULL,
	[Tier] smallint NULL,	
	[2LetterID_4xxx] nvarchar(50) NULL,	
	[3LetterID_4xxx] nvarchar(50) NULL,	
	[2LetterID_ASXi] nvarchar(50) NULL,	
	[3LetterID_ASXi] nvarchar(50) NULL,
	[HorizontalOrder] smallint NULL DEFAULT 0,
	[HorizontalScroll] smallint NULL DEFAULT 0,	
	[VerticalOrder] smallint NULL DEFAULT 0,
	[VerticalScroll] smallint NULL DEFAULT 0
);
    INSERT INTO #tmpSelectedLanguages EXEC cust.SP_Global_GetSelectedLanguages @configurationId

    SELECT countrySpelling.CountryID,
	country.Description,
	country.RegionID,
	countrySpelling.CountrySpellingID,
	countrySpelling.LanguageID,
	Name as Language,
	countrySpelling.CountryName

    FROM dbo.config_tblCountrySpelling(@configurationId) as countrySpelling
    inner join #tmpSelectedLanguages ON #tmpSelectedLanguages.LanguageID = countrySpelling.LanguageID
	inner join dbo.config_tblCountry(@configurationId) as country ON country.CountryID = countrySpelling.CountryID
    WHERE countrySpelling.CountryID = country.CountryID and country.ID=@countryId ORDER BY #tmpSelectedLanguages.RowNum ASC

    DROP TABLE #tmpSelectedLanguages
END

GO