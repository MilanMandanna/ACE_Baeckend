SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Add or remove timezone locations
-- Sample EXEC [dbo].[SP_Timezone_UpdateTimezoneLocation] 18, '25,9', 'remove'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_UpdateTimezoneLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_UpdateTimezoneLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_UpdateTimezoneLocation]
@configurationId INT,
@InputList NVARCHAR(500),
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(Descriptions NVARCHAR(500), id INT)
	DECLARE @xmlData XML, @tmpxml XML, @currentXML XML, @data NVARCHAR(250), @geoRefID NVARCHAR(150)
	DECLARE @retTable TABLE (id INT)

	SET @xmlData = (SELECT PlaceNames as xmlData FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId))

	IF (@type = 'add')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM dbo.config_tblGeoRef(@configurationId) as GR
		WHERE GR.isTimeZonePoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description NOT IN (
		SELECT ISNULL(TZN.V.value('@name', 'nvarchar(max)'), '') AS city
		FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
		OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZN(V))
	END
	ELSE IF (@type = 'remove')
	BEGIN
		INSERT INTO @tmpTable  SELECT GR.Description, GR.GeoRefId FROM  dbo.config_tblGeoRef(@configurationId) as GR
		WHERE GR.isTimeZonePoi = 1 AND  GR.GeoRefId in (SELECT * FROM STRING_SPLIT(@InputList, ','))
		AND GR.Description IN (
		SELECT ISNULL(TZN.V.value('@name', 'nvarchar(max)'), '') AS city
		FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
		OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZN(V))
	END

	SET @currentXML = (SELECT TZ.PlaceNames FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ)

	WHILE (SELECT Count(*) FROM @tmpTable) > 0
	BEGIN
		SET @data = (SELECT TOP 1 Descriptions FROM @tmpTable)
		SET @geoRefID = (SELECT TOP 1 id FROM @tmpTable)
		
		IF (@type = 'add')
		BEGIN
			IF (@currentXML IS NULL)
			BEGIN
				SET @currentXML = ('<world_timezone_placenames><city name="'+ @data +'">'+ @geoRefID +'</city></world_timezone_placenames>')
			END
			ELSE
			BEGIN
				SET @tmpxml = ('<city name="'+ @data +'">'+ @geoRefID +'</city>')
				SET @currentXML.modify('insert sql:variable("@tmpxml")into (world_timezone_placenames)[1]')
			END
		END
		ELSE IF (@type = 'remove')
		BEGIN
			SET @currentXML.modify('delete /world_timezone_placenames/city[text() = sql:variable("@geoRefID")]')
		END
		DELETE @tmpTable WHERE Id = @geoRefID
	END

	DECLARE @mappedPlaceNameID INT	
    DECLARE @updateKey INT

    SET @mappedPlaceNameID = (SELECT PlaceNameID FROM cust.tblWorldTimeZonePlaceNamesMap WHERE configurationId = @configurationId)
    IF NOT @mappedPlaceNameID IS NULL
    BEGIN

		EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWorldTimeZonePlaceNames', @mappedPlaceNameID, @updateKey OUT

		BEGIN TRY
			UPDATE TZ
			SET TZ.PlaceNames = @currentXML FROM
			cust.config_tblWorldTimeZonePlaceNames(@configurationId) AS TZ WHERE TZ.PlaceNameID = @updateKey

			INSERT INTO @retTable(id) VALUES (1)
		END TRY	
		BEGIN CATCH
				INSERT INTO @retTable(id) VALUES (0)
		END CATCH
	END	
	ELSE
	BEGIN
		DECLARE @placeNameID INT
		INSERT INTO cust.tblWorldTimeZonePlaceNames (PlaceNames) VALUES (@currentXML)
		SET @placeNameID = (SELECT MAX(PlaceNameID) FROM cust.tblWorldTimeZonePlaceNames)

		EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblWorldTimeZonePlaceNames', @placeNameID
		INSERT INTO @retTable(id) VALUES (1)
	END
	SELECT * FROM @retTable
END
GO