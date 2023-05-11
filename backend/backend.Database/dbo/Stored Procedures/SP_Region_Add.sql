SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	adds new region entry onto tblRegionSpelling
-- =============================================

IF OBJECT_ID('[dbo].[SP_Region_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Region_Add]
END
GO

CREATE PROCEDURE [dbo].[SP_Region_Add]
	@configurationId INT,
    @regionName NVARCHAR(MAX)
AS
BEGIN

    DECLARE @regionId INT;
    SET @regionId = (SELECT MAX(Region.RegionID) FROM dbo.config_tblRegionSpelling(@configurationId) as Region) 
    IF @regionId IS NULL 
    BEGIN
        SET @regionId = 1
    END
    ELSE 
    BEGIN 
        SET @regionId = @regionId + 1
    END
   SELECT @regionId as regionId
END    
GO  