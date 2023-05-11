-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the list of placenames for given config id


-- =============================================

IF OBJECT_ID('[dbo].[sp_placenames_getplacenames]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getplacenames]
END
GO
CREATE PROC sp_placenames_getplacenames
@configurationId INT
AS
BEGIN
   select georef.ID,georef.GeoRefId,georef.Description,country.Description as CountryName,region.RegionNAme
   from   config_tblGeoRef(@configurationId) as georef 
   inner join config_tblCountry(@configurationId) as country on georef.CountryId = country.CountryId
   inner join config_tblRegion (@configurationId) as region on georef.RegionId = region.RegionId
   where  region.languageId =1  ORDER BY Description

		
END

GO