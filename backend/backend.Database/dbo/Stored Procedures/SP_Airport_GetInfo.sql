SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/14/2022
-- Description:	Get all the Airport Info for a given configuration id
-- Sample EXEC [dbo].[SP_Airport_GetInfo] 1, 
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_GetInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_GetInfo]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_GetInfo]
	@configurationId INT
AS
BEGIN
    select distinct
    airportinfo.*,
    country.Description as Country
    from dbo.config_tblAirportInfo(@configurationId) as airportinfo
    left outer join dbo.config_tblGeoRef(@configurationId) as georef on airportinfo.georefid = georef.georefid
    left outer join dbo.config_tblCountry(@configurationId) as country on georef.CountryId = country.CountryID
    ORDER BY airportinfo.FourLetId ASC
END
GO