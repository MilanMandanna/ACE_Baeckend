GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dAppearance]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dAppearance]
END
GO
CREATE PROC sp_GetExportASXI3dAppearance
@configurationId INT
AS 
BEGIN

select
  tblAppearance.georefid as GeoRefId,
  tblappearance.ResolutionMpp as Resolution,
  tblgeoref.AsxiPriority as Priority,
  case 
	when tblappearance.exclude != 0 then 1
	else 0
  end as Exclude,
  tblappearance.CustomChangeBitMask as CustomChangeBit
from tblappearance
  inner join tblgeoref on tblgeoref.georefid = tblappearance.georefid
  inner join tblCoverageSegment as cvg on cvg.GeoRefID = tblgeoref.georefid
  inner join tblAppearanceMap as amap on amap.AppearanceID = tblAppearance.AppearanceID
  inner join tblGeoRefMap as grmap on grmap.GeoRefID = tblgeoref.id
  inner join tblCoverageSegmentMap as cvgmap on cvgmap.CoverageSegmentID = cvg.ID
where
	tblappearance.georefid not between 200172 and 200239 and
	tblappearance.georefid not between 300000 and 307840 and
	tblappearance.ResolutionMpp in (15, 30, 60, 120, 240, 480, 960, 1920, 3840, 7680, 15360) and
	cvg.SegmentID = 1 and
	amap.ConfigurationID = @configurationId and amap.isDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.isDeleted=0 and
	cvgmap.ConfigurationID = @configurationId and cvgmap.isDeleted=0 
order by tblAppearance.georefid

END

GO