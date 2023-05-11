GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSEGeoRefIds]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSEGeoRefIds]
END
GO
CREATE PROC sp_GetExportCESHTSEGeoRefIds
@configurationId INT
AS 
BEGIN

select
	tblgeoref.GeoRefId,
	Description as Name,
	PnType as PnGeoType,
	RliAppearance as POIType,
	CatTypeId as GeoRefIdCatTypeId
from tblgeoref
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.ID
where
	tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and 
	tblgeoref.georefid NOT BETWEEN 200172 AND 200239 and
	tblgeoref.georefid NOT BETWEEN 300000 AND 307840 and
	tblgeoref.georefid NOT BETWEEN 310000 AND 414100 and
	grmap.ConfigurationID = @configurationId AND grmap.isDeleted=0
order by tblgeoref.GeoRefId

END

GO