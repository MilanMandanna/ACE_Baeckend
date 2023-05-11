-- Main Goal of this SP is to keep the Parent and Child Config values to be in Sync in all Mapping tables
--1.Get the Child config Ids for input Config ID(Parent)
--2.Loop for all child config ids
--3.Get the config table names from config_tables and loop it
--4.Each table for child config id will be updated with Parent config values
--5.Repeat the process for all child config ids

--1.For the given config id, find all the child config ids and update the config values from input config id to child config id
--2.config_tables --> new table created which holds all the config tables
--	SELECT * INTO #TEMPMapTbl FROM sys.tables tab WHERE NAME LIKE'%Map'
--	SELECT SUBSTRING(NAME,1,len(NAME)-3) AS NAME INTO config_tables FROM #TEMPMapTbl;
--	select * from config_tables
--3. This process will update all the child config id map tables wiht parent config map tables

GO
IF OBJECT_ID('[dbo].[SP_ConfigManagement_MergeConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigManagement_MergeConfig]
END
GO
CREATE PROC [dbo].[SP_ConfigManagement_MergeConfig] 
@configId INT,
@childConfigId INT,
@userId NVARCHAR(200),
@taskId NVARCHAR(100)
AS
  BEGIN

drop table if exists #temp_configdefid_extract
drop table if exists #temp_child_configdefid_extract
drop table if exists #tempconfigid

CREATE TABLE #tempconfigid(configurationid INT);
-- [dbo].[SP_Configuration_GetAllChlildConfigs] returns list of child config id for given config id
--INSERT INTO #tempconfigid Exec [dbo].[SP_Configuration_GetAllChlildConfigs] @configId
INSERT INTO #tempconfigid VALUES(@childConfigId);

	DECLARE @tempTable TABLE(configurationId INT)
	INSERT INTO @tempTable SELECT * FROM #tempconfigid

      DECLARE @parent_keyValue NVARCHAR(10),
              @child_keyVal    NVARCHAR(10),
			  @userName		   NVARCHAR(100),
			  @configurationId INT
      DECLARE @config_table VARCHAR(100)
      DECLARE @sql NVARCHAR(MAX)
	  DECLARE @sql_1 NVARCHAR(MAX)

	  --select * from #tempconfigid

 DECLARE cur_tbl CURSOR  LOCAL STATIC FORWARD_ONLY READ_ONLY
 FOR
              SELECT tblName
              FROM   tblConfigTables WHERE IsUsedForMergeConfiguration = 1

            OPEN cur_tbl

            FETCH next FROM cur_tbl INTO @config_table
			--print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN
                  --select value from parent and child config id and call the SP_ConfigManagement_HandleMerge (pass child config id)
                  DECLARE @mapTable VARCHAR(max) = @config_table + 'Map'
                  DECLARE @mapColumn VARCHAR(max)
                  DECLARE @dataColumn VARCHAR(max)
                  DECLARE @mapSchema VARCHAR(max)


                  EXEC dbo.Sp_configmanagement_findmappingbetween
                    @mapTable,
                    @config_table,
                    @mapColumn output,
                    @dataColumn output,
                    @mapSchema output

					--dECLARE @start_time DATETIME=GETDATE();
                  --Getting parent key val
                  
					DECLARE @sql_update NVARCHAR(MAX),@sql_delete NVARCHAR(MAX),@sql_insert NVARCHAR(MAX)

					--print 'running updates'
					SET  @sql_update= 'update toUpdate
							set Previous'+@mapColumn +' = toUpdate.'+@mapColumn+', 
								'+@mapColumn+' = Source.'+@mapColumn+'
							FROM '+@mapSchema + '.' + @mapTable+' (nolock) toUpdate
								inner join '+@mapSchema + '.' + @mapTable+' (nolock) Source on
									source.Previous'+@mapColumn +' = ToUpdate.'+@mapColumn+' and
									source.configurationid = '+Cast(@configId AS NVARCHAR)+' and
									toUpdate.configurationId IN( SELECT configurationid FROM #tempconfigid ) AND toUpdate.'+@mapColumn+'
									<> Source.'+@mapColumn+';';

					--PRINT @sql_update

					EXEC sys.Sp_executesql @sql_update
						-- handle deletions
						--print 'running deletions'
							SET @sql_delete= 'update toUpdate 
							set toUpdate.isDeleted = 1 
							from '+@mapSchema + '.' + @mapTable+'  (NOLOCK) toUpdate
								inner join '+@mapSchema + '.' + @mapTable+'  (NOLOCK) source on
									source.'+@mapColumn+' = toUpdate.'+@mapColumn+' and
									source.configurationId = '+Cast(@configId AS NVARCHAR)+' and
									source.isDeleted = 1 and
									toUpdate.configurationId IN( SELECT configurationid FROM #tempconfigid );';

						--print @sql_delete
						EXEC sys.Sp_executesql @sql_delete
						--		print 'running additions'
							SET @sql_insert='insert into '+@mapSchema + '.' + @mapTable+' ('+@mapColumn+', configurationid, Previous'+@mapColumn+', isdeleted) 
								select distinct '+@mapColumn+', B.configurationid, null, 0
								from '+@mapSchema + '.' + @mapTable+' (NOLOCK),#tempconfigid B 
								where '+@mapColumn+' not in (select '+@mapColumn+' from '+@mapSchema + '.' + @mapTable+' (nolock) where configurationid IN( SELECT configurationid FROM #tempconfigid)) and 
								'+@mapSchema + '.' + @mapTable+'.configurationId = '+Cast(@configId AS NVARCHAR)+' and 
								'+@mapSchema + '.' + @mapTable+'.isdeleted = 0;';
					--PRINT @sql_insert
					EXEC sys.Sp_executesql @sql_insert
                  FETCH next FROM cur_tbl INTO @config_table
              END

			  SET @userName = (SELECT FirstName + ' ' + LastName FROM AspNetUsers WHERE Id = @userId)
			  WHILE (SELECT COUNT(*) FROM @tempTable) > 0
				BEGIN
					SET @configurationId = (SELECT TOP 1 configurationId FROM @tempTable)

					DECLARE @comment NVARCHAR(MAX)
					SET @comment = ('Merging configuration data from ' + (SELECT CT.Name FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
					WHERE C.ConfigurationID = @configId) + ' configuration version V' + Convert(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					WHERE C.ConfigurationID = @configId)) + ' to ' + (SELECT CT.Name FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
					WHERE C.ConfigurationID = @configurationId) + ' configuration version V' + Convert(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
					INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
					WHERE C.ConfigurationID = @configurationId)))

					IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'Merging Configuration' AND ConfigurationID = @configid)
					BEGIN
						UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@taskId), CommentAddedBy = @userName
						WHERE ContentType = 'airports' AND ConfigurationID = @configid
					END
					ELSE
					BEGIN
						INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
						VALUES(@configid,'Merging Configuration',@userName,GETDATE(),CONVERT(uniqueidentifier,@taskId),@comment)
					END

					DELETE FROM @tempTable WHERE configurationId = @configurationId
				END
            CLOSE cur_tbl

            DEALLOCATE cur_tbl

  END

GO