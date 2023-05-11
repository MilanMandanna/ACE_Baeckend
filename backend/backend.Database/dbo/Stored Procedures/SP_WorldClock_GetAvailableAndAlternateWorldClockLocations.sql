SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get availavle and alternate world clock locations
-- Sample EXEC [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations] 18, 'alternate'
-- =============================================

IF OBJECT_ID('[dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]
END
GO

CREATE PROCEDURE [dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]
@configurationId INT,
@type NVARCHAR(150)
AS
BEGIN
	IF (@type = 'available')
	BEGIN
		SELECT WCL.V.value('@name', 'nvarchar(max)') AS city,
        WCL.V.value('@geoRef', 'INT') AS geoRefId
        FROM cust.config_tblWorldClockCities(@configurationId) as WC
        OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/city') AS WCL(V)
	END
	
	ELSE IF (@type = 'alternate')
	BEGIN
		SELECT WCL.V.value('@name', 'nvarchar(max)') AS city,
        WCL.V.value('@geoRef', 'INT') AS geoRefId
        FROM cust.config_tblWorldClockCities(@configurationId) as WC
        OUTER APPLY WC.WorldClockCities.nodes('worldclock_cities/default_city') AS WCL(V)
	END
END
GO