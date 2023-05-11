SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/27/2023
-- Description:	To save feature set values
-- Sample EXEC [dbo].[SP_SaveFeatureSet] 'AS4XXX Product FeatureSet,ASXI-3 Product FeatureSet', 1, 3, 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_SaveFeatureSet]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_SaveFeatureSet]
END
GO

CREATE PROCEDURE [dbo].[SP_SaveFeatureSet]
    @selectedFeatureSetName NVARCHAR(MAX),
	@isAdded NVARCHAR(15),
	@configurationDefinitionId INT,
	@featureSetId INT,
	@featureSetName NVARCHAR(500) = NULL,
	@featureSetValue NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @tblTempFeatureSet TABLE(Id INT IDENTITY(1,1), FeatureSetId INT, Name NVARCHAR(MAX), Value NVARCHAR(MAX), IsConfigurable BIT, InputTypeId INT, KeyFeatureSetId INT)
	DECLARE @selectedFeatureSetID INT, @id INT, @name NVARCHAR(500)
	DECLARE @inputtype NVARCHAR(50), @keyId INT, @selectedFeatureSetValue NVARCHAR(500)
	DECLARE @selectedFeatureSetValueList TABLE(ID INT IDENTITY(1,1), val NVARCHAR(500))
	DECLARE @keyValueList TABLE(ID INT IDENTITY(1,1), selectedKey NVARCHAR(MAX), selectedValue NVARCHAR(MAX))
	DECLARE @CommaSeparatedKeyString NVARCHAR(MAX), @CommaSeparatedValueString NVARCHAR(MAX)

	SET @selectedFeatureSetID = (SELECT FeatureSetID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID = @configurationDefinitionId)
	IF (@isAdded = 0)
	BEGIN
		SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE NAME IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ',')) AND FeatureSetID = @featureSetId))
		SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE NAME IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ',')) AND FeatureSetID = @featureSetId)
		IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
		BEGIN
			DELETE FROM tblFeatureSet WHERE FeatureSetID = @featureSetId AND NAME IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ','))
			DELETE FROM tblFeatureSet WHERE FeatureSetID = @featureSetId AND ID = @keyId
		END
		ELSE
		BEGIN
			DELETE FROM tblFeatureSet WHERE FeatureSetID = @featureSetId AND NAME IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ','))
		END
	END
	ELSE
	BEGIN
		IF (@featureSetName IS NOT NULL AND @featureSetValue IS NOT NULL)
		BEGIN
			SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@featureSetName) AND FeatureSetID = @selectedFeatureSetID))
			SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@featureSetName) AND FeatureSetID = @selectedFeatureSetID)
			IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
			BEGIN
				SET @CommaSeparatedKeyString = NULL
				SET @CommaSeparatedValueString = NULL
				
				INSERT INTO @selectedFeatureSetValueList SELECT * FROM STRING_SPLIT(@featureSetValue, ',')
				
				INSERT INTO @keyValueList
				SELECT REVERSE(PARSENAME(REPLACE(REVERSE(val), '|', '.'), 1)) AS SelectedKey
					, REVERSE(PARSENAME(REPLACE(REVERSE(val), '|', '.'), 2)) AS SelectedValue FROM @selectedFeatureSetValueList
				
				SELECT @CommaSeparatedKeyString = COALESCE(@CommaSeparatedKeyString + ',', '') + (LTRIM(RTRIM(SelectedKey))) FROM @keyValueList
				SELECT @CommaSeparatedValueString = COALESCE(@CommaSeparatedValueString + ',', '') + (LTRIM(RTRIM(SelectedValue))) FROM @keyValueList

				UPDATE tblFeatureSet SET value = @CommaSeparatedKeyString WHERE ID = @keyId AND FeatureSetID = @selectedFeatureSetID
				UPDATE tblFeatureSet SET VALUE = @CommaSeparatedValueString WHERE NAME = @featureSetName AND FeatureSetID = @selectedFeatureSetID
			END
			ELSE
			BEGIN
				UPDATE tblFeatureSet SET VALUE = @featureSetValue WHERE NAME = @featureSetName AND FeatureSetID = @selectedFeatureSetID
			END
		END
		ELSE IF (@selectedFeatureSetName IS NOT NULL)
		BEGIN
			IF(@selectedFeatureSetID IS NULL)
			BEGIN
				SET @selectedFeatureSetID = (SELECT MAX(FeatureSetID) + 1 FROM tblFeatureSet)
				UPDATE tblConfigurationDefinitions SET FeatureSetID = @selectedFeatureSetID WHERE ConfigurationDefinitionID = @configurationDefinitionId
			END
			INSERT INTO @tblTempFeatureSet (FeatureSetId, Name, Value, IsConfigurable, InputTypeId, KeyFeatureSetId) SELECT @selectedFeatureSetID, Name, Value, IsConfigurable, InputTypeID, KeyFeatureSetID FROM tblFeatureSet WHERE FeatureSetID = 1 AND   
			Name IN (SELECT * FROM STRING_SPLIT(@selectedFeatureSetName, ','))  
    
			WHILE (SELECT COUNT(*) FROM @tblTempFeatureSet) > 0  
			BEGIN  
				SET @id = (SELECT TOP 1 Id FROM @tblTempFeatureSet)  
				SET @name = (SELECT Name FROM @tblTempFeatureSet WHERE Id = @id)
				SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1))
				SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)

				IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
				BEGIN
					INSERT INTO tblFeatureSet (FeatureSetID, Name, Value, IsConfigurable, InputTypeID) 
					SELECT @selectedFeatureSetID, Name, Value, IsConfigurable, InputTypeID FROM tblFeatureSet WHERE FeatureSetID = 1 AND  NAME = @name
					
					INSERT INTO tblFeatureSet (FeatureSetID, Name, Value, IsConfigurable, InputTypeID) 
					SELECT @selectedFeatureSetID, Name, Value, IsConfigurable, InputTypeID FROM tblFeatureSet WHERE FeatureSetID = 1 AND  ID = @keyId

					UPDATE tblFeatureSet SET KeyFeatureSetID = SCOPE_IDENTITY() WHERE FeatureSetID = @selectedFeatureSetID AND Name = @name
				END
				ELSE
				BEGIN
					INSERT INTO tblFeatureSet (FeatureSetID, Name, Value, IsConfigurable, InputTypeID) 
					SELECT @selectedFeatureSetID, Name, Value, IsConfigurable, InputTypeID FROM tblFeatureSet WHERE FeatureSetID = 1 AND  NAME = @name
				END
				DELETE FROM @tblTempFeatureSet WHERE Id = @id 
			END
		END
	END
END
GO