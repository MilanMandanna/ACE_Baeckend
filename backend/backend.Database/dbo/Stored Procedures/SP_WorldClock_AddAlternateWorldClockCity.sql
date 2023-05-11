SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add new alternate world clock locations
-- Sample EXEC [dbo].[SP_WorldClock_AddAlternateWorldClockCity] 18, '9', 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_AddAlternateWorldClockCity]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_AddAlternateWorldClockCity]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_AddAlternateWorldClockCity]
@configurationId INT,
@inputGeoRefId NVARCHAR(500),
@type NVARCHAR(150),
@xmlValue xml = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @cityName NVARCHAR(250), @worldClockCities XML, @cityXML XML, @defaultXML XML
		DECLARE @temp TABLE(xmlData XML, cityName NVARCHAR(250))

		IF (@inputGeoRefId = '-1')
		BEGIN
			SET @cityName = 'Departure'
		END
		ELSE IF (@inputGeoRefId = '-2')
		BEGIN
			SET @cityName = 'Destination'
		END
		ELSE
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM cust.config_tblWorldClockCities(@configurationId))
			BEGIN
				SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
				WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId)
			END
			ELSE
			BEGIN
				SET @cityXML = (SELECT GR.Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (@inputGeoRefId)
					AND GR.Description NOT IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)))

				SET @defaultXML = (SELECT GR.Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (@inputGeoRefId)
					AND GR.Description NOT IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)))

				IF (@cityXML IS NULL AND @defaultXML IS NULL)
				BEGIN
					SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId)
				END
				ELSE IF (@cityXML IS NULL)
				BEGIN
					SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId
					AND GR.Description not IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)))
				END
				ELSE IF (@defaultXML IS NULL)
				BEGIN
					SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId
					AND GR.Description not IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)))
				END
				ELSE
				BEGIN
					SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) as GR
					WHERE GR.isworldclockpoi = 1 AND  GR.GeoRefId = @inputGeoRefId
					AND GR.Description not IN (
						SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
					AND GR.Description not IN(
						SELECT WC.V.value('@name', 'nvarchar(max)') AS city
						FROM cust.config_tblWorldClockCities(@configurationId) as W
						OUTER APPLY W.WorldClockCities.nodes('worldclock_cities/default_city')  AS WC(V)))
				END
			END
		END

		IF (@cityName IS NOT NULL AND @cityName != '')
		BEGIN
			SET @worldClockCities =(SELECT WC.WorldClockCities AS xmlData 
            FROM cust.config_tblWorldClockCities(@configurationId) as WC)

			INSERT INTO @temp VALUES (@worldClockCities, @cityName)

			SELECT * FROM @temp
		END
	END
	ELSE IF (@type = 'update')
	BEGIN

		IF EXISTS (SELECT 1 FROM cust.config_tblWorldClockCities(@configurationId))
		BEGIN
			DECLARE @mappedWorldClockCityID INT	
    		DECLARE @updateKey INT
			SET @mappedWorldClockCityID = (SELECT WorldClockCityID FROM cust.config_tblWorldClockCities(@configurationId))
			IF NOT @mappedWorldClockCityID IS NULL
       			BEGIN	
			   
			   		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldClockCities', @mappedWorldClockCityID, @updateKey OUT
					UPDATE WC
					SET WorldClockCities = @xmlValue FROM cust.config_tblWorldClockCities(@configurationId) AS WC WHERE WC.WorldClockCityID = @updateKey
				END
		END
		ELSE
		BEGIN
			DECLARE @worldClockId INT
			INSERT INTO CUST.tblWorldClockCities(WorldClockCities) VALUES (@xmlValue)

			SET @worldClockId = (SELECT MAX(WorldClockCityID) FROM cust.tblWorldClockCities)
			EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblWorldClockCities',@worldClockId
		END
		SELECT 1 AS retValue
	END
END
GO