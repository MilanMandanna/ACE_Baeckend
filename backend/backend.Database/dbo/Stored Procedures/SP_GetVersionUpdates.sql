/****** Object:  StoredProcedure [dbo].[SP_GetVersionUpdates]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetVersionUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetVersionUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetVersionUpdates]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================  
-- Author:      Logeshwaran Sivaraj  
-- Create date: 9/29/2022  
-- Description: Retrieves all the data which are updated
--				based on the ConfigurationId  
-- Sample EXEC [dbo].[SP_GetVersionUpdates] 2
-- =======================================================  

CREATE PROCEDURE [dbo].[SP_GetVersionUpdates]
    @ConfigurationId int 
	   
AS
BEGIN

	DECLARE @configurationDefinitionID INT 
	DECLARE @currentConfigurationID INT = @ConfigurationId
	DECLARE @previousConfigurationID INT
	SELECT @ConfigurationDefinitionId = ConfigurationDefinitionID FROM tblConfigurations WHERE ConfigurationID = @currentConfigurationID
	DECLARE @currentVersion INT
	SELECT @currentVersion = Version FROM tblConfigurations WHERE ConfigurationID = @currentConfigurationID
	SELECT @previousConfigurationID = ConfigurationID FROM tblConfigurations WHERE Version = @currentVersion - 1 AND ConfigurationDefinitionID = @configurationDefinitionID
	--Compare with previous version configuration
	IF @previousConfigurationID IS NOT NULL
	BEGIN	
		DECLARE @sql_query NVARCHAR(MAX)
		DECLARE @tempConfigTables TABLE(id INT IDENTITY NOT NULL, tableName NVARCHAR(100))
		INSERT INTO @tempConfigTables SELECT tblName FROM tblConfigTables WHERE IsUsedForMergeConfiguration = 1
		DECLARE @cnt INT
		DECLARE @cnt_total INT
		SELECT @cnt = MIN(id) , @cnt_total = MAX(id) FROM @tempConfigTables
		DECLARE @config_table VARCHAR(100), @sqlUpdateStatement NVARCHAR(MAX), @sqlDeleteStatement NVARCHAR(MAX), @sqlInsertStatement NVARCHAR(MAX)
		DECLARE @mapTable VARCHAR(MAX), @mapColumn VARCHAR(100), @dataColumn VARCHAR(100), @mapSchema VARCHAR(100)
		DROP TABLE IF EXISTS #tempUpdates
		CREATE TABLE #tempUpdates(TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(100));
		WHILE @cnt <= @cnt_total
		BEGIN
			SELECT @config_table = tableName FROM @tempConfigTables WHERE id = @cnt
			SET @mapTable = @config_table + 'Map'
			EXEC dbo.Sp_configmanagement_findmappingbetween @mapTable, @config_table, @mapColumn output, @dataColumn output, @mapSchema output
		
			-- Inserting data when current configuration data is changed
			SET @sqlUpdateStatement = 'INSERT INTO #tempUpdates (TableName, CurrentKey, PreviousKey, Action)
					SELECT ''' + @config_table + ''',' + 'source.' + @mapColumn + ',' + 
					'destination.' + @mapColumn + ', ''Update'' FROM
					' + @mapSchema + '.' + @mapTable + '(NOLOCK) destination INNER JOIN ' + @mapSchema + '.' + @mapTable + '(NOLOCK) source ON 
					source.Previous' + @mapColumn + ' = destination.'+ @mapColumn +' AND source.configurationid = '''+
					CAST(@currentConfigurationID AS NVARCHAR) +''' AND destination.configurationId =''' + CAST(@previousConfigurationID AS NVARCHAR) + '''
					AND destination.' + @mapColumn + ' <> source.'+ @mapColumn +';';

			EXEC (@sqlUpdateStatement)

			-- Inserting data when current configuration data is deleted
			SET @sqlDeleteStatement = 'INSERT INTO #tempUpdates (TableName, CurrentKey, PreviousKey, Action)
					SELECT ''' + @config_table + ''',' + 'source.' + @mapColumn + ',' + 'destination.'+ @mapColumn + ',
					''Delete'' FROM  '+ @mapSchema + '.' + @mapTable +'  (NOLOCK) destination INNER JOIN '+ @mapSchema + '.' + @mapTable +'
					(NOLOCK) source ON source.' + @mapColumn + ' = destination.' + @mapColumn + ' AND source.configurationId = ''' + 
					Cast(@currentConfigurationID AS NVARCHAR) + ''' AND source.isDeleted = 1 AND 
					destination.configurationId IN(''' + Cast(@previousConfigurationID AS NVARCHAR) + ''');';

			EXEC (@sqlDeleteStatement)

			-- Inserting data when new data is added to current configuration
			SET @sqlInsertStatement = 'INSERT INTO #tempUpdates (TableName, CurrentKey, PreviousKey, Action)
					SELECT ''' + @config_table + ''',' + @mapColumn + ',' + 'NULL, ''Insert'' FROM ' + @mapSchema + '.' + @mapTable +  
					' (NOLOCK) WHERE ConfigurationID = ' + Cast(@currentConfigurationID AS NVARCHAR) + ' AND '+ 'Previous' + @mapColumn + ' = 0 AND IsDeleted = 0
					EXCEPT
					SELECT ''' + @config_table + ''',' + @mapColumn + ',' + 'NULL, ''Insert'' FROM ' + @mapSchema + '.' + @mapTable +  
					' (NOLOCK) WHERE ConfigurationID = ' + Cast(@previousConfigurationID AS NVARCHAR) + ' AND '+ 'Previous' + @mapColumn + ' = 0 AND IsDeleted = 0'

			EXEC (@sqlInsertStatement)
			SET @cnt = @cnt + 1
		END

		DECLARE @tableXML XML 
		SET @tableXML = (SELECT * FROM #tempUpdates FOR XML RAW);
		--SELECT @tableXML
		DROP TABLE IF EXISTS #TEMP_RESULT
		CREATE TABLE #TEMP_RESULT (ContentID INT, ContentType NVARCHAR(max), Name NVARCHAR(max), Field NVARCHAR(MAX), PreviousValue NVARCHAR(MAX), CurrentValue NVARCHAR(MAX), Action NVARCHAR(MAX))
		INSERT INTO #TEMP_RESULT
		EXEC SP_GetCountryUpdates @tableXML
		INSERT INTO #TEMP_RESULT
		EXEC SP_GetRegionUpdates @tableXML
		INSERT INTO #TEMP_RESULT
		EXEC SP_GetAirportUpdates @tableXML
		INSERT INTO #TEMP_RESULT
		EXEC SP_GetPlaceNameUpdates @tableXML
		SELECT * FROM #TEMP_RESULT ORDER BY ContentType ASC, Action DESC
		--Return Release Notes(Locking Comments)
		SELECT ISNULL(LockComment, '') AS ReleaseNotes FROM tblConfigurations WHERE ConfigurationID = @ConfigurationId
	END
END
GO


