SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 01/25/2023
-- Description:	To get values from feature set table. If configuration def Id is 1 then get all distinct values, if not get values for specific configuration def id
-- Sample EXEC [dbo].[SP_GetAllFeatureSet] 5050
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetAllFeatureSet]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetAllFeatureSet]
END
GO

CREATE PROCEDURE [dbo].[SP_GetAllFeatureSet]
    @configurationDefinitionId INT
AS
BEGIN
	DECLARE @featureSetId INT
	DECLARE @temptable TABLE(ID INT IDENTity(1,1), NAME NVARCHAR(500))
	DECLARE @featuresetValue TABLE(ID INT IDENTITY(1,1), featureSetName NVARCHAR(500), value NVARCHAR(MAX), selectedValue BIT, featureSetId INT,
				inputtype NVARCHAR(50), uniqueList NVARCHAR(MAX))
	DECLARE @distinctFeaturesetValue TABLE(ID INT IDENTITY(1,1), distinctFeatureSetName NVARCHAR(500), value NVARCHAR(MAX), selectedValue BIT,
											featureSetId INT, inputtype NVARCHAR(50))
	CREATE TABLE #selectedValueList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	CREATE TABLE #uniqueValueList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	DECLARE @tempFeatureSet TABLE(ID INT IDENTITY(1,1), featureSetId INT, Name NVARCHAR(500), Value NVARCHAR(MAX), keyFeatureSetID INT)
	DECLARE @finalList TABLE(ID INT IDENTITY(1,1), Name NVARCHAR(500))
	DECLARE @id INT, @inputtype NVARCHAR(500), @value NVARCHAR(MAX), @name NVARCHAR(MAX), @uniqueValue NVARCHAR(MAX), @selected NVARCHAR(MAX),
	@featureId INT, @CommaSeparatedString NVARCHAR(MAX), @keyId INT

	CREATE TABLE #keyList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	CREATE TABLE #valueList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	DECLARE @keys NVARCHAR(MAX), @values NVARCHAR(MAX)
	CREATE TABLE #selectedKeyList (ID INT IDENTITY(1,1), val NVARCHAR(500))
	CREATE TABLE #uniquekeyList (ID INT IDENTITY(1,1), val NVARCHAR(500))
    DECLARE @uniqueList AS TABLE (val NVARCHAR(500))
    DECLARE @selectedList AS TABLE (val NVARCHAR(500))
	DECLARE @selectedKeys NVARCHAR(MAX), @uniqueKeys NVARCHAR(MAX)
	SET @featureSetId = (SELECT FeatureSetID FROM tblConfigurationDefinitions WHERE ConfigurationDefinitionID = @configurationDefinitionId)
	--Global featurset
	IF (@configurationDefinitionId = 1 OR @featureSetId IS NULL)
	BEGIN

		INSERT INTO @temptable SELECT DISTINCT Name FROM tblFeatureSet WHERE IsConfigurable = 1
		WHILE (SELECT COUNT(*) FROM @temptable) > 0
		BEGIN
			SET @id = (SELECT TOP 1 id FROM @temptable)
			SET @name = (SELECT name FROM @temptable WHERE id = @id)
			SET @value = (SELECT value FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)
			SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1))
			SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)
			--Dropdown with keyvalue pair
			IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
			BEGIN
				SET @keys = (SELECT VALUE FROM tblFeatureSet WHERE ID = @keyId)
				SET @values = @value

				INSERT INTO #keyList SELECT * FROM STRING_SPLIT(@keys, ',')
				INSERT INTO #valueList SELECT * FROM STRING_SPLIT(@values, ',')

				INSERT INTO @finalList 
				SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #keyList xml INNER JOIN #valueList display ON xml.ID = display.ID

				SELECT @CommaSeparatedString = COALESCE(@CommaSeparatedString + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList
				
				INSERT INTO @distinctFeaturesetValue (distinctFeatureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @CommaSeparatedString, 0, 1, @inputtype)

				TRUNCATE TABLE #keyList
				TRUNCATE TABLE #valueList
				DELETE FROM @finalList
			END
			--Other InputTypes
			ELSE
			BEGIN
				INSERT INTO @distinctFeaturesetValue (distinctFeatureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @value, 0, 1, @inputtype)
			END
			DELETE FROM @temptable WHERE id = @id
		END
		SELECT * FROM @distinctFeaturesetValue ORDER BY distinctFeatureSetName ASC
	END
	--Product level selected featureset
	ELSE
	BEGIN
		INSERT INTO @temptable SELECT DISTINCT Name FROM tblFeatureSet WHERE FeatureSetID = @featureSetId AND IsConfigurable = 1
		
		WHILE (SELECT COUNT(*) FROM @temptable) > 0
		BEGIN
			SET @id = (SELECT TOP 1 id FROM @temptable)
			SET @name = (SELECT name FROM @temptable WHERE id = @id)
			SET @value = (SELECT value FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = @featureSetId)
			SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = @featureSetId))
			SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = @featureSetId)

			IF (@inputtype = 'dropdown')
			BEGIN
				--Dropdown with keyvalue pair
				IF (@keyId IS NOT NULL)
				BEGIN
					SET @CommaSeparatedString = NULL
					INSERT INTO @tempFeatureSet SELECT FeatureSetID, Name, value, KeyFeatureSetID FROM tblFeatureSet WHERE Name = @name
					SET @selected = (SELECT VALUE FROM tblFeatureSet WHERE Name = @name AND FeatureSetID = @featureSetId)
					SET @selectedKeys = (SELECT VALUE FROM tblFeatureSet WHERE ID = @keyId)

					WHILE (SELECT COUNT (*) FROM @tempFeatureSet) > 0
					BEGIN
						SET @featureId = (SELECT TOP 1 ID FROM @tempFeatureSet)
						SET @uniqueValue = (SELECT Value FROM @tempFeatureSet WHERE ID = @featureId)
						SET @keyId = (SELECT keyFeatureSetID FROM @tempFeatureSet WHERE ID = @featureId)
						SET @uniqueKeys = (SELECT value FROM tblFeatureSet WHERE ID = @keyId)

						INSERT INTO #selectedValueList SELECT * FROM STRING_SPLIT(@selected, ',')
						INSERT INTO #selectedKeyList SELECT * FROM STRING_SPLIT(@selectedKeys, ',')

						INSERT INTO #uniqueValueList SELECT * FROM STRING_SPLIT(@uniqueValue, ',')
						INSERT INTO #uniquekeyList SELECT * FROM STRING_SPLIT(@uniqueKeys, ',')

                        INSERT INTO @selectedList 
					    SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #selectedKeyList xml INNER JOIN #selectedValueList display ON xml.ID = display.ID

                        INSERT INTO @uniqueList 
					    SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #uniquekeyList xml INNER JOIN #uniqueValueList display ON xml.ID = display.ID

						DELETE FROM @tempFeatureSet WHERE ID = @featureId
					END
					--To Bind UniqueList field with key|value pair
                    DELETE FROM @finalList
					INSERT INTO @finalList 
					SELECT DISTINCT LTRIM(RTRIM(val)) FROM @uniqueList  WHERE val NOT IN (SELECT DISTINCT LTRIM(RTRIM(val)) FROM @selectedList)

					SELECT @CommaSeparatedString = COALESCE(@CommaSeparatedString + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList

					--To Bind Value Field with key|value pair
					SET @keys = (SELECT VALUE FROM tblFeatureSet WHERE ID = @keyId)
					SET @values = @value

					TRUNCATE TABLE #keyList
					TRUNCATE TABLE #valueList
					INSERT INTO #keyList SELECT * FROM STRING_SPLIT(@selectedKeys, ',')
					INSERT INTO #valueList SELECT * FROM STRING_SPLIT(@values, ',')

					DELETE FROM @finalList
					INSERT INTO @finalList 
					SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #keyList xml INNER JOIN #valueList display ON xml.ID = display.ID
					SET @value = NULL
					SELECT @value = COALESCE(@value + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList

					INSERT INTO @featuresetValue (featureSetName, value, selectedValue, featureSetId, inputtype, uniqueList) 
					VALUES (@name, @value, 1, @featureSetId, @inputtype, @CommaSeparatedString)

					TRUNCATE TABLE #selectedKeyList
					TRUNCATE TABLE #uniqueKeyList
					TRUNCATE TABLE #selectedValueList
					TRUNCATE TABLE #uniqueValueList
					TRUNCATE TABLE #keyList
					TRUNCATE TABLE #valueList
					DELETE FROM @finalList
				END
				--Dropdown without keyvalue pair
				ELSE
				BEGIN
					SET @CommaSeparatedString = NULL
					INSERT INTO @tempFeatureSet SELECT FeatureSetID, Name, value, KeyFeatureSetID FROM tblFeatureSet WHERE Name = @name
					SET @selected = NULL
                    SET @selected = (SELECT VALUE FROM tblFeatureSet WHERE Name = @name AND FeatureSetID = @featureSetId)
					WHILE (SELECT COUNT (*) FROM @tempFeatureSet) > 0
					BEGIN
						SET @featureId = (SELECT TOP 1 ID FROM @tempFeatureSet)
						SET @uniqueValue = (SELECT Value FROM @tempFeatureSet WHERE ID = @featureId)

						INSERT INTO #selectedValueList SELECT * FROM STRING_SPLIT(@selected, ',')
						INSERT INTO #uniqueValueList SELECT * FROM STRING_SPLIT(@uniqueValue, ',')

						DELETE FROM @tempFeatureSet WHERE ID = @featureId
					END
                    DELETE FROM @finalList
					INSERT INTO @finalList SELECT DISTINCT LTRIM(RTRIM(VAL)) FROM #uniqueValueList  WHERE val NOT IN (SELECT DISTINCT LTRIM(RTRIM(val)) FROM #selectedValueList)
					SELECT @CommaSeparatedString = COALESCE(@CommaSeparatedString + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList

					INSERT INTO @featuresetValue (featureSetName, value, selectedValue, featureSetId, inputtype, uniqueList) 
					VALUES (@name, @selected, 1, @featureSetId, @inputtype, @CommaSeparatedString)

					TRUNCATE TABLE #selectedValueList
					TRUNCATE TABLE #uniqueValueList
					TRUNCATE TABLE #keyList
					TRUNCATE TABLE #valueList
					DELETE FROM @finalList
				END
			END
			--Other InputTypes
			ELSE
			BEGIN
				INSERT INTO @featuresetValue (featureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @value, 1, @featureSetId, @inputtype)
			END

			DELETE FROM @temptable WHERE id = @id
		END
		--All Available featureset
		INSERT INTO @temptable SELECT DISTINCT Name FROM tblFeatureSet WHERE IsConfigurable = 1 AND NAME NOT IN (SELECT Name FROM tblFeatureSet WHERE FeatureSetID = @featureSetId)

		WHILE (SELECT COUNT(*) FROM @temptable) > 0
		BEGIN
			SET @id = (SELECT TOP 1 id FROM @temptable)
			SET @name = (SELECT name FROM @temptable WHERE id = @id)
			SET @value = (SELECT value FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)
			SET @inputtype = (SELECT Name FROM tblFeatureSetInputType WHERE InputTypeID = (SELECT InputTypeID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1))
			SET @keyId = (SELECT KeyFeatureSetID FROM tblFeatureSet WHERE name IN (@name) AND FeatureSetID = 1)
			--Dropdown with keyvalue pair
			IF (@inputtype = 'dropdown' AND @keyId IS NOT NULL)
			BEGIN
				SET @keys = (SELECT VALUE FROM tblFeatureSet WHERE ID = @keyId)
				SET @values = @value

				INSERT INTO #keyList SELECT * FROM STRING_SPLIT(@keys, ',')
				INSERT INTO #valueList SELECT * FROM STRING_SPLIT(@values, ',')

				INSERT INTO @finalList 
				SELECT LTRIM(RTRIM(xml.val)) + '|' + LTRIM(RTRIM(display.val)) AS keyValue FROM #keyList xml INNER JOIN #valueList display ON xml.ID = display.ID
				SET @CommaSeparatedString = NULL
				SELECT @CommaSeparatedString = COALESCE(@CommaSeparatedString + ',', '') + (LTRIM(RTRIM(Name))) FROM @finalList
				
				INSERT INTO @distinctFeaturesetValue (distinctFeatureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @CommaSeparatedString, 0, 1, @inputtype)

				TRUNCATE TABLE #keyList
				TRUNCATE TABLE #valueList
				DELETE FROM @finalList
			END
			--Other InputTypes
			ELSE
			BEGIN
				INSERT INTO @distinctFeaturesetValue (distinctFeatureSetName, value, selectedValue, featureSetId, inputtype) VALUES (@name, @value, 0, 1, @inputtype)
			END

			DELETE FROM @temptable WHERE id = @id
		END
		
		DROP TABLE IF EXISTS #selectedKeyList
		DROP TABLE IF EXISTS #uniqueKeyList
		DROP TABLE IF EXISTS #selectedValueList
		DROP TABLE IF EXISTS #uniqueValueList
		DROP TABLE IF EXISTS #keyList
		DROP TABLE IF EXISTS #valueList
		SELECT * FROM @distinctFeaturesetValue ORDER BY distinctFeatureSetName ASC
		SELECT * FROM @featuresetValue ORDER BY featureSetName ASC
		
	END
END
GO