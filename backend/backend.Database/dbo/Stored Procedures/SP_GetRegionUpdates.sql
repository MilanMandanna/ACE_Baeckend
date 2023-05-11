/****** Object:  StoredProcedure [dbo].[SP_GetRegionUpdates]    Script Date: 11/02/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetRegionUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetRegionUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetRegionUpdates]    Script Date: 11/02/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_GetRegionUpdates]
	@tableXml XML
AS
BEGIN
 
	DROP TABLE IF EXISTS #TEMP_REGION_PARENT
	DROP TABLE IF EXISTS #TEMP_REGION_CHILD
    DROP TABLE IF EXISTS #TEMP

	CREATE TABLE #TEMP_REGION_PARENT(ID INT, RegionId INT,RegionSpellingId INT,Translation NVARCHAR(MAX),LanguageId int,LanguageName varchar(100),Action NVARCHAR(10));
	CREATE TABLE #TEMP_REGION_CHILD(ID INT, RegionId INT, RegionSpellingId INT,Translation NVARCHAR(MAX),LanguageId int,LanguageName varchar(100),Action NVARCHAR(10));
 
	CREATE TABLE #TEMP (ID INT IDENTITY, TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(10))
	INSERT INTO #TEMP 
	SELECT Tbl.Col.value('@TableName', 'NVARCHAR(100)') AS TableName,  Tbl.Col.value('@CurrentKey', 'INT') AS CurrentKey,  
       Tbl.Col.value('@PreviousKey', 'INT') AS PreviousKey, Tbl.Col.value('@Action', 'NVARCHAR(10)') AS Action 
	FROM   @tableXml.nodes('//row') Tbl(Col) WHERE Tbl.Col.value('@TableName', 'NVARCHAR(100)') IN ('tblRegionSpelling');
 
	DECLARE @ID INT, @TableName VARCHAR(50),@ParentKey INT,@ChildKey INT, @Action NVARCHAR(10)

	DECLARE cur_tbl CURSOR 
	FOR
	SELECT ID,TableName,PreviousKey,CurrentKey,Action
	FROM   #TEMP WHERE Action = 'Update'
	
	OPEN cur_tbl
	FETCH next FROM cur_tbl INTO @ID, @TableName ,@ParentKey ,@ChildKey, @Action 
	WHILE @@FETCH_STATUS = 0
	BEGIN                              
		INSERT INTO #TEMP_REGION_PARENT(ID, RegionId,Translation,LanguageName,Action) 
        SELECT @ID, spel.RegionID, RegionName,lang.Name,@Action FROM tblRegionSpelling spel 
		INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID 
		WHERE spel.SpellingID in(@ParentKey);
 
		INSERT INTO #TEMP_REGION_CHILD(ID, RegionId,Translation,LanguageName,Action)  
        SELECT @ID, spel.RegionID,RegionName,lang.Name,@Action FROM tblRegionSpelling spel 
		INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID 
		WHERE spel.SpellingID in(@ChildKey);
		
		FETCH NEXT FROM cur_tbl INTO @ID,@TableName, @ParentKey, @ChildKey, @Action
	END 
	CLOSE cur_tbl
	DEALLOCATE cur_tbl
	--compare 2 tables and display the values

	DECLARE @TEMP_RESULT TABLE(ID INT, RegionID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX), Action NVARCHAR(10))
	INSERT INTO @TEMP_RESULT
	SELECT ID, RegionID, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end), Action
	FROM ( SELECT Src=1, ID, RegionID, LanguageName, Action, B.*
			 FROM #TEMP_REGION_PARENT A
			 CROSS APPLY (SELECT [Key], Value FROM OPENJSON((SELECT A.* For JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES))) 
				   B
			UNION ALL
			SELECT Src=2, ID, RegionID, LanguageName, Action, B.*
			 FROM #TEMP_REGION_CHILD A
			 CROSS APPLY (SELECT [Key], Value FROM OPENJSON((SELECT A.* FOR JSON PATH,WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES))) 
				   B
		  ) A
	GROUP BY ID, RegionID, LanguageName, [key], Action
	HAVING MAX(CASE WHEN Src=1 THEN Value END) <> MAX(CASE WHEN Src=2 THEN Value END)
	ORDER BY ID, [key]
 
	--SELECT * FROM @TEMP_RESULT
 
	SELECT t.RegionID AS ContentID, 'Region' AS ContentType, r.RegionName AS Name, 
	CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS Field,
	t.Parent_value AS PreviousValue, t.Child_value AS CurrentValue , t.Action
	FROM @TEMP_RESULT t, tblRegionSpelling r WHERE t.RegionID = r.RegionID AND r.LanguageId = 1 AND r.RegionName <> t.Parent_value
	UNION
	SELECT t.CurrentKey AS ContentID, 'Region' AS ContentType, r.RegionName AS Name, NULL, NULL, NULL, t.Action
	FROM #TEMP t, tblRegionSpelling r WHERE t.CurrentKey = r.RegionID AND r.LanguageId = 1 AND t.Action IN ('Insert', 'Delete')
END
