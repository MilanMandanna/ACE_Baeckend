SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
The procedure is used to get errors logged for file upload in Collins Admin feature
*/
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
	IF (@pageName = 'populations' OR @pageName = 'airports' OR @pageName = 'world guide cities')
	BEGIN
		SELECT TOP 1 errorlog FROM tbltasks WHERE ConfigurationID = @configurationId ORDER BY DateLastUpdated DESC
	END
	ELSE
	BEGIN
		SELECT TOP 1 CC.ErrorLog FROM tblConfigurationComponents CC
		INNER JOIN tblConfigurationComponentsMap CCM ON CC.ConfigurationComponentTypeID = CCM.ConfigurationComponentID AND CCM.ConfigurationID = @configurationId
	END
END

GO