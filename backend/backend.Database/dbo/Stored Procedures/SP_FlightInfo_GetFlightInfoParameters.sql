SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get and Update flightinfo parameters names
-- Sample EXEC [dbo].[SP_FlightInfo_GetFlightInfoParameters] 1, 'get', xmldata
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_GetFlightInfoParameters]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_GetFlightInfoParameters]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_GetFlightInfoParameters]
@ConfigurationId INT,
@pageName NVARCHAR(20),
@type NVARCHAR(150),
@xmlData XML = NULL
AS
BEGIN
	IF (@type = 'get')
	BEGIN
		DECLARE @temp TABLE(xmldisplayName NVARCHAR(MAX), infoParamDisplay NVARCHAR(MAX), infoParamName NVARCHAR(MAX), xmlData XML)
		DECLARE @name NVARCHAR(MAX), @infoParamDisplay NVARCHAR(MAX), @infoParamName NVARCHAR(MAX), @xml XML

		SET @name = '';
		IF (@pageName = 'flightinfo')
		BEGIN
			SELECT @name = @name + ISNULL(Nodes.item.value('(./text())[1]', 'varchar(max)'), '') + ','
			FROM cust.config_tblWebmain(@configurationId) as M
			CROSS APPLY M.InfoItems.nodes('//infoitem') AS Nodes(item)
			WHERE Nodes.item.value('(./@default_flight_info)[1]', 'varchar(max)') = 'true'
		END
		ELSE IF (@pageName = 'broadcast')
		BEGIN
			SELECT @name = @name + ISNULL(Nodes.item.value('(./text())[1]', 'varchar(max)'), '') + ','
			FROM cust.config_tblWebmain(@configurationId) as M
			CROSS APPLY M.InfoItems.nodes('//infoitem') AS Nodes(item)
			WHERE Nodes.item.value('(./@broadcast)[1]', 'varchar(max)') = 'true'
		END
		ELSE IF (@pageName = 'yourflight')
		BEGIN
			SELECT @name = @name + ISNULL(Nodes.item.value('(./text())[1]', 'varchar(max)'), '') + ','
			FROM cust.config_tblWebmain(@configurationId) as M
			CROSS APPLY M.InfoItems.nodes('//infoitem') AS Nodes(item)
			WHERE Nodes.item.value('(./@yourflight)[1]', 'varchar(max)') = 'true'
		END
		SET @infoParamName = (SELECT FS.Value FROM tblFeatureSet FS
						INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
						INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
						WHERE FS.Name = 'FlightInfo-ParametersList' AND C.ConfigurationID = @ConfigurationId)

		SET @infoParamDisplay = (SELECT FS.Value FROM tblFeatureSet FS
						INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
						INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
						WHERE FS.Name = 'FlightInfo-ParametersDisplayList' AND C.ConfigurationID = @configurationId)

		SET @xml = (SELECT InfoItems FROM cust.config_tblWebmain(@configurationId))

		INSERT INTO @temp(xmldisplayName, infoParamDisplay, infoParamName, xmlData) VALUES (@name, @infoParamDisplay, @infoParamName, @xml)

		SELECT * FROM @temp
	END
	ELSE IF(@type = 'update')
	BEGIN
		BEGIN TRY
		IF (@xmlData IS NOT NULL)
		BEGIN
			DECLARE @mappedWebMainID INT, @updateKey INT
			SET @mappedWebMainID = (SELECT WebMainID FROM cust.tblWebMainMap WHERE configurationId = @configurationId)
			IF NOT @mappedWebMainID IS NULL
       		BEGIN	
				exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblWebmain', @mappedWebMainID, @updateKey out

				UPDATE WM
				SET InfoItems = @xmlData FROM cust.config_tblWebmain(@configurationId) AS WM WHERE WM.WebMainID = @updateKey
			END
			ELSE
			BEGIN
				DECLARE @webmainId INT
				INSERT INTO cust.tblWebMain (infoItems) VALUES (@xmlData)
				SET @webmainId = (SELECT MAX(WebMainID) FROM cust.tblWebMain)
				EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblWebmain', @webmainId
			END
			SELECT 1 AS retValue
		END
		ELSE
		BEGIN
			SELECT 0 AS retValue
		END
		END TRY
		BEGIN CATCH
		SELECT 0 AS retValue
		END CATCH
	END
END
GO