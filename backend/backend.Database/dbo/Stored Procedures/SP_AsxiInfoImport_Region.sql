SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Regions from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_Region] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_Region]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_Region]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_Region]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @tempNewSpellingCounter INT,@tempUpdateSpellingCounter INT, @existingSpellingID INT, @newSpellingID INT, @CurrentRegionID INT, @CurrentLanguageID INT,@CurrentRegionName NVARCHAR (255);
	CREATE TABLE #tempNewRegionWithIDs (SpellingID INT IDENTITY (1,1) NOT NULL, RegionID INT NULL,RegionName NVARCHAR (255) NULL, LanguageID INT NULL);

	--Sqlite Database table tbRegion not have Language ID with it, So Joining AsxiInfotblanguage and tbRegion to Grab Language ID
	SELECT tempLang.*,CONCAT('Lang_',TwoLetterID) as RegionCode INTO #tempNewLang FROM AsxiInfotblanguage as tempLang
	DECLARE @dml AS NVARCHAR(MAX);
	DECLARE @ColumnName AS NVARCHAR(MAX); 

	SELECT @ColumnName= ISNULL(@ColumnName + ',','')   
       + QUOTENAME(name) from sys.columns c  
		WHERE c.object_id = OBJECT_ID('dbo.AsxiInfotbregion') and name LIKE '%Lang%'  

 --Prepare the PIVOT query using the dynamic   
	SET @dml =
	'(SELECT RT.RegionId,RT.RegionName,TNL.LanguageID FROM #tempNewLang TNL
	INNER JOIN 
	(SELECT RegionId,RegionCode,RegionName FROM AsxiInfotbregion
		UNPIVOT(RegionName FOR RegionCode IN (' + @ColumnName + ')) AS T)  RT
		ON TNL.RegionCode = RT.RegionCode)'

	INSERT INTO #tempNewRegionWithIDs  EXEC sp_executesql @dml

	--select * from #tempNewRegionWithIDs
	--For new records
	SELECT TempAsxi.* INTO  #tempNewRegion FROM #tempNewRegionWithIDs as TempAsxi WHERE CAST(TempAsxi.RegionID as nvarchar)+CAST(TempAsxi.LanguageID as nvarchar) NOT IN
			(SELECT CAST(T.RegionID as nvarchar)+CAST(T.LanguageID as nvarchar) FROM tblRegionSpelling T INNER JOIN tblRegionSpellingMap TMap ON T.SpellingID = TMap.SpellingID
				WHERE TMap.ConfigurationID = @configid);
	
	--For Modified records
	SELECT TempAsxi.* INTO  #tempUpdateRegion FROM #tempNewRegionWithIDs as TempAsxi WHERE CAST(TempAsxi.RegionID as nvarchar)+CAST(TempAsxi.LanguageID as nvarchar) IN
			(SELECT CAST(T.RegionID as nvarchar)+CAST(T.LanguageID as nvarchar) FROM tblRegionSpelling T INNER JOIN tblRegionSpellingMap TMap ON T.SpellingID = TMap.SpellingID
			WHERE (TempAsxi.RegionName != T.RegionName ) AND TMap.ConfigurationID = @configid);

	--Iterating to the new temp tables and adding it to the tblRegionSpelling and tblRegionSpellingMap
	WHILE(SELECT COUNT(*) FROM #tempNewRegion) > 0
	BEGIN

		SET @tempNewSpellingCounter = (SELECT TOP 1 SpellingID FROM #tempNewRegion)

		SET @CurrentRegionID = (SELECT TOP 1 RegionID FROM #tempNewRegion)
		SET @CurrentLanguageID = (SELECT TOP 1 LanguageID FROM #tempNewRegion)
		SET @CurrentRegionName = (SELECT TOP 1 RegionName FROM #tempNewRegion)
		
		--Insert tblRegion Table and and its Maping Table
		DECLARE @newtbSpellingID INT;
		INSERT INTO tblRegionSpelling(RegionID,RegionName,LanguageId)
		VALUES (@CurrentRegionID,@CurrentRegionName,@CurrentLanguageID) 
		SET @newtbSpellingID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblRegionSpelling', @newtbSpellingID

		DELETE FROM #tempNewRegion WHERE SpellingID = @tempNewSpellingCounter
	END

	--Iterating to the new temp tables and adding it to the tblRegionSpelling and tblRegionSpellingMap
	WHILE(SELECT COUNT(*) FROM #tempUpdateRegion) > 0
	BEGIN
		
		SET @tempUpdateSpellingCounter = (SELECT TOP 1 SpellingID FROM #tempUpdateRegion)
		SET @CurrentRegionName = (SELECT TOP 1 RegionName FROM #tempUpdateRegion)
		SET @CurrentRegionID = (SELECT TOP 1 RegionID FROM #tempUpdateRegion)
		SET @CurrentLanguageID= (SELECT TOP 1 LanguageID FROM #tempUpdateRegion)
		SET @existingSpellingID= (SELECT TRS.SpellingID FROM tblRegionSpelling TRS INNER JOIN tblRegionSpellingMap TRSM
		ON TRS.SpellingID = TRSM.SpellingID AND TRSM.ConfigurationID = @configid
		WHERE TRS.RegionID = @CurrentRegionID AND TRS.LanguageId = @CurrentLanguageID)

		DECLARE @updateSpellKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblRegionSpelling', @existingSpellingID, @updateSpellKey out
		SET NOCOUNT OFF
		UPDATE tblRegionSpelling
		SET RegionName = @CurrentRegionName
		WHERE SpellingID = @updateSpellKey

		DELETE FROM #tempUpdateRegion WHERE SpellingID = @tempUpdateSpellingCounter
	END

	DROP TABLE #tempNewRegion
	DROP TABLE #tempUpdateRegion
	DROP TABLE #tempNewRegionWithIDs
	DROP TABLE #tempNewLang
END


