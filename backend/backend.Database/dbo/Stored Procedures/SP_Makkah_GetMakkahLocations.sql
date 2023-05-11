SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get Makkah locations and available locations
-- Sample EXEC [dbo].[SP_Makkah_GetMakkahLocations] 1, 'prayertime'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Makkah_GetMakkahLocations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Makkah_GetMakkahLocations]
END
GO

CREATE PROCEDURE [dbo].[SP_Makkah_GetMakkahLocations]
@ConfigurationId INT,
@type NVARCHAR(150)
AS
BEGIN
	DECLARE @tmpTable Table(geoRefId INT, Descriptions NVARCHAR(500))
	DECLARE @geoRefTable Table(ID INT IDENTITY, GeoRefID INT)
	DECLARE @Id INT, @Count INT

	IF (@type = 'prayertime')
	BEGIN

		INSERT INTO @geoRefTable SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
		FROM cust.config_tblMakkah(@configurationId) as M
		OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V)

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -4)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-4, 'Current Location')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -1)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		END
		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, gr.Description FROM dbo.config_tblGeoRef(@ConfigurationId) as GR WHERE GR.isMakkahPoi = 1
		AND GR.GeoRefId NOT IN (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
				FROM cust.config_tblMakkah(@configurationId) as M
				OUTER APPLY M.Makkah.nodes('makkah/default_calculation_city') AS RLN(V))
	END
	ELSE IF (@type = 'available')
	BEGIN
		
		INSERT INTO @geoRefTable SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
		FROM cust.config_tblRLI(@configurationId) as R
		OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V)

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -10)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-10, 'Disabled')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -1)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-1, 'Departure')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -2)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-2, 'Destination')
		END

		SET @Count = (SELECT COUNT(*) FROM @geoRefTable WHERE GeoRefID = -3)
		IF (@Count = 0)
		BEGIN
			INSERT INTO @tmpTable VALUES (-3, 'Closest Location')
		END

		INSERT INTO @tmpTable SELECT GR.GeoRefId, GR.Description FROM  dbo.config_tblGeoRef(@ConfigurationId) as GR WHERE GR.isMakkahPoi = 1
		AND GR.GeoRefId NOT IN (SELECT RLN.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
				FROM cust.config_tblRLI(@configurationId) as R
				OUTER APPLY R.Rli.nodes('rli/mecca_rli') AS RLN(V))
	END

	SELECT * FROM @tmpTable
END
GO