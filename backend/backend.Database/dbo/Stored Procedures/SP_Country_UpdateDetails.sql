SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	Updates Contry name of the given language, for the given country of the given configuration. Also updates the country description and region id.
-- =============================================

IF OBJECT_ID('[dbo].[SP_Country_UpdateDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_UpdateDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_UpdateDetails]
	@configurationId INT,
    @countryId INT,
    @description NVARCHAR(MAX),
    @regionId INT
AS
BEGIN
	DECLARE @custom INT, @existingvalue INT,@updatedvalue INT,@updatedcountryId INT
	EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblCountry', @countryId,@updatedcountryId out
	SET @custom =2
	SET @existingvalue = (SELECT CustomChangeBitMask FROM tblCountry WHERE tblCountry.CountryID = @updatedcountryId)
	SET @updatedvalue =(@existingvalue | @custom)
	
    UPDATE country
    SET country.Description = @description,
    country.RegionID = @regionId, country.CustomChangeBitMask =@updatedvalue
    FROM dbo.config_tblCountry(@configurationId) AS country
    WHERE country.ID = @updatedcountryId

	
END    
GO  