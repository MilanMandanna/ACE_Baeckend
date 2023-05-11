-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Returns list of all the region for the given configuration
-- =============================================
IF OBJECT_ID('[dbo].[SP_Region_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_GetAll]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_GetAll]
	@configurationId int
AS
BEGIN
   
  SELECT DISTINCT Region.RegionID,
  Region.RegionName
  FROM dbo.config_tblRegionSpelling(@configurationId) as Region
  WHERE Region.LanguageID = 1

END

GO