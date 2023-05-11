SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/18/2022
-- Description:	Updates the airport data with given data
-- Sample EXEC [dbo].[SP_Airport_UpdateAirport] 1 , 6,'00S',null, 45.655556,-122.305556 ,523701 , 'Blue River'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_UpdateAirport]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_UpdateAirport]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_UpdateAirport]
	@configurationId INT,
    @airportInfoID INT,
    @fourLetID NVARCHAR(4),
    @threeLetID NVARCHAR(3) = NULL,
    @lat DECIMAL(12,9) = NULL,
    @lon DECIMAL(12,9) = NULL,
    @geoRefID INT = NULL,
    @cityName NVARCHAR(MAX) = NULL,
	@modlistinfo [ModListTable] READONLY
AS
BEGIN
    DECLARE @existingAirportInfoId INT
    DECLARE @newAirportInfoId INT
	DECLARE @custom INT, @existingvalue INT , @updatedvalue INT,@geocustom INT,@existinggeovalue INT,@updatedgeorefid INT
	DECLARE @TempModListTable TABLE( Id INT,Row INT, Columns INT,Resolution INT)
	
    EXEC SP_ConfigManagement_HandleUpdate @configurationId, 'tblAirportInfo', @airportInfoID, @newAirportInfoId output
	SET @custom = 2
	SET @geocustom = 4
	SET @existingvalue = (SELECT  CustomChangeBitMask   FROM tblAirportInfo WHERE tblAirportInfo.AirportInfoID = @newAirportInfoId )
	SET @existinggeovalue = (SELECT  GeoRefID   FROM tblAirportInfo WHERE tblAirportInfo.AirportInfoID = @newAirportInfoId )
	INSERT into @TempModListTable SELECT * from @modlistinfo
	DECLARE @Id int , @Row int,@Columns int,@Resolution int
	
	WHILE (SELECT COUNT(*) FROM @TempModListTable) > 0
	BEGIN
	 SET @Id = (SELECT TOP 1 Id from @TempModListTable)
	 SET @Row = (SELECT  Row  from @TempModListTable WHERE Id =@Id)
	 SET @Columns = (SELECT  Columns  from @TempModListTable WHERE Id =@Id)
	 SET @Resolution = (SELECT  Resolution  from @TempModListTable WHERE Id =@Id)
	 
	 IF EXISTS(SELECT 1 FROM tblModList m INNER JOIN tblModListMap mm on m.ModlistId = mm.ModlistID where m.Row = @row and m.Col = @columns and m.resolution = @resolution and mm.ConfigurationID = @configurationId)
	 begin
	 update m 
	 set isdirty = 1 
	 from tblmodlist m inner join tblmodlistmap mm on m.modlistid = mm.modlistid 
	 where  m.Row = @row and m.Col = @columns and m.resolution = @resolution and mm.ConfigurationID = @configurationId
	 end

	 DELETE FROM @TempModListTable WHERE Id =@Id
	END
	

    -- logic to handle the scenario where we want to update the four letter id of an airport but there is different airport with the same for letter id. In that case return error
    SET @existingAirportInfoId = (SELECT distinct airportinfo.AirportInfoID FROM dbo.config_tblAirportInfo(@configurationId) as airportinfo WHERE airportinfo.FourLetID = @FourLetID)

    IF (@existingAirportInfoId = @newAirportInfoId OR @existingAirportInfoId IS NULL)
    BEGIN
        UPDATE airportinfo 
        SET airportinfo.FourLetID = @fourLetID, airportinfo.ThreeLetID = @threeLetID, airportinfo.Lat = @lat, airportinfo.Lon = @lon, airportinfo.GeoRefID = @geoRefID ,airportinfo.CityName =  @cityName
        FROM 
        dbo.config_tblAirportInfo(@configurationId) as airportinfo 
        WHERE airportinfo.AirportInfoID = @newAirportInfoId
        SELECT  1 as Result,'Airport data updated successfully' as Message
		SET @updatedgeorefid = (SELECT  GeoRefID   FROM tblAirportInfo WHERE tblAirportInfo.AirportInfoID = @newAirportInfoId )
    END
    ELSE 
    BEGIN
        SELECT -1 as Result,'Airport with given 4 letter Id '+@FourLetID+' already exist' as Message
    END
	IF (@existinggeovalue = @updatedgeorefid) 
	BEGIN 
	SET @updatedvalue= (@existingvalue | @custom )
	UPDATE  tblAirportInfo SET tblAirportInfo.CustomChangeBitMask = @updatedvalue WHERE  tblAirportInfo.AirportInfoID = @newAirportInfoId
	END
	ELSE
	BEGIN
	SET @updatedvalue= (@existingvalue | @geocustom )
	UPDATE  tblAirportInfo SET tblAirportInfo.CustomChangeBitMask = @updatedvalue WHERE  tblAirportInfo.AirportInfoID = @newAirportInfoId
	END
	
END    
GO  