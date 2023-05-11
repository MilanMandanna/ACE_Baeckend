SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/23/2023
-- Description:	Update product data and create or update platforms under the product.
-- Sample EXEC [dbo].[SP_SaveProductConfigurationData] 'Product4', 'Product4', 5072, null, 1, null
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveProductConfigurationData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SaveProductConfigurationData]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveProductConfigurationData]
	@productName NVARCHAR(500),
    @productDescription NVARCHAR(MAX),
    @configurationDefinitionId INT,
    @userID UNIQUEIDENTIFIER,
	@outputTypeID INT,
	@TopLevelPartnumber NVARCHAR(MAX),
	@platformData [Type_PlatformData] READONLY
	
	
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION SavePlatforms
		DECLARE @TempPlatformDataTable TABLE( Id INT IDENTITY(1,1), ConfigurationDefinitionID INT, PlatformName NVARCHAR(MAX), PlatformDescription NVARCHAR(MAX), 
		PlatformId INT, InstallationTypeID UNIQUEIDENTIFIER)

		DECLARE @Id INT, @PlatformId INT, @platformName NVARCHAR(500), @platformDescription NVARCHAR(MAX), @platformConfigurationDefinitionID INT,
		@installationTypeID UNIQUEIDENTIFIER, @maxConfigDefID INT, @featureSetID INT, @maxPlatformID INT, @description NVARCHAR(MAX), @configurationTypeID INT,
		@configurationDefinitionParentId INT, @parentConfigConfigurationId INT, @branchDescription NVARCHAR(MAX)

		---*** Region to update Product data ***---
		UPDATE P
		SET P.Name = @productName, P.Description = @productDescription, p.LastModifiedBy = @userID,p.TopLevelPartnumber =@TopLevelPartnumber
		FROM tblProducts P
		INNER JOIN tblProductConfigurationMapping PCM ON P.ProductID = PCM.ProductID
		WHERE PCM.ConfigurationDefinitionID = @configurationDefinitionId
		---*** End Region ***---

		---*** Update ConfigurationDefinition Table ***---
		UPDATE tblConfigurationDefinitions
		SET OutputTypeID = @outputTypeID
		WHERE ConfigurationDefinitionID = @configurationDefinitionId
		---*** End Region ***---

		DECLARE @parentConfigVersion INT;

		SELECT @parentConfigVersion=MAX(VERSION) FROM tblConfigurations WHERE ConfigurationDefinitionID=@configurationDefinitionId AND Locked=1

		---*** Update / Insert data to platforms table ***---
		INSERT INTO @TempPlatformDataTable SELECT * FROM @platformData

		WHILE (SELECT COUNT(*) FROM @TempPlatformDataTable) > 0
		BEGIN
			SET @Id = (SELECT TOP 1 Id FROM @TempPlatformDataTable)
			SET @PlatformId = (SELECT TOP 1 PlatformId FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @platformName = (SELECT TOP 1 PlatformName FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @platformDescription = (SELECT TOP 1 PlatformDescription FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @platformConfigurationDefinitionID = (SELECT TOP 1 ConfigurationDefinitionID FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @installationTypeID = (SELECT TOP 1 InstallationTypeID FROM @TempPlatformDataTable WHERE Id = @Id)
			SET @featureSetID = (SELECT FeatureSetID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID = @configurationDefinitionId)

			IF @PlatformId <> 0 AND EXISTS (SELECT 1 FROM tblPlatforms P INNER JOIN tblPlatformConfigurationMapping PCM ON P.PlatformID = PCM.PlatformID 
				WHERE P.PlatformID = @PlatformId)
			BEGIN
				UPDATE P
				SET P.Name = @platformName, P.Description = @platformDescription, P.InstallationTypeID = @installationTypeID
				FROM tblPlatforms P
				INNER JOIN tblPlatformConfigurationMapping PCM ON P.PlatformID = PCM.PlatformID
				WHERE PCM.ConfigurationDefinitionID = @platformConfigurationDefinitionID
			END
			ELSE
			BEGIN
				SET @maxConfigDefID = (SELECT MAX(ConfigurationDefinitionID) FROM tblConfigurationDefinitions)
				SET @configurationTypeID = (SELECT ConfigurationTypeID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID = @configurationDefinitionId)
				SET @description = (SELECT CONCAT(@platformDescription, ' Product ', @productName))
				SET @configurationDefinitionParentId = (SELECT ConfigurationDefinitionParentID FROM tblConfigurationDefinitions 
						WHERE ConfigurationDefinitionID = @configurationDefinitionId)
			
				INSERT INTO tblConfigurationDefinitions (ConfigurationDefinitionID, ConfigurationDefinitionParentID, OutputTypeID, Active, AutoLock, 
					AutoMerge, AutoDeploy, FeatureSetID, ConfigurationTypeID,UpdatedUpToVersion)
					VALUES (@maxConfigDefID + 1, @configurationDefinitionId, @outputTypeID, 1, 1, 1, 1, @featureSetID, @configurationTypeID,@parentConfigVersion)
			
				SELECT @maxConfigDefID = (SELECT MAX(ConfigurationDefinitionID) FROM tblConfigurationDefinitions);

				SET @maxPlatformID = (SELECT ISNULL(MAX(PlatformID), 0) FROM tblPlatforms)

				INSERT INTO tblPlatforms (PlatformID, Name, Description, InstallationTypeID)
				VALUES (@maxPlatformID + 1, @platformName, @description, @installationTypeID)

				SET @maxPlatformID = (SELECT MAX(PlatformID) FROM tblPlatforms)
				INSERT INTO tblPlatformConfigurationMapping(PlatformID, ConfigurationDefinitionID) VALUES (@maxPlatformID, @maxConfigDefID)

				SET @branchDescription = CONCAT(@platformName, ' Platform Configuration')
				SET @parentConfigConfigurationId = (SELECT TOP 1 ConfigurationID FROM tblConfigurations WHERE ConfigurationDefinitionID = @configurationDefinitionId AND Locked = 1 ORDER BY Version DESC)
				EXEC dbo.SP_CreateBranch @parentConfigConfigurationId, @maxConfigDefID, 'Initial Setup', @branchDescription
			END
			DELETE FROM @TempPlatformDataTable WHERE Id = @Id;
			
		END
		COMMIT TRANSACTION SavePlatforms
	---*** End Region ---***
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION SavePlatforms
	END CATCH
END
GO