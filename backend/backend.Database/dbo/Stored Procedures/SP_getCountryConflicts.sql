/****** Object:  StoredProcedure [dbo].[SP_getCountryConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getCountryConflicts]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getCountryConflicts]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getCountryConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_getCountryConflicts]
@taskId UNIQUEIDENTIFIER
AS
BEGIN

 DROP TABLE IF EXISTS #TEMP_COUNTRY_PARENT
  DROP TABLE IF EXISTS #TEMP_COUNTRY_CHILD
    DROP TABLE IF EXISTS #TEMP

CREATE TABLE #TEMP_COUNTRY_PARENT(ID INT,MergeChoice INT, SelectedKey INT,CountryId INT,CountrySpellingId INT,Translation NVARCHAR(MAX),Description NVARCHAR(MAX),regionId int,Region nvarchar(max),LanguageId int,LanguageName varchar(100));
CREATE TABLE #TEMP_COUNTRY_CHILD(ID INT,MergeChoice INT, SelectedKey INT,CountryId INT,CountrySpellingId INT,Translation NVARCHAR(MAX),Description NVARCHAR(MAX),regionId int,Region nvarchar(max),LanguageId int,LanguageName varchar(100));
 
SELECT ID,ChildKey,ParentKey,TableName,SelectedKey,MergeChoice INTO #TEMP FROM tblMergeDetails where MergeChoice NOT in(3,1) AND TableName IN('tblCountry','tblCountrySpelling') AND TaskId = @taskId;
 
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
 
                                 IF @TableName='tblCountry'
                                 begin
                                 insert into #TEMP_COUNTRY_PARENT(ID,MergeChoice,SelectedKey,CountryId,Description,Region) 
                                 SELECT @ID,@MergeChoice,@SelectedKey,CountryID,Description,RegionName FROM tblCountry ctry 
                                 INNER JOIN tblRegionSpelling spel on ctry.RegionID=spel.RegionID and spel.LanguageId=1
                                 WHERE ID in(@ParentKey);
 
                                 insert into #TEMP_COUNTRY_CHILD(ID,MergeChoice,SelectedKey,CountryId,Description,Region) 
                                 SELECT @ID,@MergeChoice,@SelectedKey,CountryID,Description,RegionName FROM tblCountry ctry 
                                 INNER JOIN tblRegionSpelling spel on ctry.RegionID=spel.RegionID and spel.LanguageId=1
                                 WHERE ID in(@ChildKey);
 
                                 end
                                 IF @TableName='tblCountrySpelling'
                                 begin
                                 insert into #TEMP_COUNTRY_PARENT(ID,MergeChoice,SelectedKey,CountryId,Description,Translation,LanguageName)
                                 SELECT @ID,@MergeChoice,@SelectedKey,ctry.CountryID,ctry.Description,CountryName, lang.Name FROM tblCountrySpelling spel 
                                 INNER JOIN tblCountry ctry ON ctry.CountryID=spel.CountryID
								 INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID WHERE CountrySpellingID in(@ParentKey);
 
                                 insert into #TEMP_COUNTRY_CHILD(ID,MergeChoice,SelectedKey,CountryId,Description,Translation,LanguageName)
                                 SELECT @ID,@MergeChoice,@SelectedKey,ctry.CountryID,ctry.Description,CountryName, lang.Name FROM tblCountrySpelling spel 
                                 INNER JOIN tblCountry ctry ON ctry.CountryID=spel.CountryID
								 INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID WHERE CountrySpellingID in(@ChildKey);
 
                                 end
                           FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                      END
 
 CLOSE cur_tbl

            DEALLOCATE cur_tbl

--compare 2 tables and display the values
--select * from  #TEMP_COUNTRY_PARENT
--select * from  #TEMP_COUNTRY_CHILD
DECLARE @TEMP_RESULT TABLE(ID INT, CountryID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX))
INSERT INTO @TEMP_RESULT
 Select ID, CountryId,LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end)
 From ( Select Src=1, ID, CountryId,LanguageName, B.*
         From #TEMP_COUNTRY_PARENT A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
		 B
        Union All
        Select Src=2, ID, CountryId, LanguageName, B.*
         From #TEMP_COUNTRY_CHILD A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
		 B
      ) A
 Group By ID, CountryId,LanguageName, [key]
 Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
 Order By ID, [key]

-- SELECT * FROM #TEMP_RESULT

SELECT t.ID, t.CountryID AS ContentID, 'Country' AS ContentType, c.Description AS Description, 
 CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS DisplayName, 
 t.Parent_value AS ParentValue, t.Child_value AS ChildValue, 
 CASE WHEN m.SelectedKey = m.ParentKey THEN t.Parent_value  WHEN m.SelectedKey = m.ChildKey THEN t.Child_Value ELSE NULL END AS SelectedValue 
 FROM @TEMP_RESULT t, tblMergeDetails m, tblCountry c WHERE t.ID = m.ID AND t.CountryID = c.ID

END
