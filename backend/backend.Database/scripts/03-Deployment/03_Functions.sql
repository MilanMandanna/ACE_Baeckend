
GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblAppearance]
GO
/****** Object:  UserDefinedFunction [dbo].[config_tblAppearance]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 12/12/2022
-- Description:	Function returns the tblAppearance data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblAppearance
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblAppearance.*
	from tblAppearance 
		inner join tblAppearanceMap on tblAppearanceMap.AppearanceID = tblAppearance.AppearanceID
	where tblAppearanceMap.ConfigurationID = @configurationId
		and tblAppearanceMap.isDeleted = 0
)
GO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
drop function if exists dbo.config_tblCountry

GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 21/03/2022
-- Description:	Function returns the country data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblCountry
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblCountry.*
	from tblCountry 
		inner join tblCountryMap on tblCountryMap.CountryID = tblCountry.ID
	where tblCountryMap.ConfigurationID = @configurationId
		and tblCountryMap.IsDeleted = 0
)
GO

GO

GO
DROP FUNCTION IF EXISTS dbo.config_tblCoverageSegment
GO
-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 28/06/2022
-- Description:	Function returns the CoverageSegment data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblCoverageSegment
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblCoverageSegment.*
	from tblCoverageSegment 
		inner join tblCoverageSegmentMap on tblCoverageSegmentMap.CoverageSegmentID = tblCoverageSegment.ID
	where tblCoverageSegmentMap.ConfigurationID = @configurationId
		and tblCoverageSegmentMap.isDeleted = 0
)
GO

GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblGeoRef]
GO
/****** Object:  UserDefinedFunction [dbo].[config_tblGeoRef]    Script Date: 3/17/2022 5:24:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 21/03/2022
-- Description:	Function returns the Georef data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblGeoRef
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select
		tblGeoRef.*
	from tblGeoRef	
		inner join tblGeoRefMap on tblGeoRefMap.GeoRefID = tblGeoRef.ID
	where tblGeorefMap.ConfigurationID = @configurationId
		and tblgeorefmap.isdeleted = 0
)

GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblImage]
GO
/****** Object:  UserDefinedFunction [dbo].[config_tblImage] */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 28/05/2022
-- Description:	Function returns the image data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblImage
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select
		tblImage.*
	from tblImage	
		inner join tblImageMap on tblImageMap.ImageId = tblImage.ImageId
	where tblImageMap.ConfigurationID = @configurationId
		and tblImageMap.isdeleted = 0
)

GO

drop function if exists config_tblInfoSpelling
go
CREATE FUNCTION config_tblInfoSpelling
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblInfoSpelling.*
	from tblInfoSpelling 
		inner join tblInfoSpellingMap on tblInfoSpellingMap.InfoSpellingId = tblInfoSpelling.InfoSpellingId
	where tblInfoSpellingMap.ConfigurationID = @configurationId
		and tblInfoSpellingmap.isDeleted = 0
)
GO
GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblLanguage]
GO
CREATE FUNCTION [dbo].[config_tblLanguage]
(@configurationId int  )
RETURNS TABLE
AS
RETURN
(
select  
  tblLanguages.*  
 from tblLanguages   
  inner join tblLanguagesMap on tblLanguagesMap.LanguageID = tblLanguages.LanguageID  
 where tblLanguagesMap.ConfigurationID = @configurationId  
  and tblLanguagesMap.isdeleted = 0 
)
GO
GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblRegion]
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Function returns the region data for given configuration id
-- =============================================
CREATE FUNCTION [dbo].[config_tblRegion]
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblRegionSpelling.*
	from tblRegionSpelling 
		inner join tblRegionSpellingMap on tblRegionSpellingMap.SpellingID = tblRegionSpelling.SpellingID
	where tblRegionSpellingMap.ConfigurationID = @configurationId
		and tblRegionSpellingMap.IsDeleted = 0
)
GO
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.config_tblRegionSpelling') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[config_tblRegionSpelling]
END
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 1/08/2022
-- Description:	Function returns the tblRegionSpelling data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblRegionSpelling
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblRegionSpelling.*
	from tblRegionSpelling 
		inner join tblRegionSpellingMap on tblRegionSpellingMap.SpellingID = tblRegionSpelling.SpellingID
	where tblRegionSpellingMap.ConfigurationID = @configurationId
		and tblRegionSpellingMap.isDeleted = 0
)
GO

GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblAirportInfo]
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 21/03/2022
-- Description:	Function returns the Airport data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblAirportInfo
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblAirportInfo.*
	from tblAirportInfo 
		inner join tblAirportInfoMap on tblAirportInfoMap.AirportInfoID = tblAirportInfo.AirportInfoID
	where tblAirportInfoMap.ConfigurationID = @configurationId
		and tblairportinfomap.isDeleted = 0
)
GO

GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblASXiInset]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 19/05/2022
-- Description:	Function returns the inset data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblASXiInset
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblASXiInset.*
	from tblASXiInset 
		inner join tblASXiInsetMap on tblASXiInsetMap.ASXiInsetID = tblASXiInset.ASXiInsetID
	where tblASXiInsetMap.ConfigurationID = @configurationId
		and tblASXiInsetMap.IsDeleted = 0 
)
GO

GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblConfigurationComponents]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 21/03/2022
-- Description:	Function returns the tConfiguration Components data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblConfigurationComponents
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select 
		tblConfigurationComponents.*
	from tblConfigurationComponents 
		inner join tblConfigurationComponentsMap on tblConfigurationComponentsMap.ConfigurationComponentID = tblConfigurationComponents.ConfigurationComponentID
	where tblConfigurationComponentsMap.ConfigurationID = @configurationId
		and tblConfigurationComponentsMap.IsDeleted = 0
)
GO

GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.config_tblCountrySpelling') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[config_tblCountrySpelling]
END
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 1/08/2022
-- Description:	Function returns the tblCountrySpelling data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblCountrySpelling
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblCountrySpelling.*
	from tblCountrySpelling 
		inner join tblCountrySpellingMap on tblCountrySpellingMap.CountrySpellingID = tblCountrySpelling.CountrySpellingID
	where tblCountrySpellingMap.ConfigurationID = @configurationId
		and tblCountrySpellingMap.isDeleted = 0
)
GO

GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblFontFamily]
GO
/****** Object:  UserDefinedFunction [dbo].[config_tblFontFamily]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 12/12/2022
-- Description:	Function returns the tblFont data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblFontFamily
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblFontFamily.*
	from tblFontFamily 
		inner join tblFontFamilyMap on tblFontFamilyMap.FontFamilyID = tblFontFamily.FontFamilyID
	where tblFontFamilyMap.ConfigurationID = @configurationId
		and tblFontFamilyMap.isDeleted = 0
)

GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.config_tblFontMarker') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[config_tblFontMarker]
END
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 12/07/2022
-- Description:	Function returns the tblFontMarker data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblFontMarker
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblFontMarker.*
	from tblFontMarker 
		inner join tblFontMarkerMap on tblFontMarkerMap.FontMarkerID = tblFontMarker.FontMarkerID
	where tblFontMarkerMap.ConfigurationID = @configurationId
		and tblFontMarkermap.isDeleted = 0
)
GO

GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 12/07/2022
-- Description:	Function returns the tblFont data for given configuration id
-- =============================================
DROP FUNCTION IF EXISTS dbo.config_tblFont
GO

CREATE FUNCTION dbo.config_tblFont
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblFont.*
	from tblFont 
		inner join tblFontMap on tblFontMap.FontID = tblFont.FontID
	where tblFontMap.ConfigurationID = @configurationId
		and tblFontmap.isDeleted = 0
)
GO

GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblInfoSpelling]
GO
-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Lakshmikanth G R  
-- Create date: 20/07/2022  
-- Description: Function returns the tblInfoSpelling data for given configuration id  
-- =============================================  
CREATE FUNCTION dbo.config_tblInfoSpelling  
(   
 @configurationId int  
)  
RETURNS TABLE   
AS  
RETURN   
(  
 -- Add the SELECT statement with parameter references here  
 select   
  tblInfoSpelling.*  
 from tblInfoSpelling   
  inner join tblInfoSpellingMap on tblInfoSpellingMap.InfoSpellingID = tblInfoSpelling.InfoSpellingId  
 where tblInfoSpellingMap.ConfigurationID = @configurationId  
  and tblInfoSpellingMap.isDeleted = 0  
) 
GO 
GO

GO
DROP FUNCTION IF EXISTS [dbo].[config_tblFontCategory]
GO
-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 28/06/2022
-- Description:	Function returns the tblFontCategory data for given configuration id
-- =============================================
CREATE FUNCTION dbo.config_tblFontCategory
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblFontCategory.*
	from tblFontCategory 
		inner join tblFontCategoryMap on tblFontCategoryMap.FontCategoryID = tblFontCategory.FontCategoryID
	where tblFontCategoryMap.ConfigurationID = @configurationId
		and tblFontCategorymap.isDeleted = 0
)
GO

GO

-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 20-June-2022
-- Description:	Function to retrieve category ID for AS4XXX based on ASXI4/5 category ID
-- Sample SELECT [dbo].[FN_GetCatValuesBasedOnASXICatValues](11)
-- =============================================

IF OBJECT_ID (N'[dbo].[FN_GetCatValuesBasedOnASXICatValues]', N'FN') IS NOT NULL  
    DROP FUNCTION [dbo].[FN_GetCatValuesBasedOnASXICatValues];  
GO 
CREATE FUNCTION [dbo].[FN_GetCatValuesBasedOnASXICatValues]
	(@asxiCatID INT)
RETURNS INT
AS
BEGIN
	DECLARE @categoryId INT

	IF (@asxiCatID = 1)
		SET @categoryId = 1
	ELSE IF (@asxiCatID = 2)
		SET @categoryId = 3
	ELSE IF (@asxiCatID = 3 OR @asxiCatID = 4 OR @asxiCatID = 11 OR @asxiCatID = 12 OR @asxiCatID = 13 OR @asxiCatID = 14)
		SET @categoryId = 2
	ELSE IF (@asxiCatID = 5)
		SET @categoryId = 4
	ELSE IF (@asxiCatID = 6)
		SET @categoryId = 5
	ELSE IF (@asxiCatID = 7)
		SET @categoryId = 6
	ELSE IF (@asxiCatID = 8)
		SET @categoryId = 7
	ELSE IF (@asxiCatID = 9  OR @asxiCatID = 15 OR @asxiCatID = 16)
		SET @categoryId = 8
	ELSE IF (@asxiCatID = 10)
		SET @categoryId = 9
	ELSE SET @categoryId = 1

	RETURN @categoryId
END

GO

-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 19-Sep-2022
-- Description:	Function to get all values from modlist table
-- Sample SELECT * from [dbo].[FN_GetModListValues](67, 1)
-- =============================================

IF EXISTS (SELECT 1
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[dbo].[FN_GetModListValues]')
                  AND TYPE IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
    DROP FUNCTION [dbo].[FN_GetModListValues];  
GO 
CREATE FUNCTION [dbo].[FN_GetModListValues]
	(
		@configurationId INT,
		@isDirty BIT
	)
	RETURNS TABLE 
AS
RETURN 
(
	SELECT M.*
	FROM tblModList M
		INNER JOIN tblModListMap MM
	ON M.ModlistID = MM.ModlistID
	WHERE MM.ConfigurationID = @configurationId AND M.isDirty = @isDirty AND MM.IsDeleted = 0 AND M.FileJSON IS NOT NULL
)
GO

GO
DROP FUNCTION IF EXISTS [dbo].[SplitString]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      Item NVARCHAR(1000)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT
 
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
 
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
           
            INSERT INTO @Output(Item)
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
           
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END
 
      RETURN
END
GO

GO

GO
DROP FUNCTION IF EXISTS config_tblFlyOverAlert
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 10/10/2022
-- Description:	Function returns the FlyOverAlert data for given configuration id
-- =============================================
CREATE FUNCTION config_tblFlyOverAlert
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT F.* FROM cust.tblFlyOverAlert F
	INNER JOIN cust.tblFlyOverAlertMap FM ON F.FlyOverAlertID = FM.FlyOverAlertID
	WHERE FM.ConfigurationID = @configurationId AND FM.IsDeleted = 0
)
GO
GO

GO
DROP FUNCTION IF EXISTS cust.config_tblMakkah
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the Makkah data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblMakkah
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblMakkah.*
	from cust.tblMakkah 
		inner join cust.tblMakkahMap on cust.tblMakkahMap.MakkahID = cust.tblMakkah.MakkahID
	where cust.tblMakkahMap.ConfigurationID = @configurationId
		and cust.tblMakkahMap.isDeleted = 0

)
GO

GO

GO
DROP FUNCTION IF EXISTS config_tblMaps
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 10/10/2022
-- Description:	Function returns the Maps data for given configuration id
-- =============================================
CREATE FUNCTION config_tblMaps
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT M.* FROM cust.tblMaps M
	INNER JOIN cust.tblMapsMap MM ON M.MapID = MM.MapID
	WHERE MM.ConfigurationID = @configurationId AND MM.IsDeleted = 0
)
GO
GO

GO
DROP FUNCTION IF EXISTS cust.config_tblMenu
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the Menu data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblMenu
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblMenu.*
	from tblMenu 
		inner join tblMenuMap on tblMenuMap.MenuID = tblMenu.MenuID
	where tblMenuMap.ConfigurationID = @configurationId
		and tblMenuMap.isDeleted = 0
)
GO

GO

GO
DROP FUNCTION IF EXISTS cust.config_tblRLI
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the RLI data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblRLI
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblRli.*
	from cust.tblRli 
		inner join cust.tblRLIMap on cust.tblRLIMap.RLIID = cust.tblRli.RLIID
	where cust.tblRLIMap.ConfigurationID = @configurationId
		and cust.tblRLIMap.isDeleted = 0

)
GO

GO

GO
DROP FUNCTION IF EXISTS cust.config_tblWebmain
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the Webmain data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblWebmain
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblWebMain.*
	from cust.tblWebMain 
		inner join cust.tblWebMainMap on cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
	where cust.tblWebMainMap.ConfigurationID = @configurationId
		and cust.tblWebMainMap.isDeleted = 0

)
GO

GO

GO
DROP FUNCTION IF EXISTS cust.config_tblWorldClockCities
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the world clock city data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblWorldClockCities
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
		tblWorldClockCities.*
	from tblWorldClockCities 
		inner join tblWorldClockCitiesMap on tblWorldClockCitiesMap.WorldClockCityID = tblWorldClockCities.WorldClockCityID
	where tblWorldClockCitiesMap.ConfigurationID = @configurationId
		and tblWorldClockCitiesMap.isDeleted = 0
)
GO

GO

GO
DROP FUNCTION IF EXISTS cust.config_tblWorldMapPlaceNames
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the RLI data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblWorldMapPlaceNames
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblWorldMapPlaceNames.*
	from cust.tblWorldMapPlaceNames 
		inner join cust.tblWorldMapPlaceNamesMap on cust.tblWorldMapPlaceNamesMap.PlaceNameID = cust.tblWorldMapPlaceNames.PlaceNameID
	where cust.tblWorldMapPlaceNamesMap.ConfigurationID = @configurationId
		and cust.tblWorldMapPlaceNamesMap.isDeleted = 0

)
GO

GO

GO
DROP FUNCTION IF EXISTS cust.config_tblWorldTimeZonePlaceNames
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 26/05/2022
-- Description:	Function returns the RLI data for given configuration id
-- =============================================
CREATE FUNCTION cust.config_tblWorldTimeZonePlaceNames
(	
	@configurationId int
)
RETURNS TABLE 
AS
RETURN 
(
	select cust.tblWorldTimeZonePlaceNames.*
	from cust.tblWorldTimeZonePlaceNames 
		inner join cust.tblWorldTimeZonePlaceNamesMap on cust.tblWorldTimeZonePlaceNamesMap.PlaceNameID = cust.tblWorldTimeZonePlaceNames.PlaceNameID
	where cust.tblWorldTimeZonePlaceNamesMap.ConfigurationID = @configurationId
		and cust.tblWorldTimeZonePlaceNamesMap.isDeleted = 0

)
GO

GO

