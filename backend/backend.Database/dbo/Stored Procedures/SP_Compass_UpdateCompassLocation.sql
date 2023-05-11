SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 02/11/2022
-- Description:	Update compass locations
-- Sample EXEC [dbo].[SP_Compass_UpdateCompassLocation] 1, '-3', 'get'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Compass_UpdateCompassLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Compass_UpdateCompassLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Compass_UpdateCompassLocation]
@configurationId INT,
@inputGeoRefId NVARCHAR(500),
@type NVARCHAR(150),
@xmlValue xml = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @cityName NVARCHAR(250), @worldClockCities XML, @location1 NVARCHAR(250), @location2 NVARCHAR(250)
		DECLARE @temp TABLE(xmlData XML, cityName NVARCHAR(250))

		SET @location1 = (SELECT WC.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V));
		SET @location2 = (SELECT WC.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V));

		IF (@location1 IS NULL AND @location2 IS NULL)
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) GR
			WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId)
		END

		ELSE IF (@location1 IS NULL AND @location2 IS NOT NULL)
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) GR
			WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId
			AND GR.Description NOT IN (
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.config_tblRLI(@configurationId) as R
					OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V)))
		END

		ELSE IF (@location1 IS NOT NULL AND @location2 IS NULL)
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) GR
			WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId
			AND GR.Description NOT IN (
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.config_tblRLI(@configurationId) as R
					OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V)))
		END

		ELSE IF (@location1 IS NOT NULL AND @location2 IS NOT NULL)
		BEGIN
			SET @cityName = (SELECT Description FROM dbo.config_tblGeoRef(@configurationId) GR
			WHERE GR.isRliPoi = 1 AND  GR.GeoRefId = @inputGeoRefId
			AND GR.Description NOT IN (
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.config_tblRLI(@configurationId) as R
					OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V))
			AND GR.Description NOT IN(
					SELECT WC.V.value('@name', 'nvarchar(max)') AS city
					FROM cust.config_tblRLI(@configurationId) as R
					OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V)))
		END

		IF (@cityName IS NOT NULL AND @cityName != '')
			BEGIN
				SET @worldClockCities =(SELECT R.Rli AS xmlData 
				FROM cust.config_tblRLI(@configurationId) as R)

				INSERT INTO @temp VALUES (@worldClockCities, @cityName)
			END
			ELSE IF (@inputGeoRefId = -1)
			BEGIN
				SET @worldClockCities =(SELECT R.Rli AS xmlData 
			  FROM cust.config_tblRLI(@configurationId) as R)

				INSERT INTO @temp VALUES (@worldClockCities, 'Departure')
			END
			ELSE IF (@inputGeoRefId = -2)
			BEGIN
				SET @worldClockCities =(SELECT R.Rli AS xmlData 
				FROM cust.config_tblRLI(@configurationId) as R)

				INSERT INTO @temp VALUES (@worldClockCities, 'Destination')
			END
			ELSE IF (@inputGeoRefId = -3)
			BEGIN
				SET @worldClockCities =(SELECT R.Rli AS xmlData 
         		FROM cust.config_tblRLI(@configurationId) as R)

				INSERT INTO @temp VALUES (@worldClockCities, 'Closest Location')
			END

		SELECT * FROM @temp
	END
	ELSE IF (@type = 'update')
	BEGIN
		IF EXISTS (SELECT 1 FROM cust.config_tblRLI(@configurationId))
		BEGIN
			declare @mappedRliId int	
			declare @updateKey int
			set @mappedRliId = (select RLIID from cust.tblRliMap where configurationId = @configurationId)
			if not @mappedRliId is null
			BEGIN
				exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblRli', @mappedRliId, @updateKey out
				UPDATE R
				SET Rli = @xmlValue FROM cust.config_tblRLI(@configurationId) as R WHERE R.RLIID = @updateKey
			END	
		END
		ELSE
		BEGIN
			DECLARE @rliId INT
			INSERT INTO cust.tblRli(RLI) VALUES(@xmlValue)
			SET @rliId = (SELECT MAX(RLIID) FROM cust.tblRli)

			EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblRli',@rliId
		END
		SELECT 1 AS retValue
	END
END
GO