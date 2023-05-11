/****** Object:  StoredProcedure [dbo].[SP_getPlaceNameUpdates]    Script Date: 11/03/2022 12:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_getPlaceNameUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_getPlaceNameUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getPlaceNameUpdates]    Script Date: 11/03/2022 12:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_getPlaceNameUpdates]
	@tableXml XML
AS
BEGIN

	DROP TABLE IF EXISTS #TEMP_PLACENAME_PARENT
	DROP TABLE IF EXISTS #TEMP_PLACENAME_CHILD
    DROP TABLE IF EXISTS #TEMP

	CREATE TABLE #TEMP_PLACENAME_PARENT(ID INT,GeoRefId INT, Description nvarchar(max), CountryId INT,Country NVARCHAR(MAX), RegionId INT, Region nvarchar(max), CatTypeId INT, Category nvarchar(max), SpellingId INT, Translation nvarchar(max),LanguageId INT, LanguageName nvarchar(max), Lat1 decimal, Lat2 decimal, Lon1 decimal, Lon2 decimal, Resolution decimal, Exclude bit, Priority INT, Action NVARCHAR(10));
	CREATE TABLE #TEMP_PLACENAME_CHILD(ID INT,GeoRefId INT, Description nvarchar(max), CountryId INT,Country NVARCHAR(MAX), RegionId INT,Region nvarchar(max),CatTypeId INT, Category nvarchar(max), SpellingId INT, Translation nvarchar(max), LanguageId INT, LanguageName nvarchar(max), Lat1 decimal, Lat2 decimal, Lon1 decimal, Lon2 decimal, Resolution decimal, Exclude bit, Priority INT, Action NVARCHAR(10));
 
	CREATE TABLE #TEMP (ID INT IDENTITY, TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(10))
	INSERT INTO #TEMP 
	SELECT Tbl.Col.value('@TableName', 'NVARCHAR(100)') AS TableName,  Tbl.Col.value('@CurrentKey', 'INT') AS CurrentKey,  
       Tbl.Col.value('@PreviousKey', 'INT') AS PreviousKey, Tbl.Col.value('@Action', 'NVARCHAR(10)') AS Action 
	FROM   @tableXml.nodes('//row') Tbl(Col) WHERE Tbl.Col.value('@TableName', 'NVARCHAR(100)') IN ('tblGeoRef', 'tblCoverageSegment', 'tblSpelling', 'tblAppearance');
 
	DECLARE @ID INT, @TableName VARCHAR(50),@ParentKey INT,@ChildKey INT, @Action NVARCHAR(10)

	DECLARE cur_tbl CURSOR 
	FOR
	SELECT ID,TableName,PreviousKey,CurrentKey,Action
	FROM   #TEMP WHERE Action = 'Update'
	
	OPEN cur_tbl
	FETCH next FROM cur_tbl INTO @ID,@TableName ,@ParentKey ,@ChildKey, @Action 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @TableName='tblGeoRef'
		BEGIN
			INSERT INTO #TEMP_PLACENAME_PARENT(ID, GeoRefId, Description, Country, Region, Category,Action) 
			SELECT @ID,geo.GeoRefId,geo.Description, ctry.Description, RegionName, cat.Description, @Action 
			FROM tblGeoRef geo 
			INNER JOIN tblCountry ctry on geo.CountryId = ctry.CountryID
			INNER JOIN tblRegionSpelling spel on geo.RegionID=spel.RegionID and spel.LanguageId=1
			INNER JOIN tblCategoryType cat on geo.AsxiCatTypeId = cat.CategoryTypeID
			WHERE geo.ID in(@ParentKey);
 
			INSERT INTO #TEMP_PLACENAME_CHILD(ID, GeoRefId, Description, Country, Region, Category,Action) 
			SELECT @ID,geo.GeoRefId, geo.Description, ctry.Description, RegionName, cat.Description, @Action 
			FROM tblGeoRef geo 
			INNER JOIN tblCountry ctry on geo.CountryId = ctry.CountryID
			INNER JOIN tblRegionSpelling spel on geo.RegionID=spel.RegionID and spel.LanguageId=1
			INNER JOIN tblCategoryType cat on geo.AsxiCatTypeId = cat.CategoryTypeID
			WHERE geo.ID in(@ChildKey);
		END

		IF @TableName='tblSpelling'
		BEGIN
			INSERT INTO #TEMP_PLACENAME_PARENT(ID,GeoRefId,Description,Translation, LanguageName,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,spel.UnicodeStr,lang.Name, @Action 
			FROM tblSpelling spel 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=spel.GeoRefID 
			INNER JOIN tblLanguages lang ON spel.LanguageID = lang.LanguageID
			WHERE spel.SpellingID in(@ParentKey);
 
			INSERT INTO #TEMP_PLACENAME_CHILD(ID,GeoRefId,Description,Translation, LanguageName,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,spel.UnicodeStr,lang.Name, @Action 
			FROM tblSpelling spel 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=spel.GeoRefID 
			INNER JOIN tblLanguages lang ON spel.LanguageID = lang.LanguageID 
			WHERE spel.SpellingID in(@ChildKey);
		END

		IF @TableName = 'tblCoverageSegment'
		BEGIN
		INSERT INTO #TEMP_PLACENAME_PARENT(ID,GeoRefId,Description,Lat1,Lat2,Lon1,Lon2,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,seg.Lat1,seg.Lat2,seg.Lon1,seg.Lon2, @Action 
			FROM tblCoverageSegment seg 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=seg.GeoRefID 
			WHERE seg.ID in(@ParentKey);
 
			INSERT INTO #TEMP_PLACENAME_CHILD(ID,GeoRefId,Description,Lat1,Lat2,Lon1,Lon2,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,seg.Lat1,seg.Lat2,seg.Lon1,seg.Lon2, @Action  
			FROM tblCoverageSegment seg 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=seg.GeoRefID 
			WHERE seg.ID in(@ChildKey);
		END

		IF @TableName = 'tblAppearance'
		BEGIN
		INSERT INTO #TEMP_PLACENAME_PARENT(ID,GeoRefId,Description,Resolution,Exclude,Priority,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,appear.Resolution,appear.Exclude,appear.Priority, @Action
			FROM tblAppearance appear 
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=appear.GeoRefID 
			WHERE appear.AppearanceID in(@ParentKey);
 
			INSERT INTO #TEMP_PLACENAME_CHILD(ID,GeoRefId,Description,Resolution,Exclude,Priority,Action)
			SELECT @ID,geo.GeoRefId,geo.Description,appear.Resolution,appear.Exclude,appear.Priority, @Action  
			FROM tblAppearance appear
			INNER JOIN tblGeoRef geo ON geo.GeoRefId=appear.GeoRefID 
			WHERE appear.AppearanceID in(@ChildKey);
		END
	FETCH NEXT FROM cur_tbl INTO @ID, @TableName, @ParentKey, @ChildKey, @Action
	END 
	CLOSE cur_tbl
	DEALLOCATE cur_tbl
	--compare 2 tables and display the values
	--select * from  #TEMP_PLACENAME_PARENT
	--select * from  #TEMP_PLACENAME_CHILD
	DECLARE @TEMP_RESULT TABLE(ID INT, GeoRefID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX), Parent_value NVARCHAR(MAX), Child_value NVARCHAR(MAX), Action NVARCHAR(10))
	INSERT INTO @TEMP_RESULT
	 Select ID, GeoRefId, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end), Action
	 From ( Select Src=1, ID, GeoRefId, LanguageName, Action, B.*
			 From #TEMP_PLACENAME_PARENT A
			 Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
			 B
			Union All
			Select Src=2, ID, GeoRefId, LanguageName, Action, B.*
			 From #TEMP_PLACENAME_CHILD A
			 Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
			 B
		  ) A
	 Group By ID, GeoRefId, LanguageName, [key], Action
	 Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
	 Order By ID, [key]

	-- SELECT * FROM #TEMP_RESULT

	SELECT t.GeoRefID AS ContentID, 'PlaceName' AS ContentType, g.Description AS Name,
	CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS Field, 
	t.Parent_value AS PreviousValue, t.Child_value AS CurrentValue , Action
	FROM @TEMP_RESULT t, tblGeoRef g WHERE t.GeoRefID = g.ID
	UNION
	SELECT t.CurrentKey AS ContentID, 'PlaceName' AS ContentType, g.Description AS Name, NULL, NULL, NULL, t.Action
	FROM #TEMP t, tblGeoRef g WHERE t.CurrentKey = g.ID AND t.Action IN ('Insert', 'Delete') 
END
