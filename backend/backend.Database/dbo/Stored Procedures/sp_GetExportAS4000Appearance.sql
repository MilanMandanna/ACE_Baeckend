GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000Appearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000Appearance]
END
GO
CREATE PROC sp_GetExportAS4000Appearance
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
	tblAppearance.georefid NOT BETWEEN 20000 AND 20162
	AND tblAppearance.georefid NOT BETWEEN 20200 AND 25189
	AND tblAppearance.georefid NOT BETWEEN 200172 AND 200239
	AND tblAppearance.georefid NOT BETWEEN 250001 AND 250017
	and tblAppearance.georefid < 510000
	and resolution not in (0, 3,6, 60, 1620)
	and apmap.ConfigurationID = @configurationId and apmap.isDeleted=0
	and grmap.ConfigurationID = @configurationId and grmap.isDeleted=0
order by georefid, resolution

END

GO