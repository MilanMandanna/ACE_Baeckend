SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 08/25/2022
-- Description:	Procedure to get errors when a file upload fails.
-- Sample EXEC [dbo].[SP_GetFileUploadErrorLogs] 1,'populations'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetFileUploadErrorLogs]', 'P') IS NOT NULL
	BEGIN
		DROP PROC [dbo].[SP_GetFileUploadErrorLogs]
	END
GO

CREATE PROCEDURE [dbo].[SP_GetFileUploadErrorLogs]  
	@configurationId INT,  
	@pageName NVARCHAR(500)  
AS  
BEGIN

	DECLARE @name NVARCHAR(250), @taskType UNIQUEIDENTIFIER
	
	IF (@pageName = 'populations' OR @pageName = 'airports' OR @pageName = 'world guide cities')
		BEGIN
			SELECT
				@name = CASE @pageName
				WHEN 'populations' THEN 'Import CityPopulation'
				WHEN 'airports' THEN 'Import NewAirportFromNavDB'
				WHEN 'placenames' THEN 'Import NewPlaceNames'
				WHEN 'world guide' THEN 'Import WGCities'
			END
			SELECT TOP 1 errorlog FROM tbltasks WHERE ConfigurationID = @configurationId
			AND TaskTypeID IN (SELECT ID FROM tblTaskType WHERE Name = @name) ORDER BY DateStarted DESC
		END
	ELSE
		BEGIN
			SELECT TOP 1 CC.ErrorLog FROM tblConfigurationComponents CC
			INNER JOIN tblConfigurationComponentsMap CCM ON CC.ConfigurationComponentTypeID = CCM.ConfigurationComponentID AND CCM.ConfigurationID = @configurationId
		END
END