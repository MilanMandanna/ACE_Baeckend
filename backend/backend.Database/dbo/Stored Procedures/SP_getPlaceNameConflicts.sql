/****** Object:  StoredProcedure [dbo].[SP_getPlaceNameConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getPlaceNameConflicts]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getPlaceNameConflicts]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getPlaceNameConflicts]    Script Date: 9/29/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_getPlaceNameConflicts]
@taskId UNIQUEIDENTIFIER
AS
BEGIN

 DROP TABLE IF EXISTS #TEMP_PLACENAME_PARENT
  DROP TABLE IF EXISTS #TEMP_PLACENAME_CHILD
    DROP TABLE IF EXISTS #TEMP

CREATE TABLE #TEMP_PLACENAME_PARENT(ID INT,MergeChoice INT, SelectedKey INT,GeoRefId INT, Description nvarchar(max), CountryId INT,Country NVARCHAR(MAX), RegionId INT, Region nvarchar(max), CatTypeId INT, Category nvarchar(max), SpellingId INT, Translation nvarchar(max),LanguageId INT, LanguageName nvarchar(max), Lat1 decimal, Lat2 decimal, Lon1 decimal, Lon2 decimal, Resolution decimal, Exclude bit, Priority INT);
CREATE TABLE #TEMP_PLACENAME_CHILD(ID INT,MergeChoice INT, SelectedKey INT,GeoRefId INT, Description nvarchar(max), CountryId INT,Country NVARCHAR(MAX), RegionId INT,Region nvarchar(max),CatTypeId INT, Category nvarchar(max), SpellingId INT, Translation nvarchar(max), LanguageId INT, LanguageName nvarchar(max), Lat1 decimal, Lat2 decimal, Lon1 decimal, Lon2 decimal, Resolution decimal, Exclude bit, Priority INT);
 
SELECT ID,ChildKey,ParentKey,TableName,SelectedKey,MergeChoice INTO #TEMP FROM tblMergeDetails where MergeChoice NOT IN(1,3) AND TableName IN('tblGeoRef', 'tblCoverageSegment', 'tblSpelling', 'tblAppearance') AND TaskId = @taskId;
 
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

                                 IF @TableName='tblGeoRef'
                                 BEGIN
									 INSERT INTO #TEMP_PLACENAME_PARENT(ID,MergeChoice,SelectedKey, GeoRefId, Description, Country, Region, Category) 
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description, ctry.Description, RegionName, cat.Description 
									 FROM tblGeoRef geo 
									 INNER JOIN tblCountry ctry on geo.CountryId = ctry.CountryID
									 INNER JOIN tblRegionSpelling spel on geo.RegionID=spel.RegionID and spel.LanguageId=1
									 INNER JOIN tblCategoryType cat on geo.AsxiCatTypeId = cat.CategoryTypeID
									 WHERE geo.ID in(@ParentKey);
 
									 INSERT INTO #TEMP_PLACENAME_CHILD(ID,MergeChoice,SelectedKey, GeoRefId, Description, Country, Region, Category) 
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId, geo.Description, ctry.Description, RegionName, cat.Description 
									 FROM tblGeoRef geo 
									 INNER JOIN tblCountry ctry on geo.CountryId = ctry.CountryID
									 INNER JOIN tblRegionSpelling spel on geo.RegionID=spel.RegionID and spel.LanguageId=1
									 INNER JOIN tblCategoryType cat on geo.AsxiCatTypeId = cat.CategoryTypeID
									 WHERE geo.ID in(@ChildKey);
                                 END

                                 IF @TableName='tblSpelling'
                                 BEGIN
									 INSERT INTO #TEMP_PLACENAME_PARENT(ID,MergeChoice,SelectedKey,GeoRefId,Description,Translation, LanguageName)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,spel.UnicodeStr,lang.Name 
									 FROM tblSpelling spel 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=spel.GeoRefID 
									 INNER JOIN tblLanguages lang ON spel.LanguageID = lang.LanguageID
									 WHERE spel.SpellingID in(@ParentKey);
 
									 INSERT INTO #TEMP_PLACENAME_CHILD(ID,MergeChoice,SelectedKey,GeoRefId,Description,Translation, LanguageName)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,spel.UnicodeStr,lang.Name 
									 FROM tblSpelling spel 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=spel.GeoRefID 
									 INNER JOIN tblLanguages lang ON spel.LanguageID = lang.LanguageID 
									 WHERE spel.SpellingID in(@ChildKey);
                                 END

								 IF @TableName = 'tblCoverageSegment'
								 BEGIN
									INSERT INTO #TEMP_PLACENAME_PARENT(ID,MergeChoice,SelectedKey,GeoRefId,Description,Lat1,Lat2,Lon1,Lon2)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,seg.Lat1,seg.Lat2,seg.Lon1,seg.Lon2 
									 FROM tblCoverageSegment seg 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=seg.GeoRefID 
									 WHERE seg.ID in(@ParentKey);
 
									 INSERT INTO #TEMP_PLACENAME_CHILD(ID,MergeChoice,SelectedKey,GeoRefId,Description,Lat1,Lat2,Lon1,Lon2)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,seg.Lat1,seg.Lat2,seg.Lon1,seg.Lon2  
									 FROM tblCoverageSegment seg 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=seg.GeoRefID 
									 WHERE seg.ID in(@ChildKey);
								 END

								 IF @TableName = 'tblAppearance'
								 BEGIN
									INSERT INTO #TEMP_PLACENAME_PARENT(ID,MergeChoice,SelectedKey,GeoRefId,Description,Resolution,Exclude,Priority)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,appear.Resolution,appear.Exclude,appear.Priority
									 FROM tblAppearance appear 
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=appear.GeoRefID 
									 WHERE appear.AppearanceID in(@ParentKey);
 
									 INSERT INTO #TEMP_PLACENAME_CHILD(ID,MergeChoice,SelectedKey,GeoRefId,Description,Resolution,Exclude,Priority)
									 SELECT @ID,@MergeChoice,@SelectedKey,geo.GeoRefId,geo.Description,appear.Resolution,appear.Exclude,appear.Priority  
									 FROM tblAppearance appear
									 INNER JOIN tblGeoRef geo ON geo.GeoRefId=appear.GeoRefID 
									 WHERE appear.AppearanceID in(@ChildKey);
								 END
                           FETCH next FROM cur_tbl INTO @ID,@ChildKey,@ParentKey,@TableName,@MergeChoice,@SelectedKey
                      END
 
 CLOSE cur_tbl

            DEALLOCATE cur_tbl
--compare 2 tables and display the values
--select * from  #TEMP_PLACENAME_PARENT
--select * from  #TEMP_PLACENAME_CHILD
DECLARE @TEMP_RESULT TABLE(ID INT, GeoRefID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX))
INSERT INTO @TEMP_RESULT
 Select ID, GeoRefId, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end)
 From ( Select Src=1, ID, GeoRefId, LanguageName, B.*
         From #TEMP_PLACENAME_PARENT A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
		 B
        Union All
        Select Src=2, ID, GeoRefId, LanguageName, B.*
         From #TEMP_PLACENAME_CHILD A
         Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
		 B
      ) A
 Group By ID, GeoRefId, LanguageName, [key]
 Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
 Order By ID, [key]

-- SELECT * FROM #TEMP_RESULT

SELECT t.ID, t.GeoRefID AS ContentID, 'PlaceName' AS ContentType, g.Description AS Description, 
 CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS DisplayName, 
 t.Parent_value AS ParentValue, t.Child_value AS ChildValue, 
 CASE WHEN m.SelectedKey = m.ParentKey THEN t.Parent_value  WHEN m.SelectedKey = m.ChildKey THEN t.Child_Value ELSE NULL END AS SelectedValue  
 FROM @TEMP_RESULT t, tblMergeDetails m, tblGeoRef g WHERE t.ID = m.ID AND t.GeoRefID = g.ID

END
