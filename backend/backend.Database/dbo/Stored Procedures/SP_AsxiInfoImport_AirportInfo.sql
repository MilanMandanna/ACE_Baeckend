SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_AirportInfo] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_AirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_AirportInfo]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_AirportInfo]
		@configid INT
AS
BEGIN

	DECLARE @tempNewAirportInfoCounter INT, @existingAirportInfoId INT, @newAirportInfoId INT,
	@AsxiAirportFourLetId NVARCHAR(4), @AsxiAirportThreeLetId NVARCHAR(4), @AsxiAirportGeoRefID INT, @AsxiAirportLat FLOAT, @AsxiAirportLong FLOAT;
	CREATE TABLE #tempNewAirportInfoWithIDs (AirportInfoId INT IDENTITY (1,1) NOT NULL, FourLetID NVARCHAR(4) NULL,ThreeLetID NVARCHAR(3),Lat DECIMAL (12,9) NULL,
	Lon DECIMAL(12,9) NULL,GeoRefID INT NULL)
	DECLARE @customChangeBitMask INT, @existingvalue INT, @updatedvalue INT;

	--Since there ID column for AsxiInfotbairportinfo. Created the table with one and added the records.
	INSERT INTO #tempNewAirportInfoWithIDs SELECT FourLetId,ThreeLetId,Lat,Lon,PointGeoRefId FROM AsxiInfotbairportinfo 
	
	--For new records
	SELECT TempAsxi.* INTO  #tempNewAirportInfo FROM #tempNewAirportInfoWithIDs AS TempAsxi WHERE FourLetID NOT IN 
			(SELECT T.FourLetID FROM tblAirportInfo T INNER JOIN tblAirportInfoMap TMap ON T.AirportInfoID = TMap.AirportInfoID
				WHERE TMap.ConfigurationID = @configid);
	
	--For Modified records
	SELECT TempAsxi.* INTO  #tempUpdateAirportInfo FROM #tempNewAirportInfoWithIDs AS TempAsxi WHERE TempAsxi.FourLetID IN
			(SELECT T.FourLetID FROM tblAirportInfo T INNER JOIN tblAirportInfoMap TMap ON T.AirportInfoID = TMap.AirportInfoID
				WHERE (TempAsxi.ThreeLetID != T.ThreeLetID OR
							TempAsxi.Lat != ROUND(T.Lat,6) OR
							TempAsxi.Lon != ROUND(T.Lon,6)) AND TMap.ConfigurationID = @configid);


	--Iterating to the new temp tables and adding it to the tblAirportInfo and tblAirportInfoMap
	WHILE(SELECT COUNT(*) FROM #tempNewAirportInfo) > 0
	BEGIN
		
		SET @tempNewAirportInfoCounter = (SELECT TOP 1 AirportInfoId FROM #tempNewAirportInfo)
		SET @AsxiAirportGeoRefID = (SELECT TOP 1 GeoRefID FROM #tempNewAirportInfo)	
		SET @AsxiAirportFourLetId = (SELECT TOP 1 FourLetID FROM #tempNewAirportInfo)
		SET @AsxiAirportThreeLetId = (SELECT TOP 1 ThreeLetID FROM #tempNewAirportInfo)
		SET @AsxiAirportLat = (SELECT TOP 1 Lat FROM #tempNewAirportInfo)
		SET @AsxiAirportLong = (SELECT TOP 1 Lon FROM #tempNewAirportInfo)

		DECLARE @airportinfoId INT;
		INSERT INTO tblAirportInfo(FourLetID, ThreeLetID, Lat, Lon, GeoRefID, CustomChangeBitMask)
		VALUES (@AsxiAirportFourLetId, @AsxiAirportThreeLetId, @AsxiAirportLat, @AsxiAirportLong, @AsxiAirportGeoRefID, 8) 
		SET @airportinfoId = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblAirportInfo', @airportinfoId


		DELETE FROM #tempNewAirportInfo WHERE AirportInfoId = @tempNewAirportInfoCounter
	END

	--Iterating to the new temp tables and adding it to the tblAirportInfo and tblAirportInfoMap
	WHILE(SELECT COUNT(*) FROM #tempUpdateAirportInfo) > 0
	BEGIN	

		SET @tempNewAirportInfoCounter = (SELECT TOP 1 AirportInfoId FROM #tempUpdateAirportInfo)
		SET @AsxiAirportGeoRefID = (SELECT TOP 1 GeoRefID FROM #tempUpdateAirportInfo)		
		SET @AsxiAirportFourLetId = (SELECT TOP 1 FourLetID FROM #tempUpdateAirportInfo)
		SET @AsxiAirportThreeLetId = (SELECT TOP 1 ThreeLetID FROM #tempUpdateAirportInfo)
		SET @AsxiAirportLat = (SELECT TOP 1 Lat FROM #tempUpdateAirportInfo)
		SET @AsxiAirportLong = (SELECT TOP 1 Lon FROM #tempUpdateAirportInfo)


		--Update the tblAirportInfo and its Maping Table
		SET @existingAirportInfoId = (SELECT airportinfo.AirportInfoID FROM dbo.config_tblAirportInfo(@configid) AS airportinfo 
			WHERE airportinfo.FourLetID = @AsxiAirportFourLetId)

		DECLARE @updateKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblAirportInfo', @existingAirportInfoId, @updateKey out

		SET @customChangeBitMask = 2
 	 	SET @existingvalue = (SELECT CustomChangeBitMask FROM tblAirportInfo WHERE AirportInfoID = @updateKey)
 	 	SET @updatedvalue =(@existingvalue | @customChangeBitMask)
		SET NOCOUNT OFF
		UPDATE tblAirportInfo
		SET ThreeLetID = @AsxiAirportThreeLetId, Lat = @AsxiAirportLat, Lon = @AsxiAirportLong, CustomChangeBitMask = @updatedvalue
		WHERE AirportInfoID = @updateKey

		DELETE FROM #tempUpdateAirportInfo WHERE AirportInfoId = @tempNewAirportInfoCounter
	END

	DROP TABLE #tempNewAirportInfo
	DROP TABLE #tempUpdateAirportInfo
	DROP TABLE #tempNewAirportInfoWithIDs
END


