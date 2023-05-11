SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 10/17/2022
-- Description:	Populate the merge details table with the keys of parent configuration AND child configuration for all the table. This data will be used to populate the screen with values.
-- Sample EXEC [dbo].[SP_MergeConfiguration_PopulateMergeDetails] 105, 112, '5CAA57A1-2DE9-403C-9756-01CCE173A06C'
-- =============================================

IF OBJECT_ID('[dbo].[SP_MergeConfiguration_PopulateMergeDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_MergeConfiguration_PopulateMergeDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_MergeConfiguration_PopulateMergeDetails]
@configurationId INT,
@parentConfigurationId INT,
@taskId uniqueidentifier
AS
BEGIN
	DECLARE @config_table VARCHAR(100), @sqlUpdateStatement NVARCHAR(MAX), @sqlDeleteStatement NVARCHAR(MAX), @sqlInsertStatement NVARCHAR(MAX)
	BEGIN TRY
		UPDATE tblTasks SET DetailedStatus = 'In Progress', TaskStatusID = 2, DateLastUpdated = GETDATE() WHERE ID = @taskId
		BEGIN TRAN
			DECLARE cur_tbl CURSOR  LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
			SELECT tblName FROM tblConfigTables WHERE IsUsedForMergeConfiguration = 1
		
			OPEN cur_tbl

				FETCH next FROM cur_tbl INTO @config_table
				WHILE @@FETCH_STATUS = 0

				BEGIN

					DECLARE @mapTable VARCHAR(MAX) = @config_table + 'Map'
					DECLARE @mapColumn VARCHAR(MAX), @dataColumn VARCHAR(MAX), @mapSchema VARCHAR(MAX)

					EXEC dbo.Sp_configmanagement_findmappingbetween
						@mapTable, @config_table, @mapColumn output, @dataColumn output, @mapSchema output

					-- Inserting data when parent configuration data is changed
					SET @sqlUpdateStatement = 'INSERT INTO tblMergeDetails (TaskId, TableName, ParentKey, ChildKey, MergeChoice, SelectedKey, action)
							SELECT ''' + CONVERT(NVARCHAR(36), @taskId) + ''',''' + @config_table + ''',' + 'source.' + @mapColumn + ',' + 
							'destination.' + @mapColumn + ', 2, NULL, ''Update'' FROM
							' + @mapSchema + '.' + @mapTable + '(NOLOCK) destination INNER JOIN ' + @mapSchema + '.' + @mapTable + '(NOLOCK) source ON 
							source.Previous' + @mapColumn + ' = destination.'+ @mapColumn +' AND source.configurationid = '''+
							CAST(@parentConfigurationId AS NVARCHAR) +''' AND destination.configurationId =''' + CAST(@configurationId AS NVARCHAR) + '''
							AND destination.' + @mapColumn + ' <> source.'+ @mapColumn +';';

					EXEC (@sqlUpdateStatement)

					-- Inserting data when parent configuration data is deleted
					SET @sqlDeleteStatement = 'INSERT INTO tblMergeDetails (TaskId, TableName, ParentKey, ChildKey, MergeChoice, SelectedKey, action)
							SELECT ''' + CONVERT(nvarchar(36), @taskId) + ''',''' + @config_table + ''',' + 'source.' + @mapColumn + ',' + 'destination.'+ @mapColumn + ',
							1, NULL, ''Delete'' FROM  '+ @mapSchema + '.' + @mapTable +'  (NOLOCK) destination INNER JOIN '+ @mapSchema + '.' + @mapTable +'
							(NOLOCK) source ON source.' + @mapColumn + ' = destination.' + @mapColumn + ' AND source.configurationId = ''' + 
							Cast(@parentConfigurationId AS NVARCHAR) + ''' AND source.isDeleted = 1 AND 
							destination.configurationId IN(''' + Cast(@configurationId AS NVARCHAR) + ''');';

					 EXEC (@sqlDeleteStatement)

					-- Inserting data when new data is added to parent configuration
					SET @sqlInsertStatement = 'INSERT INTO tblMergeDetails (TaskId, TableName, ParentKey, ChildKey, MergeChoice, SelectedKey, action)
							SELECT ''' + CONVERT(nvarchar(36), @taskId) + ''',''' + @config_table + ''',' + @mapColumn + ',' + 'NULL, 1, NULL, ''Insert'' FROM 
							'+ @mapSchema + '.' + @mapTable + ' (NOLOCK) WHERE ' + @mapColumn + ' NOT IN (SELECT ' + @mapColumn + ' FROM ' + @mapSchema +
							'.' + @mapTable + ' (NOLOCK) WHERE configurationid IN(''' + Cast(@configurationId AS NVARCHAR) + ''')) AND  ' + @mapSchema + '.'
							+ @mapTable + '.configurationId = ''' + Cast(@parentConfigurationId AS NVARCHAR) + ''' AND '
							+ @mapSchema + '.' + @mapTable + '.isdeleted = 0 AND ' + @mapSchema + '.' + @mapTable + '.Previous' + @mapColumn + ' = 0;'

					 EXEC (@sqlInsertStatement)

					--Check if same record is updated in the another versions of Parent configuration 
					--and then update the latest mapcolumn value in merge details table ParentKey field
					DECLARE @tempDetails TABLE
					( id INT IDENTITY,
					  CurrentKey INT
					);
					DELETE FROM @tempDetails
					INSERT INTO @tempDetails
					SELECT ParentKey FROM tblMergeDetails WHERE TableName = @config_table AND TaskId = @taskId
					DECLARE @cnt INT
					DECLARE @cnt_total INT
					DECLARE @CurrentKey INT
					IF (SELECT COUNT(*) FROM @tempDetails) > 0
					BEGIN
						SELECT @cnt = min(id) , @cnt_total = max(id) FROM @tempDetails
						--Loop and update the latest mapping id
						WHILE @cnt <= @cnt_total
						BEGIN
							SELECT @CurrentKey = CurrentKey FROM @tempDetails WHERE id = @cnt 
							DECLARE @MergeDetailsUpdateStatement NVARCHAR(MAX)
							SET @MergeDetailsUpdateStatement = 'IF EXISTS (SELECT 1 FROM ' + @mapSchema + '.' + @mapTable + ' WHERE ' + @mapSchema + '.' + @mapTable + '.Previous' + @mapColumn + ' = ' + Cast(@CurrentKey AS NVARCHAR) + ' AND ConfigurationID = ' + Cast(@parentConfigurationId AS NVARCHAR) + ')' 
							 + 'BEGIN '
							 + 'UPDATE tblMergeDetails SET ParentKey = (SELECT ' + @mapColumn + ' FROM ' + @mapSchema + '.' + @mapTable + ' WHERE '+ @mapSchema + '.' + @mapTable + '.Previous' + @mapColumn + ' = ' + Cast(@CurrentKey AS NVARCHAR) + ' AND ConfigurationID = ' + Cast(@parentConfigurationId AS NVARCHAR)  + ')' 
							 + ' WHERE ParentKey = ' + Cast(@CurrentKey AS NVARCHAR) 
							 + ' AND TaskId = ''' + convert(NVARCHAR(36), @taskId)
							 + ''' END'
							--PRINT @MergeDetailsUpdateStatement
							EXEC (@MergeDetailsUpdateStatement)
							SET @cnt = @cnt + 1
						END
					END
					FETCH next FROM cur_tbl INTO @config_table
				END

			CLOSE cur_tbl
			DEALLOCATE cur_tbl
			
			COMMIT TRAN
		END TRY

		BEGIN CATCH
			ROLLBACK TRAN
			UPDATE tblTasks SET DetailedStatus = 'Not Started', TaskStatusID = 1, DateLastUpdated = GETDATE() WHERE ID = @taskId
			--print 'after update'
		END CATCH
END
GO