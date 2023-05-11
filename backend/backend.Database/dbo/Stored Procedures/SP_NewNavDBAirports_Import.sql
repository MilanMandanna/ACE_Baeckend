SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 03/07/2022
-- Description:	Import new Airports FROM navDB, Airport.csv Data Source files, If there is no new Airport now row will get modified
--				Date 03/31/2022 Laksmikanth Updated the SP to update ConfigurationHistoryTable
--				Date 04/20/2022 Laksmikanth Updated the SP to handle four letter ID with Same GeoRefID
--				Date 07/08/2022 Laksmikanth Updated the SP to handle Update the Airports Data
-- Sample EXEC [dbo].[SP_NewNavDBAirports_Import] 1, '8435FAA9-7174-4F4D-A1E7-A4C52A020142' , '83A32F91-81A0-49F2-B7E7-47EA335C94DC'
-- =============================================

IF OBJECT_ID('[dbo].[SP_NewNavDBAirports_Import]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_NewNavDBAirports_Import]
END
GO

CREATE PROCEDURE [dbo].[SP_NewNavDBAirports_Import]
	@configid INT,
	@LastModifiedBy NVARCHAR(250),
	@currentTaskID NVARCHAR(50)
AS
BEGIN
	DECLARE @geoRefId INT,@userName NVARCHAR(50);
	DECLARE @tempId INT, @tempGeoRefId INT, @tempCity VARCHAR(50),@tempLat DECIMAL (12, 9), @tempLong DECIMAL (12, 9), @tempCityDesc VARCHAR(250),
		@tempThreeLetID VARCHAR(10),@tempFourLetID VARCHAR(10),@GeoRefRank INT,@tbNewAirportsCounter INT,@UpdateAirportsCounter INT,
		 @existingGeoRefId INT, @existingSegmentId INT, @existingSpellingId INT, @existingAppearanceId INT, @existingAirportInfoId INT;


	--Temp Tables
	DECLARE @resolutionlistTbl table (Zlevel INT IDENTITY (1,1), res FLOAT, resMap INT);
	DECLARE @temptbNewAirportsWithID TABLE (AirportID INT IDENTITY (1,1) NOT NULL ,FourLetId NVARCHAR(10) NULL,ThreeLetId NVARCHAR(10) NULL,Lat DECIMAL(12,9) NULL,Long DECIMAL(12,9) NULL,Description NVARCHAR(250) NULL,City NVARCHAR(50),SN INT NULL,existingGeorefId INT NULL);
	CREATE TABLE #tbNewAirports (ID INT IDENTITY (1,1),FourLetId NVARCHAR(10) NULL,ThreeLetId NVARCHAR(10) NULL,Lat DECIMAL(12,9) NULL,Long DECIMAL(12,9) NULL,Description NVARCHAR(250) NULL,City NVARCHAR(50),SN INT NULL,existingGeorefId INT NULL);
	CREATE TABLE #tbUpdateAirports (ID INT IDENTITY (1,1),FourLetId NVARCHAR(10) NULL,ThreeLetId NVARCHAR(10) NULL,Lat DECIMAL(12,9) NULL,Long DECIMAL(12,9) NULL,Description NVARCHAR(250) NULL,City NVARCHAR(50),SN INT NULL,existingGeorefId INT NULL);
	
	--resolutionlistTbl has all the resolulations and their mapings
	INSERT INTO @resolutionlistTbl values (0,60), (0,120), (0,240), (0.971922,30), (3,0), (6,0),(15,480),(30,960),
		(60,0),(75,1920),(150,3840),(300,7680),(600,15360),(1620,0),(2025,0)

	BEGIN

		DELETE FROM dbo.tblNavDBAirports
				 WHERE SN NOT IN
						(
						SELECT MAX(SN)
							FROM dbo.tblNavDBAirports GROUP BY FourLetId,City
							);
		INSERT INTO @temptbNewAirportsWithID SELECT * FROM dbo.tblNavdbAirports


		--' Import source data to a temporary table For new records. 
		INSERT INTO #tbNewAirports(FourLetId,ThreeLetId,Lat,Long,City,Description)
		SELECT TN.FourLetId, TN.ThreeLetId,TN.Lat,TN.Long,TN.City,TN.Description
		FROM @temptbNewAirportsWithID TN WHERE TN.FourLetId NOT IN (SELECT AirpotInfo.FourLetId FROM dbo.config_tblAirportInfo(@configid) AS AirpotInfo);


		--' Import source data to a temporary table For Modified records. 
		INSERT INTO #tbUpdateAirports(FourLetId,ThreeLetId,Lat,Long,City,Description)
		SELECT  TN.FourLetId, TN.ThreeLetId,TN.Lat,TN.Long,TN.City,TN.Description
		FROM @temptbNewAirportsWithID TN WHERE TN.FourLetId  IN (SELECT AirpotInfo.FourLetId FROM dbo.config_tblAirportInfo(@configid) AS AirpotInfo
			WHERE ROUND(TN.Lat,4) != ROUND(AirpotInfo.Lat,4) OR
					ROUND(TN.Long,4) != ROUND(AirpotInfo.Lon,4));


	--Iterating to the new temp entires and updaing the records
	WHILE(SELECT COUNT(*) FROM #tbNewAirports) > 0
	BEGIN	

		SET @tempGeoRefId = (select max(dbo.tblGeoRef.GeoRefId) FROM  dbo.tblGeoRef)
		SET @tbNewAirportsCounter = (SELECT TOP 1 ID FROM #tbNewAirports)
		SET @tempCity= (SELECT TOP 1 City FROM #tbNewAirports)
		SET @tempFourLetID = (SELECT TOP 1 FourLetID FROM #tbNewAirports)
		SET @existingGeoRefId = (SELECT TOP 1 airinfo.GeoRefID FROM dbo.tblAirportInfo airinfo WHERE airinfo.CityName = @tempCity);
		SET @tempLat =(SELECT TOP 1 Lat FROM #tbNewAirports)
		SET @tempLong= (SELECT TOP 1 Long FROM #tbNewAirports)
		SET @tempCity= (SELECT TOP 1 City FROM #tbNewAirports)
		SET @tempCityDesc= (SELECT TOP 1 Description FROM #tbNewAirports)



		--If New Airport(FourLetID) for a new city(There is no GeoRef in the Database), then create new georefId and update all the 
		-- the  tables tblGeoRef , tblSpelling ,tblAirportInfo, tblCoverageSegment tblAppearance
		--If it is New Airport(FourLetID) for existing place(There is a GeoRef in the Database), Then use same GeoRef and Update
		--tblAirportInfo and tblCoverageSegment
		IF @existingGeoRefId IS NULL OR @existingGeoRefId = ''
		BEGIN
			SET @geoRefId = @tempGeoRefId + 1
			--Insert tblGeoRef Table and and its Maping Table
			DECLARE @GeoReftblID INT;
			INSERT INTO dbo.tblGeoRef(GeoRefId, Description, CatTypeId, AsxiCatTypeId, PnType, 
						isAirport, isAirportPoi,isAttraction, isCapitalCountry, isCapitalState, isClosestPoi, 
						isInteractivePoi, isInteractiveSearch, isMakkahPoi, isRliPoi,isShipWreck, isSnapshot,
						isSummit, isTerrainLand, isTerrainOcean, isTimeZonePoi, isWaterBody, isWorldClockPoi, 
						isWGuide,Priority, AsxiPriority, RliAppearance, KeepNew, Display)
			VALUES (@geoRefId,@tempCityDesc,2, 10, 1, 
						0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0,0, 0);
			SET @GeoReftblID = SCOPE_IDENTITY();

			INSERT INTO dbo.tblGeoRefMap(ConfigurationID,GeoRefId,PreviousGeoRefID,IsDeleted)
			VALUES ( @configid,@GeoReftblID,0, 0)

			--Insert tblCoverageSegment Table and and its Maping Table
			DECLARE @CoverageSegmenttblId INT;
			INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
			VALUES(@geoRefId,1,@tempLat,@tempLong,0, 0, 7);
			SET @CoverageSegmenttblId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblCoverageSegment', @CoverageSegmenttblId  
	
			--Insert tblAirportInfo Table and and its Maping Table
			DECLARE @airportinfoId INT;
			INSERT INTO dbo.tblAirportInfo(GeoRefID,FourLetID, ThreeLetID,Lat,Lon,CityName, dataSourceId)
			VALUES(@geoRefId,@tempFourLetID,@tempThreeLetID,@tempLat,@tempLong,@tempCity,7);
			SET @airportinfoId = SCOPE_IDENTITY();
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAirportInfo', @airportinfoId
		
			--Insert tblSpelling Table and and its Maping Table
			DECLARE @SpellingtblId INT;
			INSERT INTO dbo.tblSpelling ( GeoRefId, LanguageId, UnicodeStr, FontId, SphereMapFontId, dataSourceId )
			VALUES(@geoRefId,1,@tempCity,1002,1015,7);
			SET @SpellingtblId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblSpelling', @SpellingtblId
	
			-- Update tblAppearance Table only for English)
			--Update the Maping table List, This is used to iterate tblAppearance table for all the resolutions
			DECLARE @existAppearanceTblID INT,@newAppearanceTbleID INT,@NumRes INT, @Init INT;	
			SELECT @NumRes= COUNT(*) FROM @resolutionlistTbl
			SET @Init =1
			WHILE @Init<= @NumRes
			BEGIN
				DECLARE @AppearancetblId INT;
				INSERT INTO dbo.tblAppearance(GeoRefId,Resolution, ResolutionMpp, Exclude, SphereMapExclude )
				VALUES(@geoRefId,(SELECT TOP 1 res FROM @resolutionlistTbl where Zlevel =@Init),(SELECT TOP 1 resMap FROM @resolutionlistTbl where Zlevel =@Init),0,0);
				SET @AppearancetblId = SCOPE_IDENTITY()
				EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAppearance', @AppearancetblId
				SET @Init= @Init + 1
			END				
		END
		ELSE
		BEGIN
			SET @geoRefId = @existingGeoRefId
		END
		IF @existingGeoRefId IS NOT NULL
		BEGIN
			--Insert tblCoverageSegment Table and and its Maping Table
			DECLARE @CoverageSegmentId INT;
			INSERT INTO dbo.tblCoverageSegment(GeoRefId, SegmentId, Lat1, Lon1, Lat2, Lon2, dataSourceId )
			VALUES(@existingGeoRefId,1,@tempLat,@tempLong,0, 0, 7);
			SET @CoverageSegmentId = SCOPE_IDENTITY()
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblCoverageSegment', @CoverageSegmentId  
	
			--Insert tblAirportInfo Table and and its Maping Table
			DECLARE @airportinfotbId INT;
			INSERT INTO dbo.tblAirportInfo(GeoRefID,FourLetID, ThreeLetID,Lat,Lon,CityName, dataSourceId)
			VALUES(@existingGeoRefId,@tempFourLetID,@tempThreeLetID,@tempLat,@tempLong,@tempCity,7);
			SET @airportinfotbId = SCOPE_IDENTITY();
			EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAirportInfo', @airportinfotbId
		END


		DELETE FROM #tbNewAirports WHERE ID = @tbNewAirportsCounter
	END

	--Iterating to the new modified entires and updaing the records
	WHILE(SELECT COUNT(*) FROM #tbUpdateAirports) > 0
	BEGIN	
		SET @UpdateAirportsCounter = (SELECT TOP 1 ID FROM #tbUpdateAirports)
		SET @tempFourLetID = (SELECT TOP 1 FourLetID FROM #tbUpdateAirports)
		SET @geoRefId = (SELECT TOP 1 airinfo.GeoRefID FROM dbo.tblAirportInfo airinfo WHERE airinfo.FourLetID = @tempFourLetID);		
		SET @tempLat =(SELECT TOP 1 Lat FROM #tbUpdateAirports)
		SET @tempLong= (SELECT TOP 1 Long FROM #tbUpdateAirports)
		SET @tempCity= (SELECT TOP 1 City FROM #tbUpdateAirports)
		SET @tempCityDesc= (SELECT TOP 1 Description FROM #tbUpdateAirports)


		--Update the tblAirportInfo and its Maping Table
		SET @existingAirportInfoId = (SELECT airportinfo.AirportInfoID FROM dbo.config_tblAirportInfo(@configid) AS airportinfo 
			WHERE airportinfo.FourLetID = @tempFourLetID AND (airportinfo.GeoRefID  = @geoRefId OR airportinfo.GeoRefID IS NULL))
		IF(@existingAirportInfoId IS NOT NULL AND @existingAirportInfoId !='')
		BEGIN
			DECLARE @updateKey INT
			exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblAirportInfo', @existingAirportInfoId, @updateKey out
			SET NOCOUNT OFF
			UPDATE tblAirportInfo
			SET Lat = @tempLat, Lon = @tempLong, CityName = @tempCity
			WHERE AirportInfoID = @updateKey
		END

		-- --Update the tblCoverageSegment Table and and its Maping Table
		-- SET @existingSegmentId = (SELECT TOP 1 coveragesegment.ID FROM dbo.config_tblCoverageSegment(@configid) AS coveragesegment 
			-- WHERE coveragesegment.GeoRefID = @geoRefId)
		-- IF(@existingSegmentId IS NOT NULL AND @existingSegmentId !='')
		-- BEGIN
			-- DECLARE @updateSegmentKey INT
			-- exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblCoverageSegment', @existingSegmentId, @updateSegmentKey out
			-- SET NOCOUNT OFF
			-- UPDATE tblCoverageSegment
			-- SET  Lat1 = @tempLat, Lon1 = @tempLong
			-- WHERE ID = @updateSegmentKey
		-- END

		DELETE FROM #tbUpdateAirports WHERE ID = @UpdateAirportsCounter
	END

	END
	--Delete the temp table once import is done
	DELETE dbo.tblNavdbAirports;
	DELETE #tbNewAirports
	DELETE #tbUpdateAirports
	DELETE @temptbNewAirportsWithID	
	--Update tblConfigurationHistory with the content
	DECLARE @comment NVARCHAR(MAX)
	SET @comment = ('Imported new airport data for ' + (SELECT CT.Name FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				INNER JOIN tblConfigurationTypes CT ON CD.ConfigurationTypeID = CT.ConfigurationTypeID
				WHERE C.ConfigurationID = @configid) + ' configuration version V' + CONVERT(NVARCHAR(10),(SELECT C.Version FROM tblConfigurations C
				INNER JOIN  tblConfigurationDefinitions CD ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
				WHERE C.ConfigurationID = @configid)))

	SET @userName =   (SELECT FirstName + ' ' + LastName FROM dbo.AspNetUsers WHERE Id IN (SELECT StartedByUserID FROM tblTasks WHERE Id = @currentTaskID) );

	IF EXISTS (SELECT 1 FROM tblConfigurationHistory WHERE ContentType = 'airports' AND ConfigurationID = @configid)
	BEGIN
		UPDATE tblConfigurationHistory SET UserComments = @comment, DateModified = GETDATE(), TaskID = CONVERT(uniqueidentifier ,@currentTaskID), CommentAddedBy = @userName
		WHERE ContentType = 'airports' AND ConfigurationID = @configid
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblConfigurationHistory(ConfigurationID,ContentType,CommentAddedBy,DateModified,TaskID,UserComments)
		VALUES(@configid,'airports',@userName,GETDATE(),CONVERT(uniqueidentifier,@currentTaskID),@comment)
	END
END
GO
