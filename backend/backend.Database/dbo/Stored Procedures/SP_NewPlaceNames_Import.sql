SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 03/07/2022
-- Description:	Import new PlaceNames from The external DataSources
-- Sample EXEC [dbo].[SP_NewPlaceNames_Import] 1, 'userName' , '02c3cb7c-d072-4136-b19e-ded5aafa53e9'
-- =============================================

IF OBJECT_ID('[dbo].[SP_NewPlaceNames_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_NewPlaceNames_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_NewPlaceNames_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50),
	@isUSPlacename BIT
AS
BEGIN
	DECLARE @geoRefId INT,@userName NVARCHAR(50);
	DECLARE @resolutionlistTbl table (Zlevel INT, res FLOAT, resMap INT);
	DECLARE @ExistingPlaceNames table (GeoRefID INT);
	DECLARE @NewPlaceNames table (PlaceName NVARCHAR(250), Lat DECIMAL (12, 9),Long DECIMAL (12, 9),Population INT);
	DECLARE @FinalPlaceNames table (Id INT IDENTITY(1,1), PlaceName NVARCHAR(250), Lat DECIMAL (12, 9),Long DECIMAL (12, 9),Population INT);

	IF (@isUSPlacename = 1)
	BEGIN
		INSERT INTO @NewPlaceNames 
		SELECT rtrim(TPN.CityName) AS PlaceName,CAST(TPN.Lat AS DECIMAL(12, 9)) AS Lat,CAST(TPN.Long AS DECIMAL(12, 9)) AS Long,CAST(TC.Population AS INT) AS Population 
		FROM tblTempCityInfo TC 
		INNER JOIN  tblTempPlacNamesNationalFile TPN ON rtrim(TC.City) = rtrim(TPN.CityName)
		WHERE TC.Population > 50000 ;
	END
	ELSE
	BEGIN
		INSERT INTO @NewPlaceNames 
		SELECT rtrim(TPN.CityName) AS PlaceName,CAST(TPN.Lat AS DECIMAL(12, 9)) AS Lat,CAST(TPN.Long AS DECIMAL(12, 9)) AS Long,CAST(TC.Population AS INT) AS Population 
		FROM tblTempCityInfo TC 
		INNER JOIN  tblTempPlacNamesNationalFile TPN ON rtrim(TC.City) = rtrim(TPN.CityName)
		WHERE TC.Population > 150000 AND TPN.BGNFilter = 'N';
	END;

	--Delete Duplicate Placenames from @NewPlaceNames
	WITH tmp AS (
      SELECT PlaceName, ROW_NUMBER() OVER(PARTITION BY PlaceName ORDER BY PlaceName) AS ROWNUMBER
      FROM @NewPlaceNames
	  )
	DELETE tmp
		WHERE ROWNUMBER > 1;

   --Getting the existing Placenames from the Database
	INSERT INTO @ExistingPlaceNames
	SELECT GeoRefId FROM tblGeoRef Where GeoRefId IN
	(SELECT TS.GeoRefID FROM tblSpelling TS 
		INNER JOIN  
		  @NewPlaceNames NP ON TS.UnicodeStr = NP.PlaceName
	WHERE TS.LanguageID = 1)

	--Delete the existing place names from @NewPlaceNames to avoid the duplicate insertion
	DELETE NPN FROM @NewPlaceNames NPN
	INNER JOIN 
	(SELECT DISTINCT UnicodeStr
		FROM tblSpelling WHERE
		GeoRefID IN (SELECT GeoRefID FROM @ExistingPlaceNames) AND LanguageID = 1) TEMP
		ON TEMP.UnicodeStr = NPN.PlaceName

	--Import all the Data to @temptbNewAirportswWithID
	INSERT INTO @FinalPlaceNames SELECT * FROM @NewPlaceNames

	--Get GgeoRefId
	SET @geoRefId = (select max(dbo.tblGeoRef.GeoRefId) FROM  dbo.tblGeoRef);
	
	--resolutionlistTbl has all the resolulations and their mapings
	INSERT INTO @resolutionlistTbl values (1,0,60), (2,0,120), (3,0,240), (4,0.971922,30), (5,3,0), (6,6,0),(7,15,480),(8,30,960),
		(9,60,0),(10,75,1920),(11,150,3840),(12,300,7680),(13,600,15360),(14,1620,0),(15,2025,0)

	WHILE(SELECT COUNT(*) FROM @FinalPlaceNames) > 0
	BEGIN
		DECLARE @tempId INT, @tempGeoRefId INT, @tempCity VARCHAR(50),@tempLat FLOAT, @tempLong FLOAT, @tempCityDesc VARCHAR(250);

		SET @tempId = (SELECT TOP 1 Id from @FinalPlaceNames);
		SET @tempGeoRefId = @tempId + @geoRefId;
		SET @tempCity = (SELECT TOP 1 PlaceName FROM @FinalPlaceNames WHERE Id = @tempId);
		SET @tempLat = (SELECT TOP 1 Lat FROM @FinalPlaceNames WHERE Id = @tempId);
		SET @tempLong = (SELECT TOP 1 Long FROM @FinalPlaceNames WHERE Id = @tempId);

		-- Update tblGeoRef Table
		BEGIN

			DECLARE @newGeorRefTblID INT;

			--Update tblGeoRef
			INSERT INTO dbo.tblGeoRef(GeoRefId, Description, CatTypeId, AsxiCatTypeId, PnType, 
					isAirport, isAirportPoi,isAttraction, isCapitalCountry, isCapitalState, isClosestPoi, 
					isInteractivePoi, isInteractiveSearch, isMakkahPoi, isRliPoi,isShipWreck, isSnapshot,
					isSummit, isTerrainLand, isTerrainOcean, isTimeZonePoi, isWaterBody, isWorldClockPoi, 
					isWGuide,Priority, AsxiPriority, RliAppearance, KeepNew, Display)
			VALUES (@tempGeoRefId,@tempCity,2, 10, 1, 
					0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0,0, 0);
	
			--Get New ID 
			SET @newGeorRefTblID =(SELECT MAX(ID) FROM dbo.tblGeoRef WHERE GeoRefID = @tempGeoRefId);
			
			--Update tblGeoRefMap
			INSERT INTO dbo.tblGeoRefMap(ConfigurationID,GeoRefId,PreviousGeoRefID,IsDeleted)
			VALUES ( @configid,@newGeorRefTblID,0, 0)
		END

		-- Update tbCoverageSegment Table		
		BEGIN
			DECLARE @newCoverageSegmentID INT;

			--Update tbCoverageSegment
			INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
			VALUES(@tempGeoRefId,1,@tempLat,@tempLong,0, 0, 7);
	
			--Get New ID 
			SET @newCoverageSegmentID =(SELECT MAX(ID) FROM dbo.tblCoverageSegment WHERE GeoRefID = @tempGeoRefId);
			
			-- Update tbCoverageSegmentMap
			INSERT INTO dbo.tblCoverageSegmentMap(ConfigurationID,CoverageSegmentID,PreviousCoverageSegmentID,IsDeleted)
			VALUES ( @configid,@newCoverageSegmentID,0, 0)
		END		

		-- Update tbSpelling Table only for English) and Mark DoSpellCheck = 1 as it is a new entry and ready for Language Translation
		BEGIN
			DECLARE @newSpellingTblID INT;				
	
			--Update tbSpelling
			INSERT INTO dbo.tblSpelling ( GeoRefId, LanguageId, UnicodeStr, FontId, SphereMapFontId, dataSourceId,DoSpellCheck )
			VALUES(@tempGeoRefId,1,@tempCity,1002,1015,7,1);
	
			--Get New ID 
			SET @newSpellingTblID =(SELECT MAX(SpellingID) FROM tblSpelling WHERE GeoRefID = @tempGeoRefId);
			
			--Update tblSpellingMap
			INSERT INTO dbo.tblSpellingMap(ConfigurationID,SpellingID,PreviousSpellingID,IsDeleted)
			VALUES ( @configid,@newSpellingTblID,0, 0)
		END
		-- Update tblAppearance Table only for English)
		--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions		
		BEGIN
			DECLARE @newAppearanceTbleID INT,@NumRes INT, @Init INT;	
			SELECT @NumRes= COUNT(*) FROM @resolutionlistTbl
			SET @Init =1
			WHILE @Init<= @NumRes
			BEGIN
			
				--Update tblAppearance
				INSERT INTO dbo.tblAppearance(GeoRefId,Resolution, ResolutionMpp, Exclude, SphereMapExclude )
				VALUES(@tempGeoRefId,(SELECT TOP 1 res FROM @resolutionlistTbl where Zlevel =@Init),(SELECT TOP 1 resMap FROM @resolutionlistTbl where Zlevel =@Init),0,0);

				--Get New ID 
				SET @newAppearanceTbleID =(SELECT MAX(AppearanceID) FROM dbo.tblAppearance WHERE GeoRefID = @tempGeoRefId);
				
				--tblAppearanceMap
				INSERT INTO dbo.tblAppearanceMap(ConfigurationID,AppearanceID,PreviousAppearanceID,IsDeleted)
				VALUES ( @configid,@newAppearanceTbleID,0, 0)
				SET @Init= @Init + 1
			END
		END
	DELETE FROM @FinalPlaceNames WHERE Id = @tempId;
	END
	--Delete the temp table once import is done
	DELETE dbo.tblTempCityInfo;
	DELETE dbo.tblTempPlacNamesNationalFile;
	DELETE @ExistingPlaceNames
	DELETE @NewPlaceNames
	--Update tblConfigurationHistory with the content
	DECLARE @comment NVARCHAR(MAX)
	SET @comment = ('Imported new palcenames data for ' + (SELECT CT.Name FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
				WHERE C.ConfigurationID = @configid) + ' configuration version V' + CONVERT(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				WHERE C.ConfigurationID = @configid)))

	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id IN (SELECT StartedByUserID FROM tblTasks WHERE Id = @currentTaskID) );

	IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'placenames' AND ConfigurationID = @configid)
	BEGIN
		UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@currentTaskID), CommentAddedBy = @userName
		WHERE ContentType = 'placenames' AND ConfigurationID = @configid
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
		VALUES(@configid,'placenames',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID),@comment)
	END
END
