SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Updates region name of the given language, for the given country of the given configuration
-- =============================================

IF OBJECT_ID('[dbo].[SP_Region_UpdateDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_UpdateDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_UpdateDetails]
	@configurationId INT,
    @regionId INT,
    @languageId INT,
    @regionName NVARCHAR(MAX)
AS
BEGIN
    DECLARE @custom INT, @existingvalue INT,@updatedvalue INT
	SET @custom =2
	SET @existingvalue = (SELECT CustomChangeBitMask FROM tblRegionSpelling WHERE tblRegionSpelling.regionId = @regionId AND tblRegionSpelling.LanguageID = @languageId )
	SET @updatedvalue =(@existingvalue | @custom)
    UPDATE regionSpelling 
    SET regionSpelling.regionName =  @regionName,regionSpelling.CustomChangeBitMask =@updatedvalue FROM 
    dbo.config_tblRegionSpelling(@configurationId) as regionSpelling 
    WHERE regionSpelling.regionId = @regionId AND regionSpelling.LanguageID = @languageId   
END    
GO  