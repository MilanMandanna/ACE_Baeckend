SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/14/2022
-- Description:	Get Airport IATA and ICAO names
-- Sample EXEC [dbo].[SP_Airport_GetNames] 1, 'iata'
-- Sample EXEC [dbo].[SP_Airport_GetNames] 1, 'icao'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_GetNames]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_GetNames]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_GetNames]
	@configurationId INT,
	@type NVARCHAR(250)
AS
BEGIN
	IF (@type = 'iata')
	BEGIN 
		SELECT 
        dbo.tblAirportInfo.ThreeLetID 
        FROM dbo.tblAirportInfo 
        INNER JOIN dbo.tblAirportInfoMap ON dbo.tblAirportInfoMap.AirportInfoID = dbo.tblAirportInfo.AirportInfoID
        WHERE dbo.tblAirportInfo.ThreeLetID IS NOT NULL AND dbo.tblAirportInfoMap.ConfigurationID = @configurationId AND dbo.tblAirportInfoMap.IsDeleted = 0
	END
    ELSE IF (@type = 'icao')
    BEGIN
       SELECT 
        dbo.tblAirportInfo.FourLetID 
        FROM dbo.tblAirportInfo 
        INNER JOIN dbo.tblAirportInfoMap ON dbo.tblAirportInfoMap.AirportInfoID = dbo.tblAirportInfo.AirportInfoID
        WHERE dbo.tblAirportInfo.FourLetID IS NOT NULL AND dbo.tblAirportInfoMap.ConfigurationID = @configurationId AND dbo.tblAirportInfoMap.IsDeleted = 0
    END
END
GO