SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/05/2022
-- Description:	adds new country entry to tblCountry and returns the country id
-- =============================================

IF OBJECT_ID('[dbo].[SP_Country_Add]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Country_Add]
END
GO

CREATE PROCEDURE [dbo].[SP_Country_Add]
	@configurationId INT,
    @description NVARCHAR(MAX),
    @regionId INT
AS
BEGIN


    DECLARE @countryId INT;
    INSERT INTO dbo.tblCountry (Description,RegionID,CustomChangeBitMask) VALUES(@description,@regionId,1)
    SET @countryId = SCOPE_IDENTITY();
	update dbo.tblCountry set countryid=@countryId where ID=@countryId;
    EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblCountry', @countryId
    SELECT @countryId as countryId

END    
GO  