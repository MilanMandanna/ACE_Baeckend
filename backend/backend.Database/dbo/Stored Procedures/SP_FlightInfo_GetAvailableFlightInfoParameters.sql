SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get available flightinfo parameters
-- Sample EXEC [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]
END
GO

CREATE PROCEDURE [dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]
@ConfigurationId INT 
AS
BEGIN
	DECLARE @temp TABLE(infoParamDisplay NVARCHAR(500), infoParamName NVARCHAR(500))
	DECLARE @infoParamDisplay NVARCHAR(500), @infoParamName NVARCHAR(500)

	SET @infoParamName = (SELECT FS.Value FROM tblFeatureSet FS
                    INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
                    INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
                    WHERE FS.Name = 'FlightInfo-ParametersList' AND C.ConfigurationID = @configurationId)

	SET @infoParamDisplay = (SELECT FS.Value FROM tblFeatureSet FS
                    INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
                    INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
                    WHERE FS.Name = 'FlightInfo-ParametersDisplayList' AND C.ConfigurationID = @configurationId)

	INSERT INTO @temp(infoParamDisplay, infoParamName) VALUES (@infoParamDisplay, @infoParamName)

	SELECT * FROM @temp
END
GO