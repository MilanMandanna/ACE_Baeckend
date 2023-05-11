SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets different locations for view type
-- Sample EXEC [SP_Timezone_ColorsData] 18,'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_ColorsData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_ColorsData]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_ColorsData]  
 @configurationId INT,
 @type NVARCHAR(500),
 @color NVARCHAR(500) = NULL,
 @nodeName NVARCHAR(500) = NULL
AS  
BEGIN
	IF (@type = 'get')
	BEGIN
		SELECT PlaceNames.value('(world_timezone_placenames/@depart_color)[1]', 'varchar(max)') as Departure_Color,
		PlaceNames.value('(world_timezone_placenames/@dest_color)[1]', 'varchar(max)') as Destination_Color,
		PlaceNames.value('(world_timezone_placenames/@timeatpp_color)[1]', 'varchar(max)') as Present_Color 
		FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
	END
	ELSE IF (@type = 'update')
	BEGIN

		DECLARE @mappedPlaceNameID INT	
        DECLARE @updateKey INT

        SET @mappedPlaceNameID = (SELECT PlaceNameID FROM cust.tblWorldTimeZonePlaceNamesMap WHERE configurationId = @configurationId)
        IF NOT @mappedPlaceNameID IS NULL
        BEGIN
		    EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldTimeZonePlaceNames', @mappedPlaceNameID, @updateKey OUT

			IF (@nodeName = 'depart_color')  
			BEGIN  
				UPDATE TZ   
				SET PlaceNames.modify('replace value of (/world_timezone_placenames/@depart_color)[1] with sql:variable("@color")')   
				FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ WHERE TZ.PlaceNameID = @updateKey
			END  
			ELSE IF (@nodeName = 'dest_color')  
			BEGIN  
				UPDATE TZ   
				SET PlaceNames.modify('replace value of (/world_timezone_placenames/@dest_color)[1] with sql:variable("@color")')   
				FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ WHERE TZ.PlaceNameID = @updateKey
			END  
			ELSE IF (@nodeName = 'timeatpp_color')  
			BEGIN  
				UPDATE TZ   
				SET PlaceNames.modify('replace value of (/world_timezone_placenames/@timeatpp_color)[1] with sql:variable("@color")')   
				FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ WHERE TZ.PlaceNameID = @updateKey
			END
		END
		ELSE
		BEGIN
			DECLARE @currentXML XML

			IF (@nodeName = 'timeatpp_color')
			BEGIN
			SET @currentXML = ('<world_timezone_placenames timeatpp_color="' + @color + '"></world_timezone_placenames>')
			END
			ELSE IF (@nodeName = 'dest_color')
			BEGIN
			SET @currentXML = ('<world_timezone_placenames dest_color="' + @color + '"></world_timezone_placenames>')
			END
			ELSE IF (@nodeName = 'depart_color')
			BEGIN
			SET @currentXML = ('<world_timezone_placenames depart_color="' + @color + '"></world_timezone_placenames>')
			END

			DECLARE @placeNameID INT
			INSERT INTO cust.tblWorldTimeZonePlaceNames (PlaceNames) VALUES (@currentXML)
			SET @placeNameID = (SELECT MAX(PlaceNameID) FROM cust.tblWorldTimeZonePlaceNames)

			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblWorldTimeZonePlaceNames', @placeNameID
		END
	END
END