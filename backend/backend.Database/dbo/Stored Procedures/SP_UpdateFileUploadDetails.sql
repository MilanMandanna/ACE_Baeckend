SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 5/17/2022
-- Description:	When a file is uploaded to Azure, update the details in the configuration components table.
-- Sample EXEC [dbo].[SP_UpdateFileUploadDetails] 67, 1, '', 'systemconfig', null, 'systemconfig'
-- =============================================
IF OBJECT_ID('[dbo].[SP_UpdateFileUploadDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_UpdateFileUploadDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateFileUploadDetails]
	 @configurationId INT,
	 @url NVARCHAR(MAX),
	 @fileName NVARCHAR(50),
	 @userId NVARCHAR(MAX),
	 @pageName NVARCHAR(150),
	 @errorMessage NVARCHAR(MAX)
AS
BEGIN
	DECLARE @configurationComponentTypeId INT, @configurationComponentId INT, @userName NVARCHAR(500), @existingComponentId INT, @newComponentID INT

	SET  @configurationComponentTypeId = (SELECT ConfigurationComponentTypeID FROM tblConfigurationComponentType WHERE Name LIKE '%' + @pageName + '%')
	--SET @configurationComponentId = (SELECT ISNULL(MAX([ConfigurationComponentID]),0) + 1 FROM tblConfigurationComponents as results)
	SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)
	
	IF EXISTS(SELECT 1 FROM tblConfigurationComponentsMap CCM 
			  INNER JOIN tblConfigurationComponents CC ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
			  WHERE CCM.ConfigurationID = @configurationId	AND CC.ConfigurationComponentTypeID = @configurationComponentTypeId)
	BEGIN
		SET @existingComponentId = (SELECT CCM.ConfigurationComponentID FROM tblConfigurationComponentsMap CCM
		INNER JOIN tblConfigurationComponents CC ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
		INNER JOIN tblConfigurationComponentType CCT ON CCT.ConfigurationComponentTypeID = CC.ConfigurationComponentTypeID
		WHERE CCM.ConfigurationID = @configurationId AND CC.ConfigurationComponentTypeID = @configurationComponentTypeId)

		EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblConfigurationComponents', @existingComponentId, @newComponentID OUTPUT

		IF (@url != 'error')
		BEGIN
			UPDATE CC
				SET Path = @url, ErrorLog = ''
				FROM tblConfigurationComponents CC
				INNER JOIN tblConfigurationComponentsMap CCM ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
				WHERE CC.ConfigurationComponentTypeID = @configurationComponentTypeId AND CCM.ConfigurationID = @configurationId
				AND CC.ConfigurationComponentID = @newComponentID
		END
		ELSE
		BEGIN
			UPDATE CC
				SET Path = '', ErrorLog = @errorMessage
				FROM tblConfigurationComponents CC
				INNER JOIN tblConfigurationComponentsMap CCM ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
				WHERE CC.ConfigurationComponentTypeID = @configurationComponentTypeId AND CCM.ConfigurationID = @configurationId
				AND CC.ConfigurationComponentID = @newComponentID			
		END
		UPDATE CCM
				SET Action = 'Updated', LastModifiedBy = @userName, LastModifiedDate = GETDATE()
				FROM tblConfigurationComponentsMap CCM
				INNER JOIN tblConfigurationComponents CC ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
				WHERE ConfigurationID = @configurationId AND CC.ConfigurationComponentTypeID = @configurationComponentTypeId
				AND CCM.ConfigurationComponentID = @newComponentID
	END
	ELSE
	BEGIN
		IF (@url != 'true')
		BEGIN
			INSERT INTO tblConfigurationComponents (Path, ConfigurationComponentTypeID, Name, ErrorLog) 
			VALUES (@url, @configurationComponentTypeId, @pageName, '')
			SET @configurationComponentId = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			INSERT INTO tblConfigurationComponents (Path, ConfigurationComponentTypeID, Name, ErrorLog) 
			VALUES ('', @configurationComponentTypeId, @pageName, @errorMessage)
			SET @configurationComponentId = SCOPE_IDENTITY()
		END

		EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblConfigurationComponents', @configurationComponentId

		UPDATE CCM
				SET LastModifiedBy = @userName, LastModifiedDate = GETDATE()
				FROM tblConfigurationComponentsMap CCM
				INNER JOIN tblConfigurationComponents CC ON CC.[ConfigurationComponentID] = CCM.ConfigurationComponentID
				WHERE ConfigurationID = @configurationId AND CCM.ConfigurationComponentID = @configurationComponentId
	END
END

GO