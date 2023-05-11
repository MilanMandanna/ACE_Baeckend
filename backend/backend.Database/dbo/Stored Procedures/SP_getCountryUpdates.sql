/****** Object:  StoredProcedure [dbo].[SP_GetCountryUpdates]    Script Date: 10/31/2022 6:35:06 PM ******/
IF OBJECT_ID('[dbo].[SP_GetCountryUpdates]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE IF EXISTS [dbo].[SP_GetCountryUpdates]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetCountryUpdates]    Script Date: 10/31/2022 6:35:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_GetCountryUpdates]
	@tableXml XML
AS
BEGIN

	DROP TABLE IF EXISTS #TEMP_COUNTRY_PARENT
	DROP TABLE IF EXISTS #TEMP_COUNTRY_CHILD
	DROP TABLE IF EXISTS #TEMP

	CREATE TABLE #TEMP_COUNTRY_PARENT(ID INT, CountryId INT,CountrySpellingId INT,Translation NVARCHAR(MAX),Description NVARCHAR(MAX),regionId int,Region nvarchar(max),LanguageId int,LanguageName varchar(100),Action NVARCHAR(10));
	CREATE TABLE #TEMP_COUNTRY_CHILD(ID INT, CountryId INT,CountrySpellingId INT,Translation NVARCHAR(MAX),Description NVARCHAR(MAX),regionId int,Region nvarchar(max),LanguageId int,LanguageName varchar(100),Action NVARCHAR(10));
	
	CREATE TABLE #TEMP (ID INT IDENTITY, TableName NVARCHAR(100), CurrentKey INT, PreviousKey INT, Action NVARCHAR(10))
	INSERT INTO #TEMP 
	SELECT Tbl.Col.value('@TableName', 'NVARCHAR(100)') AS TableName,  Tbl.Col.value('@CurrentKey', 'INT') AS CurrentKey,  
       Tbl.Col.value('@PreviousKey', 'INT') AS PreviousKey, Tbl.Col.value('@Action', 'NVARCHAR(10)') AS Action 
	FROM   @tableXml.nodes('//row') Tbl(Col) WHERE Tbl.Col.value('@TableName', 'NVARCHAR(100)') IN ('tblCountry','tblCountrySpelling')
	
	DECLARE @ID INT, @TableName VARCHAR(50),@ParentKey INT,@ChildKey INT, @Action NVARCHAR(10)
 
	DECLARE cur_tbl CURSOR 
	FOR
	SELECT ID,TableName,PreviousKey,CurrentKey,Action
	FROM   #TEMP WHERE Action = 'Update'
 
	OPEN cur_tbl 
	FETCH next FROM cur_tbl INTO @ID, @TableName ,@ParentKey ,@ChildKey, @Action 
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF @TableName='tblCountry'
		BEGIN
			INSERT INTO #TEMP_COUNTRY_PARENT(ID,CountryId,Description,Region,Action) 
			SELECT @ID,CountryID,Description,RegionName,@Action FROM tblCountry ctry 
			INNER JOIN tblRegionSpelling spel on ctry.RegionID=spel.RegionID and spel.LanguageId=1
			WHERE ID in(@ParentKey);
 
			INSERT INTO #TEMP_COUNTRY_CHILD(ID,CountryId,Description,Region,Action) 
			SELECT @ID,CountryID,Description,RegionName, @Action FROM tblCountry ctry 
			INNER JOIN tblRegionSpelling spel on ctry.RegionID=spel.RegionID and spel.LanguageId=1
			WHERE ID in(@ChildKey);
		END
		IF @TableName='tblCountrySpelling'
		BEGIN
			INSERT INTO #TEMP_COUNTRY_PARENT(ID,CountryId,Description,Translation,LanguageName,Action)
			SELECT @ID,ctry.CountryID,ctry.Description,CountryName, lang.Name, @Action FROM tblCountrySpelling spel 
			INNER JOIN tblCountry ctry ON ctry.CountryID=spel.CountryID
			INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID WHERE CountrySpellingID in(@ParentKey);
 
			INSERT INTO #TEMP_COUNTRY_CHILD(ID,CountryId,Description,Translation,LanguageName,Action)
			SELECT @ID,ctry.CountryID,ctry.Description,CountryName, lang.Name, @Action FROM tblCountrySpelling spel 
			INNER JOIN tblCountry ctry ON ctry.CountryID=spel.CountryID
			INNER JOIN tblLanguages lang on lang.LanguageID=spel.LanguageID WHERE CountrySpellingID in(@ChildKey);
		END
		FETCH NEXT FROM cur_tbl INTO @ID,@TableName, @ParentKey, @ChildKey, @Action
	END 
	CLOSE cur_tbl
	DEALLOCATE cur_tbl

	--compare 2 tables and display the values
	--select * from  #TEMP_COUNTRY_PARENT
	--select * from  #TEMP_COUNTRY_CHILD
	DECLARE @TEMP_RESULT TABLE(ID INT, CountryID INT, LanguageName NVARCHAR(MAX), [Key] NVARCHAR(MAX) NULL, Parent_value NVARCHAR(MAX) NULL, Child_value NVARCHAR(MAX) NULL, Action NVARCHAR(10))
	INSERT INTO @TEMP_RESULT
	 Select ID, CountryId, LanguageName, [key], Parent_Value = max( case when Src=1 then Value end), Child_Value = max( case when Src=2 then Value end), Action
	 From ( Select Src=1, ID, CountryId, LanguageName, Action, B.*
			 From #TEMP_COUNTRY_PARENT A
			 Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
			 B
			Union All
			Select Src=2, ID, CountryId, LanguageName, Action, B.*
			 From #TEMP_COUNTRY_CHILD A
			 Cross Apply (Select [Key], Value From OpenJson((Select A.* For JSON Path,Without_Array_Wrapper,INCLUDE_NULL_VALUES))) 
			 B
		  ) A
	 Group By ID, CountryId, LanguageName, [key], Action
	 Having max(case when Src=1 then Value end) <> max(case when Src=2 then Value end)
	 Order By ID, [key]

	-- SELECT * FROM #TEMP_RESULT

	SELECT t.CountryID AS ContentID, 'Country' AS ContentType, c.Description AS Name, 
	CASE WHEN t.[Key] = 'Translation' THEN t.[key] + '(' + t.LanguageName + ')' ELSE t.[key] END AS Field, 
	t.Parent_value AS PreviousValue, t.Child_value AS CurrentValue, Action 
	FROM @TEMP_RESULT t, tblCountry c WHERE t.CountryID = c.ID
	UNION
	SELECT t.CurrentKey AS ContentID, 'Country' AS ContentType, c.Description AS Name, NULL, NULL, NULL, t.Action
	FROM #TEMP t, tblCountry c WHERE t.CurrentKey = c.ID AND t.Action IN ('Insert', 'Delete') 
END
