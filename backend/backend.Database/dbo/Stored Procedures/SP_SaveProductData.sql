SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/24/2023
-- Description:	Procedure to create new product data
-- Sample EXEC [dbo].[SP_SaveProductData] 'test2','testing', 1,NULL,2
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveProductData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SaveProductData]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveProductData]
	@productName NVARCHAR(500),
    @productDescription NVARCHAR(MAX),
	@configurationDefinitionId INT,
	@userID UNIQUEIDENTIFIER,
	@outputTypeID INT,
	@topLevelPartNumber NVARCHAR(500)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION SaveProducts
		DECLARE @maxConfigDefID INT, @maxProductID INT, @maxConfigurationTypeID INT, @parentConfigConfigurationId INT, @description NVARCHAR(MAX)
		Declare @outputTable TABLE(ConfigurationId INT, Message NVARCHAR(500), ConfigurationDefinitionId INT)
		SET @maxConfigDefID = (SELECT MAX(ConfigurationDefinitionID) FROM tblConfigurationDefinitions)
		
		SET @maxConfigurationTypeID = (SELECT MAX(ConfigurationTypeID) FROM tblConfigurationTypes)


		---*** Region to insert Configuration types ***---
		INSERT INTO tblConfigurationTypes (ConfigurationTypeID, Name, UsesTimezone, UsesPlacenames)
		VALUES (@maxConfigurationTypeID + 1, @productName, 1, 1)
		---*** End region ***---

		DECLARE @parentConfigVersion INT;

		SELECT @parentConfigVersion=MAX(VERSION) FROM tblConfigurations WHERE ConfigurationDefinitionID=1 AND Locked=1

		---*** Region Insert data to configurationdefinition table ***---
		INSERT INTO tblConfigurationDefinitions (ConfigurationDefinitionID, ConfigurationDefinitionParentID, OutputTypeID, Active, AutoLock, 
			AutoMerge, AutoDeploy, ConfigurationTypeID,UpdatedUpToVersion) VALUES (@maxConfigDefID + 1, 1, @outputTypeID, 1, 1, 1, 1, @maxConfigurationTypeID,@parentConfigVersion)
			
		SET @maxConfigDefID = (SELECT MAX(ConfigurationDefinitionID) FROM tblConfigurationDefinitions)
		---*** End Region ***---

		---*** Insert data to products table ***--
		SET @maxProductID = (SELECT MAX(ProductID) FROM tblProducts)

		INSERT INTO tblProducts(ProductID, Name, Description, LastModifiedBy,TopLevelPartnumber)  
        VALUES (@maxProductID + 1, @productName, @productDescription, @userID,@topLevelPartNumber)  

		SET @maxProductID = (SELECT MAX(ProductID) FROM tblProducts)
		INSERT INTO tblProductConfigurationMapping(ProductID, ConfigurationDefinitionID) VALUES (@maxProductID, @maxConfigDefID)
		---*** End Region ***---
		
		SET @description = CONCAT(@productName, ' Product Configuration')
		INSERT INTO @outputTable (ConfigurationId, Message) EXEC dbo.SP_CreateBranch 1, @maxConfigDefID, 'Initial Setup', @description

		SELECT @maxConfigDefID AS ConfigurationDefinitionID
		COMMIT  TRANSACTION SaveProducts
	END TRY
	BEGIN CATCH
		SELECT 0 AS ConfigurationDefinitionID
		ROLLBACK  TRANSACTION SaveProducts
	END CATCH
END
GO