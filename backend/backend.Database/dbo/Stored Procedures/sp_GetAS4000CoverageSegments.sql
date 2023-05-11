GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetAS4000CoverageSegments]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetAS4000CoverageSegments]
END
GO
CREATE PROC sp_GetAS4000CoverageSegments
@configurationId INT
AS
BEGIN

SELECT 
	tblCoverageSegment.GeoRefId,
	tblCoverageSegment.SegmentID,
	Lat1,
	Lon1,
	Lat2,
	Lon2
from dbo.tblCoverageSegment 
	inner join tblCoverageSegmentMap csmap on csmap.CoverageSegmentID = tblCoverageSegment.ID
	inner join tblgeoRef on tblGeoRef.GeoRefId = tblCoverageSegment.GeoRefID
	inner join tblGeoRefMap as grmap on grmap.GeoRefID = tblgeoref.id
WHERE 
	tblCoverageSegment.georefid < 510000 
	and tblCoverageSegment.georefid NOT BETWEEN 20000 AND 20162 
	and tblCoverageSegment.georefid NOT BETWEEN 20200 AND 25189 
	and tblCoverageSegment.georefid NOT BETWEEN 200172 AND 200239 
	AND tblCoverageSegment.georefid NOT BETWEEN 250001 AND 250017 
	AND tblCoverageSegment.georefid NOT BETWEEN 300000 AND 307840
	and csmap.configurationId = @configurationId and csmap.IsDeleted=0
	and grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0
order by tblCoverageSegment.GeoRefID

END

GO