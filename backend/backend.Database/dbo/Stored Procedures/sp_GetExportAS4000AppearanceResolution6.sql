GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000AppearanceResolution6]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000AppearanceResolution6]
END
GO
CREATE PROC sp_GetExportAS4000AppearanceResolution6
@configurationId INT
AS 
BEGIN
select
	tblAppearance.GeoRefId,
	Resolution,
	tblGeoRef.Priority as Priority,
	tblGeoRef.MarkerId as MarkerId,
	Exclude,
	tblGeoRef.isInteractivePoi as POI,
	tblGeoRef.AtlasMarkerId as AtlasMarkerId,
	SphereMapExclude,
	null as SphereMapPNMeshId
from tblAppearance
	inner join tblgeoref on tblgeoref.GeoRefId = tblAppearance.GeoRefID
	inner join tblAppearanceMap as apmap on apmap.AppearanceID = tblAppearance.AppearanceID
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.ID
where
	tblAppearance.georefid between 300000 and 307840
	and tblAppearance.resolution = 6
	and apmap.ConfigurationID = @configurationId and apmap.isDeleted=0
	and grmap.ConfigurationID = @configurationId and grmap.isDeleted=0
order by georefid, resolution
END

GO