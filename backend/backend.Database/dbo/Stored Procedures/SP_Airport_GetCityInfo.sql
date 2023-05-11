SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 03/21/2022
-- Description:	Get all the City Info for a given configuration id
-- Sample EXEC [dbo].[SP_Airport_GetCityInfo] 1, 
-- =============================================

IF OBJECT_ID('[dbo].[SP_Airport_GetCityInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Airport_GetCityInfo]
END
GO

CREATE PROCEDURE [dbo].[SP_Airport_GetCityInfo]
	@configurationId INT
AS
BEGIN
    SELECT distinct georef.georefid as GeoRefId,georef.Description Name,
    country.Description as Country
    FROM 
    dbo.config_tblGeoRef(@configurationId) as georef
    left outer join dbo.config_tblCountry(@configurationId) as country on georef.CountryId = country.CountryID
END
GO