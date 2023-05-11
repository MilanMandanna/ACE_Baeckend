/****** Object:  StoredProcedure [dbo].[SP_getRegionConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getRegionConflicts]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getRegionConflicts]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getRegionConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_getRegionConflicts]
@taskId UNIQUEIDENTIFIER
AS
BEGIN
 
  DROP TABLE IF EXISTS #TEMP_REGION_PARENT
  DROP TABLE IF EXISTS #TEMP_REGION_CHILD
    DROP TABLE IF EXISTS #TEMP

CREATE TABLE #TEMP_REGION_PARENT(ID INT,MergeChoice INT, SelectedKey INT,RegionId int,RegionSpellingId INT,Translation NVARCHAR(MAX),LanguageId int,LanguageName varchar(100));
CREATE TABLE #TEMP_REGION_CHILD(ID INT,MergeChoice INT, SelectedKey INT,RegionId int, RegionSpellingId INT,Translation NVARCHAR(MAX),LanguageId int,LanguageName varchar(100));
 
SELECT ID,ChildKey,ParentKey,TableName,SelectedKey,MergeChoice INTO #TEMP FROM tblMergeDetails where MergeChoice NOT IN(1,3) AND TableName IN('tblRegionSpelling') AND TaskId = @taskId;
 
DECLARE @TableName varchar(50),@ParentKey INT,@ChildKey INT,@MergeChoice INT,@SelectedKey INT,@ID INT
 
DECLARE cur_tbl CURSOR 
 FOR
              SELECT ID,ChildKey,ParentKey,TableName,MergeChoice,SelectedKey
              FROM   #TEMP
 
                      OPEN cur_tbl
 
            FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                    --print @config_table
            WHILE @@FETCH_STATUS = 0
              BEGIN
                              
                                 insert into #TEMP_REGION_PARENT(ID,MergeChoice,SelectedKey,regionId,Translation,LanguageName) 
                                 
                                                      SELECT @ID,@MergeChoice,@SelectedKey,spel.RegionID, RegionName,lang.Name FROM tblRegionSpelling spel 
                                 INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID 
                                 WHERE spel.SpellingID in(@ParentKey);
 
                                 insert into #TEMP_REGION_CHILD(ID,MergeChoice,SelectedKey,regionId,Translation,LanguageName)  
                                 
                                                      SELECT @ID,@MergeChoice,@SelectedKey,spel.RegionID,RegionName,lang.Name FROM tblRegionSpelling spel 
                                 INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID 
                                 WHERE spel.SpellingID in(@ChildKey);
 
                           FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                      END
 
 CLOSE cur_tbl

            DEALLOCATE cur_tbl
--compare 2 tables and display the values

DECLARE @TEMP_RESULT TABLE(ID INT, RegionID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX))
INSERT INTO @TEMP_RESULT
Select ID, RegionID, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end)
From ( Select Src=1, ID, RegionID, LanguageName, B.*
         From #TEMP_REGION_PARENT A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
               B
        Union All
        Select Src=2, ID, RegionID, LanguageName,B.*
         From #TEMP_REGION_CHILD A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
               B
      ) A
Group By ID, RegionID, LanguageName, [key]
Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
Order By ID, [key]
 
--SELECT * FROM @TEMP_RESULT
 
SELECT t.ID, t.RegionID AS ContentID, 'Region' AS ContentType, r.RegionName AS Description, 
 CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS DisplayName,
 t.Parent_value AS ParentValue, t.Child_value AS ChildValue, 
 CASE WHEN m.SelectedKey = m.ParentKey THEN t.Parent_value  WHEN m.SelectedKey = m.ChildKey THEN t.Child_Value ELSE NULL END AS SelectedValue 
 FROM @TEMP_RESULT t, tblMergeDetails m, tblRegionSpelling r WHERE t.ID = m.ID AND t.RegionID = r.RegionID AND r.LanguageId = 1 AND r.RegionName <> t.Parent_value
 
END
