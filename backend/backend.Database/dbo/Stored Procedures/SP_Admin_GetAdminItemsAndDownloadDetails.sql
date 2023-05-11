SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 03/29/2022
-- Description:	Get admin items and download details
-- Sample EXEC [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails] 112, 'page', 'populations'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Admin_GetAdminItemsAndDownloadDetails]
@configurationId INT,
@type NVARCHAR(150),
@pageName NVARCHAR(250) = NULL
AS
BEGIN
	DECLARE @AdminItems TABLE (buttonNames NVARCHAR(MAX))
	DECLARE @DownloadDetails TABLE (userName NVARCHAR(500), dateUploaded DATETIME, revision INT, taskId NVARCHAR(300), configurationId INT, configurationDefinitionId INT)
	IF (@type = 'adminitem')
	BEGIN
		INSERT INTO @AdminItems SELECT FS.Value FROM tblFeatureSet FS
        INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
        INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        WHERE FS.Name = 'Collins-Admin-ItemsList' AND C.ConfigurationID = @configurationId

		SELECT * FROM @AdminItems
	END
	
	ELSE IF (@type = 'page')
	BEGIN
		IF (@pageName = 'populations' OR @pageName = 'airports' OR @pageName = 'world guide cities')
		BEGIN
			INSERT INTO @DownloadDetails SELECT CH.CommentAddedBy, CH.DateModified, C.Version , CH.TaskID, CH.ConfigurationID, C.ConfigurationDefinitionID 
			FROM tblConfigurationHistory CH
			INNER JOIN tblConfigurations C ON C.ConfigurationID = CH.ConfigurationID 
			WHERE ContentType = @pageName AND TaskID IS NOT NULL
			AND CH.ConfigurationID IN (SELECT ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID IN 
									(SELECT ConfigurationDefinitionID FROM tblConfigurations WHERE ConfigurationID = @configurationId))
			ORDER BY C.Version DESC
			
		END
		ELSE
		BEGIN
			INSERT INTO @DownloadDetails
			SELECT CCM.LastModifiedBy, CCM.LastModifiedDate, C.Version, CC.ConfigurationComponentID, C.ConfigurationID, C.ConfigurationDefinitionID FROM tblConfigurationComponents CC
			INNER JOIN tblConfigurationComponentsMap CCM ON CC.ConfigurationComponentID = CCM.ConfigurationComponentID
			AND CC.ErrorLog = '' AND CC.Name = @pageName 
			AND CCM.ConfigurationID IN (SELECT ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID IN 
										(SELECT ConfigurationDefinitionID FROM tblConfigurations WHERE ConfigurationID = @configurationId))
			INNER JOIN tblConfigurations C ON C.ConfigurationID = CCM.ConfigurationID ORDER BY C.Version ASC
		END

		SELECT * FROM @DownloadDetails ORDER BY revision DESC
	END
END
GO