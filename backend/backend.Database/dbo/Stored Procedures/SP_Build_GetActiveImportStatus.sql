SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 08/25/2022
-- Description:	Get any current active import process based on the page name and configuration id
-- Sample EXEC [dbo].[SP_Build_GetActiveImportStatus] 'populations', 105
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_GetActiveImportStatus]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_GetActiveImportStatus]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_GetActiveImportStatus]
	@pageName NVARCHAR(250),
	@configurationId INT
AS
	DECLARE @name NVARCHAR(250), @taskType UNIQUEIDENTIFIER
	DECLARE @BuildStatus TABLE(ID UNIQUEIDENTIFIER, DetailedStatus NVARCHAR(250), PercentageComplete NVARCHAR(250), DateStarted NVARCHAR(250), Version INT)

	SELECT 
	@name = CASE @pageName
			WHEN 'populations' THEN 'Import CityPopulation'
			WHEN 'airports' THEN 'Import NewAirportFromNavDB'
			WHEN 'placenames' THEN 'Import NewPlaceNames'
			WHEN 'world guide' THEN 'Import WGCities'
	END

	IF EXISTS (SELECT 1 FROM tblTasks T INNER JOIN tblConfigurations C ON T.ConfigurationID = C.ConfigurationID WHERE T.ConfigurationID = @configurationId)
	BEGIN
		INSERT INTO @BuildStatus(ID, DetailedStatus, PercentageComplete, DateStarted, Version) SELECT TOP 1 ID, DetailedStatus, PercentageComplete, FORMAT(DateStarted, 'MM/dd/yyyy') AS DateStarted, C.Version FROM tblTasks T
		INNER JOIN tblConfigurations C ON T.ConfigurationID = C.ConfigurationID
		WHERE T.ConfigurationID = @configurationId 
		AND T.TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = @name) ORDER BY DateStarted DESC
	END

	ELSE
	BEGIN
		INSERT INTO @BuildStatus(ID, DetailedStatus, PercentageComplete, DateStarted, Version) SELECT TOP 1 T.ID, T.DetailedStatus, T.PercentageComplete, FORMAT(T.DateStarted, 'MM/dd/yyyy') AS DateStarted, C.Version FROM tblTasks T
		INNER JOIN tblConfigurations C ON T.ConfigurationID = C.ConfigurationID
		INNER JOIN tblTaskType TT ON T.TaskTypeID = TT.ID
		WHERE T.ConfigurationID  IN (SELECT ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID IN
		(SELECT ConfigurationDefinitionID FROM tblConfigurations WHERE ConfigurationID = @configurationId)) AND TT.Name = @name ORDER BY DateStarted DESC
	END

	SELECT * FROM @BuildStatus