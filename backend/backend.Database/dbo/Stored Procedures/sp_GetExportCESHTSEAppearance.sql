SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSEAppearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSEAppearance]
END
GO
CREATE PROC sp_GetExportCESHTSEAppearance
@configurationId INT
AS
BEGIN

select
	tblAppearance.GeoRefId,
	Resolution,
	tblAppearance.Priority,
	abs(exclude) as Exclude,
	abs(spheremapexclude) as SphereMapExclude
from tblAppearance
	inner join tblAppearanceMap as apmap on apmap.AppearanceID = tblAppearance.AppearanceID
	inner join tblgeoref on tblgeoref.GeoRefId = tblAppearance.GeoRefID
	inner join tblgeorefmap as grmap on grmap.GeoRefId = tblgeoref.id
where
	tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and 
	tblgeoref.georefid NOT BETWEEN 200172 AND 200239 and
	tblgeoref.georefid NOT BETWEEN 300000 AND 307840 and
	tblgeoref.georefid NOT BETWEEN 310000 AND 414100 and
	resolution in (15, 30, 75, 150, 300, 600, 1620) and
	apmap.ConfigurationID = @configurationId and apmap.IsDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0
order by georefid, resolution

END
GO