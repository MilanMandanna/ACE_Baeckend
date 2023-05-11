SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets different locations for view type
-- Sample EXEC [dbo].[SP_Views_GetLocationForSelectedView] 35,'worldclock'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_GetLocationForSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_GetLocationForSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_GetLocationForSelectedView]
@configurationId INT,
@viewName NVARCHAR(500)
AS
BEGIN
	DECLARE @cityXML XML, @DestinationXML XML, @DepartureXML XML, @ClosestXML XML, @Location1XML XML, @Location2XML XML, @defaultXML XML
	DECLARE @tmpTable Table(geoRefId INT, Descriptions NVARCHAR(500))
	
	IF (@viewName = 'compass')
	BEGIN

		--SET @Location1XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location1[@name = "Closest Location"]') = 1)
		--SET @Location2XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location2[@name = "Closest Location"]') = 1)

		--IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		--END

		--SET @Location1XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location1[@name = "Departure"]') = 1)
		--SET @Location2XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location2[@name = "Departure"]') = 1)

		--IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		--END

		--SET @Location1XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location1[@name = "Destination"]') = 1)
		--SET @Location2XML = (SELECT R.Rli
		--				FROM cust.config_tblRLI(@configurationId) as R
		--				WHERE R.Rli.exist('/rli/location2[@name = "Destination"]') = 1)

		--IF (@Location1XML IS NULL AND @Location2XML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		--END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
		WHERE GR.isRliPoi = 1 AND GR.GeoRefID NOT IN (
				SELECT ISNULL(WC.V.value('text()[1]', 'nvarchar(max)'), '') AS city
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/location1')  AS WC(V))
		AND GR.GeoRefID NOT IN(
				SELECT ISNULL(WC.V.value('text()[1]', 'nvarchar(max)'), '') AS city
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/location2')  AS WC(V))
	END
	ELSE IF (@viewName = 'timezone')
	BEGIN
		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
		WHERE GR.isTimeZonePoi = 1 AND 
		GR.GeoRefID NOT IN (SELECT ISNULL(TZV.V.value('text()[1]', 'nvarchar(max)'), '') AS city
       						FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
            				OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZV(V))
	END
	ELSE IF (@viewName = 'worldclock')
	BEGIN

		--SET @DepartureXML	= (SELECT WC.WorldClockCities
		--				FROM cust.config_tblWorldClockCities(@configurationId) as WC
		--				WHERE WC.WorldClockCities.exist('/worldclock_cities/city[@name = "Departure"]') = 1)
		--SET @DestinationXML = (SELECT WC.WorldClockCities
		--						FROM cust.config_tblWorldClockCities(@configurationId) as WC
		--						WHERE WC.WorldClockCities.exist('/worldclock_cities/default_city[@name = "Departure"]') = 1)

		--IF (@DepartureXML IS NULL AND @DestinationXML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		--END

		--SET @DepartureXML	= (SELECT WC.WorldClockCities
		--			FROM cust.config_tblWorldClockCities(@configurationId) as WC
		--			WHERE WC.WorldClockCities.exist('/worldclock_cities/city[@name = "Destination"]') = 1)
		--SET @DestinationXML	= (SELECT WC.WorldClockCities
		--			FROM cust.config_tblWorldClockCities(@configurationId) as WC
		--			WHERE WC.WorldClockCities.exist('/worldclock_cities/default_city[@name = "Destination"]') = 1)

		--IF (@DepartureXML IS NULL AND @DestinationXML IS NULL)
		--BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		--END

		SET @cityXML = (SELECT WC.WorldClockCities
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						WHERE WC.WorldClockCities.exist('/worldclock_cities/city') = 1)
		SET @defaultXML = (SELECT WC.WorldClockCities
						FROM cust.config_tblWorldClockCities(@configurationId) as WC
						WHERE WC.WorldClockCities.exist('/worldclock_cities/default_city') = 1)

		IF (@defaultXML IS NULL AND @cityXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
			WHERE GR.isWorldClockPoi = 1
		END
		ELSE IF (@cityXML IS NULL AND @defaultXML IS NOT NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
			WHERE GR.isWorldClockPoi = 1 AND
			GeoRefId NOT IN (SELECT
				WCL.V.value('@geoRef', 'nvarchar(max)') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V))
		END
		ELSE IF (@cityXML IS NOT NULL AND @defaultXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
			WHERE GR.isWorldClockPoi = 1 AND
			GeoRefId NOT IN (SELECT
				WCL.V.value('@geoRef', 'nvarchar(max)') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V))
		END
		ELSE IF (@cityXML IS NOT NULL AND @defaultXML IS NOT NULL)
		BEGIN
			INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@configurationId) AS GR
			WHERE GR.isWorldClockPoi = 1 AND
			GR.GeoRefID NOT IN (SELECT
				ISNULL(WCL.V.value('@geoRef', 'nvarchar(max)'), '') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)) AND
			GR.GeoRefID NOT IN (SELECT
				ISNULL(WCL.V.value('@geoRef', 'nvarchar(max)'), '') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V))
		END
	END

	SELECT * FROM @tmpTable
END
GO