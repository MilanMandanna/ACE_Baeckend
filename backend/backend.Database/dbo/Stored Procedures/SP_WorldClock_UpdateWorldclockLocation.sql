SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add or remove available world clock locations
-- Sample EXEC [dbo].[SP_WorldClock_UpdateWorldclockLocation] 18, '9,25', 'add'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_UpdateWorldclockLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_UpdateWorldclockLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_UpdateWorldclockLocation]
@configurationId INT,
@InputList NVARCHAR(500),
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(Descriptions NVARCHAR(500), id INT)
	DECLARE @xmlData XML, @tmpxml XML, @currentXML XML, @data NVARCHAR(250), @geoRefID NVARCHAR(150)
	DECLARE @retTable TABLE (id INT)
	DECLARE @cityXML XML, @mappedWorldClockCityID int, @updateKey int, @newWordClockCityID INT, @newRecord BIT = 0
	set @mappedWorldClockCityID = (select WorldClockCityID from cust.config_tblWorldClockCities(@configurationId))

	SET @xmlData = (SELECT WorldClockCities as xmlData  FROM cust.config_tblWorldClockCities(@configurationId) as WC)

	IF (@type = 'add')
	BEGIN
		SET @cityXML = (SELECT GR.Description FROM dbo.config_tblGeoRef(@configurationId) as GR
		WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description NOT IN (
			SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
			FROM cust.config_tblWorldClockCities(@configurationId) as WC
			OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)))
			
		IF (@cityXML IS NULL)
		BEGIN
			INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId  FROM dbo.config_tblGeoRef(@configurationId) as GR
			WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		END
		ELSE IF (@cityXML IS NOT NULL)
		BEGIN
			INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.config_tblGeoRef(@configurationId) as GR 
			WHERE GR.isWorldclockpoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
			AND GR.Description NOT IN (
				SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
				FROM cust.config_tblWorldClockCities(@configurationId) as WC
				OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
		END
	END
	ELSE IF (@type = 'remove')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.config_tblGeoRef(@configurationId) as GR
		WHERE GR.isWorldClockPoi = 1 AND  GR.GeoRefId IN (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description IN (
			SELECT WCL.V.value('@name', 'nvarchar(max)') AS city
			FROM cust.config_tblWorldClockCities(@configurationId) as WC
			OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)) 
	END

	SET @currentXML = (SELECT W.WorldClockCities FROM cust.config_tblWorldClockCities(@configurationId) as W)

	IF (@type = 'all')
	BEGIN
		SET @currentXML.modify('delete /worldclock_cities/city')
        	
				BEGIN TRY
				if not @mappedWorldClockCityID is null
       		 	BEGIN

					exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldClockCities', @mappedWorldClockCityID, @updateKey out
					UPDATE W
					SET W.WorldClockCities = @currentXML
					FROM cust.config_tblWorldClockCities(@configurationId) as W WHERE W.WorldClockCityID = @updateKey
					INSERT INTO @retTable(id) VALUES (1)
				END
				END TRY
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
	END

	IF CHARINDEX('-1', @InputList) > 0
	BEGIN
		INSERT INTO @tmpTable (id, Descriptions) VALUES('-1', 'Departure')
	END
	IF CHARINDEX('-2', @InputList) > 0
	BEGIN
		INSERT INTO @tmpTable (id, Descriptions) VALUES('-2', 'Destination')
	END

	WHILE (SELECT Count(*) FROM @tmpTable) > 0
	BEGIN
		SET @data = (SELECT TOP 1 Descriptions FROM @tmpTable)
		SET @geoRefID = (SELECT TOP 1 id FROM @tmpTable)
		
		IF (@type = 'add')
		BEGIN
			IF (@currentXML IS NULL)
			BEGIN
				SET @currentXML = ('<worldclock_cities><city name="'+ @data +'" geoRef="'+ @geoRefID +'" /></worldclock_cities>')
				SET @newRecord = (1)
			END
			ELSE
			BEGIN
				SET @tmpxml = ('<city name="'+ @data +'" geoRef="'+ @geoRefID +'" />')
				SET @currentXML.modify('insert sql:variable("@tmpxml")into (worldclock_cities)[1]')
			END
		END
		ELSE IF (@type = 'remove')
		BEGIN
			SET @currentXML.modify('delete /worldclock_cities/city[@geoRef = sql:variable("@geoRefID")]')
		END
		BEGIN TRY
			IF (@newRecord = 1)
			BEGIN
				INSERT INTO cust.tblWorldClockCities(WorldClockCities) VALUES (@currentXML)
				SET @newWordClockCityID = (SELECT MAX(WorldClockCityID) FROM cust.tblWorldClockCities)
				EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblWorldClockCities',@newWordClockCityID
			END
			ELSE
			BEGIN
				IF NOT @mappedWorldClockCityID IS NULL
				BEGIN
					exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldClockCities', @mappedWorldClockCityID, @updateKey out
					UPDATE W
					SET W.WorldClockCities = @currentXML
					FROM cust.config_tblWorldClockCities(@configurationId) as W WHERE W.WorldClockCityID = @updateKey
					INSERT INTO @retTable(id) VALUES (1) 
				END
			END
		END TRY
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
		DELETE @tmpTable WHERE Id = @geoRefID
	END
	SELECT id FROM @retTable
END
GO