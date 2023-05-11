GO
-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIds]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIds]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIds
@configurationId INT
AS
BEGIN
select 
	null as '4xx POI',
	tblGeoRef.GeoRefId,
	Description as Name,
	isCapitalCountry as 'country capital',
	isTerrainOcean as 'Ocean Floor',
	PnType,
	isCapitalState as 'State Capitals',
	case
		when CatTypeId is null then 1
		else CatTypeId
	end as GeoRefIdCatTypeId,
	Display,
	KeepNew
from tblgeoref
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblGeoRef.ID
where
	tblgeoref.georefid NOT BETWEEN 20000 AND 20162
	AND tblgeoref.georefid NOT BETWEEN 20200 AND 25189
	AND tblgeoref.georefid NOT BETWEEN 200172 AND 200239
	AND tblgeoref.georefid NOT BETWEEN 250001 AND 250017
	and grmap.ConfigurationID = @configurationId and grmap.isDeleted=0
END

GO