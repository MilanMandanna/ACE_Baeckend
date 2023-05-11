
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_GeoRef]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_GeoRef]
END
GO

-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/29/2022
-- Description:	It imports AsxiInfotbgeorefid data to tblGeoRef from asxinfo.sqlite3 
--               This import effect few more other tables such as tblCoverageSegment, tblSpelling and tblResolution as it all has 
--				 GeoRefID dependency.
-- Sample EXEC [dbo].[SP_AsxiInfoImport_GeoRef] 1,
-- =============================================

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_GeoRef]
		@configid INT
AS
BEGIN

	DECLARE @AsxiGeoRefID INT, @AsxiGeoRefCityName NVARCHAR(MAX), @AsxiGeoRefRegionId INT, @AsxiGeoRefCountryId INT,
	 @AsxiGeoRefCatTypeId INT, @AsxiGeoRefisRliPoi BIT, @AsxiGeoRefisInteractivePoi BIT, @AsxiGeoRefisWorldClockPoi BIT,@AsxiGeoRefClosestPOI BIT,
	 @AsxiGeoRefLat FLOAT, @AsxiGeoRefLon FLOAT, @customChangeBitMask INT, @existingvalue INT, @updatedvalue INT;
	DECLARE @dml AS NVARCHAR(MAX);
	DECLARE @ColumnName AS NVARCHAR(MAX);
	 
	DECLARE @tempNewSpelling TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, GeoRefID INT NULL,LangTwoLetter NVARCHAR(2) NULL,LangID INT NULL, UniCodeStr NVARCHAR(MAX));  
	DECLARE @tempSpelling TABLE (TempID INT IDENTITY (1,1) NOT NULL,LangID INT NULL, UniCodeStr NVARCHAR(MAX)); 
	
	SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(name) from sys.columns c
		where c.object_id = OBJECT_ID('dbo.AsxiInfotbgeorefid') and name LIKE '%Lang%'
	
	--Prepare the PIVOT query using the dynamic   
	SET @dml =   
			N'(SELECT GeoRefID,(SELECT RIGHT( LangTwoLetter, 2 )), UniCodeStr  
				FROM   
				(SELECT GeoRefId, ' +@ColumnName +' 
		
			FROM AsxiInfotbgeorefid) p  
				UNPIVOT  
				(UniCodeStr FOR LangTwoLetter IN   
					(' + @ColumnName + ')  
					)AS unpvtAsxiInfotbgeorefid) '
		--Print @DynamicPivotQuery
	INSERT INTO @tempNewSpelling(GeoRefID,LangTwoLetter,UniCodeStr) EXEC sp_executesql @dml  
		--Execute the Dynamic Pivot Query
	
	
		--Updating two letter codes
		UPDATE T1   
		SET T1.LangID = T2.LanguageID  
			FROM @tempNewSpelling AS T1 INNER JOIN AsxiInfotblanguage T2  
		ON T1.LangTwoLetter = t2.TwoLetterID  

	--resolutionlistTbl has all the resolulations and their mapings
	DECLARE @resolutionlistTbl table (Zlevel INT, res FLOAT, resMap INT);
	INSERT INTO @resolutionlistTbl values (1,0,60), (2,0,120), (3,0,240), (4,0.971922,30), (5,3,0), (6,6,0),(7,15,480),(8,30,960),
		(9,60,0),(10,75,1920),(11,150,3840),(12,300,7680),(13,600,15360),(14,1620,0),(15,2025,0)	

	--For new records
	SELECT TempAsxi.* INTO  #tempNewGeoRefId FROM AsxiInfotbgeorefid AS TempAsxi WHERE TempAsxi.GeoRefId NOT IN 
			(SELECT GeoRef.GeoRefId FROM dbo.config_tblGeoRef(@configid) AS GeoRef);
	
	--For Modified records
	SELECT TempAsxi.* INTO  #tempUpdatedGeoRefId FROM AsxiInfotbgeorefid AS TempAsxi WHERE TempAsxi.GeoRefId IN 
			(SELECT GeoRef.GeoRefId FROM dbo.config_tblGeoRef(@configid) AS GeoRef
				WHERE TempAsxi.RegionId != GeoRef.RegionId OR
							TempAsxi.CountryId != GeoRef.CountryId OR
							TempAsxi.GeoRefIdCatTypeId != GeoRef.AsxiCatTypeId OR
							TempAsxi.RLIPOI != GeoRef.isRliPoi OR
							TempAsxi.IPOI != GeoRef.isInteractivePoi OR
							TempAsxi.WCPOI != GeoRef.isWorldClockPoi OR
							TempAsxi.MakkahPOI != GeoRef.isMakkahPoi OR
							TempAsxi.ClosestPOI != GeoRef.isClosestPoi);
	
	
	
	--Iterating to the new temp tables and adding it to the tblGeoRefId and tblGeoRefIdMap
	WHILE(SELECT COUNT(*) FROM #tempNewGeoRefId) > 0
	BEGIN
		
		SET @AsxiGeoRefID = (SELECT TOP 1 GeoRefID FROM #tempNewGeoRefId)	
		SET @AsxiGeoRefCityName = (SELECT TOP 1 Lang_EN FROM #tempNewGeoRefId)
		SET @AsxiGeoRefCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM #tempNewGeoRefId)
		SET @AsxiGeoRefRegionId = (SELECT TOP 1 RegionId FROM #tempNewGeoRefId)
		SET @AsxiGeoRefCountryId = (SELECT TOP 1 CountryId FROM #tempNewGeoRefId)
		SET @AsxiGeoRefisRliPoi = (SELECT TOP 1 RLIPOI FROM #tempNewGeoRefId)
		SET @AsxiGeoRefisInteractivePoi= (SELECT TOP 1 IPOI FROM #tempNewGeoRefId)
		SET @AsxiGeoRefisWorldClockPoi= (SELECT TOP 1 WCPOI FROM #tempNewGeoRefId)
		SET @AsxiGeoRefClosestPOI = (SELECT TOP 1 ClosestPOI FROM #tempNewGeoRefId)
		SET @AsxiGeoRefLat = (SELECT TOP 1 Lat FROM #tempNewGeoRefId)
		SET @AsxiGeoRefLon = (SELECT TOP 1 Lon FROM #tempNewGeoRefId)
		INSERT INTO @tempSpelling(LangID,UniCodeStr) SELECT TNS.LangID,TNS.UniCodeStr FROM @tempNewSpelling AS TNS WHERE TNS.GeoRefID = @AsxiGeoRefID


		--Insert tblGeoRef Table and and its Maping Table
		DECLARE @tGeoReftblID INT;
		INSERT INTO tblGeoRef (GeoRefId, Description, AsxiCatTypeId, RegionId, CountryId, isRliPoi, isInteractivePoi, isWorldClockPoi, isMakkahPoi, isClosestPoi, CustomChangeBitMask)
		VALUES (@AsxiGeoRefID,@AsxiGeoRefCityName,@AsxiGeoRefCatTypeId,@AsxiGeoRefRegionId,@AsxiGeoRefCountryId,@AsxiGeoRefisRliPoi,
		@AsxiGeoRefisInteractivePoi,@AsxiGeoRefisInteractivePoi,@AsxiGeoRefisWorldClockPoi,@AsxiGeoRefClosestPOI, 8)
		SET @tGeoReftblID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblGeoRef', @tGeoReftblID

		--Insert tblCoverageSegment Table and and its Maping Table
		DECLARE @CoverageSegmenttblId INT;
		INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
		VALUES(@AsxiGeoRefID,1,@AsxiGeoRefLat,@AsxiGeoRefLon,0, 0, 7);
		SET @CoverageSegmenttblId = SCOPE_IDENTITY()
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblCoverageSegment', @CoverageSegmenttblId

		WHILE(SELECT COUNT(*) FROM @tempSpelling) > 0
		BEGIN
			---Insert tblSpelling Table and and its Maping Table
			DECLARE @spellingLangID INT, @spellingInit INT,@spellingUniCodestr NVARCHAR(MAX),@SpellingtblId INT;	
			SET @spellingInit =(SELECT TOP 1 TempID FROM @tempSpelling)
			SET @spellingLangID =(SELECT TOP 1 LangID FROM @tempSpelling)
			SET @spellingUniCodestr =(SELECT TOP 1 UniCodeStr FROM @tempSpelling)
			
			INSERT INTO dbo.tblSpelling ( GeoRefId, LanguageId, UnicodeStr, FontId, SphereMapFontId, dataSourceId )
			VALUES(@AsxiGeoRefID,@spellingLangID,@spellingUniCodestr,1002,1015,7);
			SET @SpellingtblId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblSpelling', @SpellingtblId
			DELETE FROM @tempSpelling WHERE TempID = @spellingInit
		END
		-- Update tblAppearance Table only for English)
		--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions
		DECLARE @NumRes INT, @Init INT;	
		SELECT @NumRes= COUNT(*) FROM @resolutionlistTbl
		SET @Init =1
		WHILE @Init<= @NumRes
		BEGIN
			DECLARE @AppearancetblId INT;
			INSERT INTO dbo.tblAppearance(GeoRefId,Resolution, ResolutionMpp, Exclude, SphereMapExclude )
			VALUES(@AsxiGeoRefID,(SELECT TOP 1 res FROM @resolutionlistTbl where Zlevel =@Init),(SELECT TOP 1 resMap FROM @resolutionlistTbl where Zlevel =@Init),0,0);
			SET @AppearancetblId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAppearance', @AppearancetblId
			SET @Init= @Init + 1
		END
		DELETE @tempSpelling
		DELETE FROM #tempNewGeoRefId WHERE GeoRefId = @AsxiGeoRefID
	END


	WHILE(SELECT COUNT(*) FROM #tempUpdatedGeoRefId) > 0
	BEGIN	

		DECLARE @existingGeoRefId INT, @existingSegmentId INT, @existingSpellingId INT, @existingAppearanceId INT

		SET @AsxiGeoRefID = (SELECT TOP 1 GeoRefID FROM #tempUpdatedGeoRefId)	
		SET @AsxiGeoRefCityName = (SELECT TOP 1 Lang_EN FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefRegionId = (SELECT TOP 1 RegionId FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefCountryId = (SELECT TOP 1 CountryId FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefisRliPoi = (SELECT TOP 1 RLIPOI FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefisInteractivePoi= (SELECT TOP 1 IPOI FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefisWorldClockPoi= (SELECT TOP 1 WCPOI FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefClosestPOI = (SELECT TOP 1 ClosestPOI FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefLat = (SELECT TOP 1 Lat FROM #tempUpdatedGeoRefId)
		SET @AsxiGeoRefLon = (SELECT TOP 1 Lon FROM #tempUpdatedGeoRefId)
		INSERT INTO @tempSpelling(LangID,UniCodeStr) SELECT TNS.LangID,TNS.UniCodeStr FROM @tempNewSpelling AS TNS WHERE TNS.GeoRefID = @AsxiGeoRefID


		--Update the tblGeoRefId and its Maping Table
		SET @existingGeoRefId = (SELECT GeoRef.ID FROM dbo.config_tblGeoRef(@configid) AS GeoRef 
			WHERE GeoRef.ID = @AsxiGeoRefID)

		DECLARE @updateKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblGeoRef', @existingGeoRefId, @updateKey out

 	 	SET @customChangeBitMask = 2
 	 	SET @existingvalue = (SELECT CustomChangeBitMask FROM tblGeoRef WHERE ID = @updateKey)
 	 	SET @updatedvalue =(@existingvalue | @customChangeBitMask)
		SET NOCOUNT OFF
		UPDATE tblGeoRef
		SET Description = @AsxiGeoRefCityName, CatTypeId = @AsxiGeoRefCatTypeId, RegionId = @AsxiGeoRefRegionId,
		CountryId = @AsxiGeoRefCountryId, isRliPoi = @AsxiGeoRefisRliPoi, isInteractivePoi = @AsxiGeoRefisInteractivePoi,
		isWorldClockPoi = @AsxiGeoRefisWorldClockPoi, isClosestPoi = @AsxiGeoRefClosestPOI, CustomChangeBitMask = @updatedvalue
		WHERE ID = @updateKey


		--Update the tblCoverageSegment Table and and its Maping Table
		SET @existingSegmentId = (SELECT coveragesegment.ID FROM dbo.config_tblCoverageSegment(@configid) AS coveragesegment 
		WHERE coveragesegment.GeoRefID = @AsxiGeoRefID)

		DECLARE @updateSegmentKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblCoverageSegment', @existingSegmentId, @updateSegmentKey out
		SET NOCOUNT OFF
		UPDATE tblCoverageSegment
		SET  Lat1 = @AsxiGeoRefLat, Lon1 = @AsxiGeoRefLon
		WHERE ID = @updateSegmentKey

		WHILE(SELECT COUNT(*) FROM @tempSpelling) > 0
		BEGIN
		
			---Insert tblSpelling Table and and its Maping Table
			DECLARE @updateSpellingKey INT;
			SET @spellingInit =(SELECT TOP 1 TempID FROM @tempSpelling)
			SET @spellingLangID =(SELECT TOP 1 LangID FROM @tempSpelling)
			SET @spellingUniCodestr =(SELECT TOP 1 UniCodeStr FROM @tempSpelling)
			
			--Update the tblSpelling Table and and its Maping Table
			SET @existingSpellingId = (SELECT spelling.SpellingID FROM dbo.config_tblSpelling(@configid) AS spelling 
			WHERE spelling.GeoRefID = @AsxiGeoRefID AND spelling.LanguageID = 1)
			exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblSpelling', @existingSpellingId, @updateSpellingKey out
			SET NOCOUNT OFF
			UPDATE tblSpelling
			SET  UnicodeStr = @spellingUniCodestr, LanguageID = @spellingLangID
			WHERE SpellingID = @updateSpellingKey
			DELETE FROM @tempSpelling WHERE TempID = @spellingInit
		END
		-- Update tblAppearance Table only for English)
		--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions	
		DELETE @tempSpelling
		DELETE FROM #tempUpdatedGeoRefId WHERE GeoRefID = @AsxiGeoRefID
	END

	DROP TABLE #tempNewGeoRefId
	DROP TABLE #tempUpdatedGeoRefId
END
