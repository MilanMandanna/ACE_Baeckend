-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns Details of the region as name of the region in all the selected languages
-- =============================================
IF OBJECT_ID('[dbo].[SP_Region_GetDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_GetDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_GetDetails]
	@configurationId int,
    @regionId int
AS
BEGIN
   
   CREATE TABLE #tmpSelectedLanguages
(
	[RowNum] int not null,
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

    SELECT regionSpelling.RegionID,
	regionSpelling.SpellingID,
	regionSpelling.LanguageID,
	Name as Language,
	regionSpelling.RegionName

    FROM dbo.config_tblRegionSpelling(@configurationId) as regionSpelling
    inner join #tmpSelectedLanguages ON #tmpSelectedLanguages.LanguageID = regionSpelling.LanguageID
    WHERE regionSpelling.RegionId = @regionId ORDER BY #tmpSelectedLanguages.RowNum ASC

    DROP TABLE #tmpSelectedLanguages
END

GO