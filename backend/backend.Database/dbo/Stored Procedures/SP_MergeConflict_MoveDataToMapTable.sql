DROP PROCEDURE IF EXISTS [dbo].[SP_MergeConflict_MoveDataToMapTable]
--[dbo].[Sp_mergeconflict_movedatatomaptable]	 105,'d9978e53-2715-461d-b5d2-7c8c05896286'
GO
SET ansi_nulls ON
GO
SET quoted_identifier ON
GO
CREATE PROC [dbo].[Sp_mergeconflict_movedatatomaptable]
  @configurationId INT,
  @taskId UNIQUEIDENTIFIER
AS
  BEGIN
    SELECT *
    INTO   #tempmergedetails_updated
    FROM   tblmergedetails
    WHERE  taskid=@taskId
    AND    (selectedkey!=childkey OR SelectedKey IS NULL)
    --Added records will be added here
    -- lop the above results and insert/update into the mapping for the child config id

	SELECT * FROM #tempmergedetails_updated
    DECLARE cur_tbl CURSOR local static forward_only read_only FOR
    SELECT tablename,
           selectedkey,
           childkey,
           action
    FROM   #tempmergedetails_updated
    OPEN cur_tbl
    DECLARE @tableName VARCHAR(50),
      @ChildKey        INT,
      @selectedKey     INT,
      @action          VARCHAR(20)
    FETCH next
    FROM  cur_tbl
    INTO  @tableName,
          @selectedKey,
          @ChildKey,
          @action
    print @tableName
    WHILE @@FETCH_STATUS = 0
    BEGIN
      DECLARE @sql_update NVARCHAR(max)
      DECLARE @mapTable   VARCHAR(max) = @tableName + 'Map'
      DECLARE @mapColumn  VARCHAR(max)
      DECLARE @dataColumn VARCHAR(max)
      DECLARE @mapSchema  VARCHAR(max)
      EXEC dbo.Sp_configmanagement_findmappingbetween
        @mapTable,
        @tableName,
        @mapColumn output,
        @dataColumn output,
        @mapSchema output
      IF @action = 'update'
      BEGIN
        SET @sql_update= 'update toUpdate set Previous'+@mapColumn +' = toUpdate.'+@mapColumn+', toUpdate.'+@mapColumn+' = '+Cast(@selectedKey AS NVARCHAR)+' FROM '
		+@mapSchema + '.' + @mapTable+' (nolock) toUpdate WHERE toUpdate.configurationId IN( '+Cast(@configurationId AS NVARCHAR)+' ) AND 
		toUpdate.'+@mapColumn+' = '+Cast(@ChildKey AS NVARCHAR)+' AND '+Cast(@ChildKey AS NVARCHAR)+' <> '+Cast(@selectedKey AS NVARCHAR)+';';
        print @sql_update
		EXEC sys.Sp_executesql
          @sql_update
      END
      ELSE
      IF @action='Insert'
      BEGIN
        DECLARE @sql_insert NVARCHAR(max)
        SET @sql_insert='insert into '+@mapSchema + '.' + @mapTable+' ('+@mapColumn+', configurationid, Previous'+@mapColumn+', isdeleted) VALUES( '+ @selectedKey+','+@configurationId+',NULL,0)';
        EXEC sys.Sp_executesql
          @sql_insert
      END
      ELSE
      IF @action = 'Delete'
      BEGIN
        DECLARE @sql_delete NVARCHAR(max)
        SET @sql_delete= 'update toUpdate set toUpdate.isDeleted = 1 from '+@mapSchema + '.' + @mapTable+'  (NOLOCK) toUpdate toUpdate.'+@mapColumn+'='+@selectedKey+' toUpdate.configurationId IN( '+Cast(@configurationId AS NVARCHAR)+' );';
        EXEC sys.Sp_executesql
          @sql_delete
      END

FETCH next
    FROM  cur_tbl
    INTO  @tableName,
          @selectedKey,
          @ChildKey,
          @action

    END
    CLOSE cur_tbl
    DEALLOCATE cur_tbl
  END
  
  GO