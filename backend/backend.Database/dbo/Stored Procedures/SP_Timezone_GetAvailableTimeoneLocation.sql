SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Get timezone locations
-- Sample EXEC [dbo].[SP_Timezone_GetAvailableTimeoneLocation] 18
-- =============================================

IF OBJECT_ID('[dbo].[SP_Timezone_GetAvailableTimeoneLocation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Timezone_GetAvailableTimeoneLocation]
END
GO

CREATE PROCEDURE [dbo].[SP_Timezone_GetAvailableTimeoneLocation]
@configurationId INT
AS
BEGIN
	SELECT
    TZV.V.value('@name', 'nvarchar(max)') AS city,
    TZV.V.value('(text())[1]', 'nvarchar(max)') AS geoRefId
    FROM cust.config_tblWorldTimeZonePlaceNames(@configurationId) as TZ
    OUTER APPLY TZ.PlaceNames.nodes('world_timezone_placenames/city') AS TZV(V)
END
GO