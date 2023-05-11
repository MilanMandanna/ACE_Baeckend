GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetCESHTSECoverageSegments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetCESHTSECoverageSegments]
END
GO
CREATE PROC sp_GetCESHTSECoverageSegments
@configurationId INT
AS
BEGIN

select
	tblCoverageSegment.GeoRefId,
	SegmentId,
	Lat1,
	Lon1,
	Lat2,
	Lon2
from tblCoverageSegment
	inner join tblCoverageSegmentMap as csmap on csmap.CoverageSegmentID = tblCoverageSegment.ID
	inner join tblgeoref on tblgeoref.GeoRefId = tblCoverageSegment.GeoRefID
	inner join tblgeorefmap as grmap on grmap.GeoRefId = tblgeoref.id
where
	tblgeoref.georefid NOT BETWEEN 20200 AND 25189 and 
	tblgeoref.georefid NOT BETWEEN 200172 AND 200239 and
	tblgeoref.georefid NOT BETWEEN 300000 AND 307840 and
	tblgeoref.georefid NOT BETWEEN 310000 AND 414100 and
	csmap.ConfigurationID = @configurationId and csmap.IsDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0
order by tblCoverageSegment.georefid, segmentid

END

GO