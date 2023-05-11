GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetASXI3dCoverageSegments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetASXI3dCoverageSegments]
END
GO
CREATE PROC sp_GetASXI3dCoverageSegments
@configurationId INT
AS
BEGIN

select 
	tblCoverageSegment.GeoRefID,
	SegmentID,
	Lat1,
	Lon1,
	Lat2,
	Lon2,
	tblCoverageSegment.CustomChangeBitMask as CustomChangeBit
from tblCoverageSegment
    inner join tblgeoref on tblgeoref.GeoRefId = tblCoverageSegment.GeoRefID
	inner join tblCoverageSegmentMap as csmap on csmap.CoverageSegmentID = tblCoverageSegment.ID
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
where
	tblgeoref.georefid not between 200172 and 200239 and
	tblgeoref.georefid not between 300000 and 307840 and
	csmap.ConfigurationID = @configurationId and csmap.IsDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0 and
	tblCoverageSegment.GeoRefID in (
	  select georefid
	  from tblcoveragesegment
		inner join tblcoveragesegmentmap as cvgmap on cvgmap.CoverageSegmentID = tblcoveragesegment.ID
	  where 
		cvgmap.ConfigurationID = @configurationId and cvgmap.IsDeleted=0 
		and tblcoveragesegment.segmentid = 1
	)
order by georefid

END

GO