SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/18/2022
-- Description:	Updates the airport data with given data
-- Sample EXEC [dbo].[SP_Airport_AddAirport] 1 ,'00S',null, 45.655556,-122.305556 ,523701 , 'Blue River'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_AddAirport]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_AddAirport]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_AddAirport]
	@configurationId INT,
    @fourLetID NVARCHAR(4),
    @threeLetID NVARCHAR(3) = NULL,
    @lat DECIMAL(12,9) = NULL,
    @lon DECIMAL(12,9) = NULL,
    @geoRefID INT = NULL,
    @cityName NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @existingAirportInfoMapCount INT
    DECLARE @existingAirportInfoId INT
    DECLARE @newAirportInfoId INT

    SET @existingAirportInfoMapCount = (SELECT COUNT(*) FROM dbo.tblAirportInfoMap INNER JOIN dbo.tblAirportInfo ON  dbo.tblAirportInfo.AirportInfoID = dbo.tblAirportInfoMap.AirportInfoID WHERE dbo.tblAirportInfoMap.ConfigurationID = @configurationId AND dbo.tblAirportInfo.FourLetId = @fourLetID AND dbo.tblAirportInfoMap.IsDeleted = 0)
    IF (@existingAirportInfoMapCount > 1)
    BEGIN        
        SELECT -1 as Result,'Airport with given 4 letter Id '+@FourLetID+' already exist' as Message
    END
    ELSE 
    BEGIN
        SET @existingAirportInfoId = (
            SELECT DISTINCT
            airportinfo.AirportInfoID
            FROM dbo.config_tblAirportInfo(@configurationId) as airportinfo
            WHERE airportinfo.FourLetId = @fourLetID
        )
        IF (@existingAirportInfoId IS NOT NULL)
        BEGIN
            EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblAirportInfo',@existingAirportInfoId
            SELECT 2 as Result,'New mapping with '+CAST(@configurationId AS varchar)+ ' and '+@FourLetID+' has been created' as Message

        END
        ELSE
        BEGIN
            INSERT INTO dbo.tblAirportInfo(FourLetID,ThreeLetID,Lat,Lon,GeoRefID,CityName,DataSourceID,CustomChangeBitMask) VALUES(@fourLetID,@threeLetID,@lat,@lon,@geoRefID,@cityName,7,1)
            SET @newAirportInfoId = (SELECT MAX(airportinfo.AirportInfoID) FROM dbo.tblAirportInfo as airportinfo)
            EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblAirportInfo',@newAirportInfoId
            SELECT 1 as Result,'New airport with IATA "'+@FourLetID+'" has been created' as Message

        END
    END
END    
GO  