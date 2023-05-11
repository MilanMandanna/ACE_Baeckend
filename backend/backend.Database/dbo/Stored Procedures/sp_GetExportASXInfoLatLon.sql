GO
-- =============================================
-- Author:		<Sathya>
-- Create date: <19-05-2022>
-- Description:	 Retrieves the latitude and longitude information for each georef record. Suitable for export
--                    into the asxinfo database
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXInfoLatLon]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXInfoLatLon]
END
GO
CREATE PROC sp_GetExportASXInfoLatLon
@configurationId INT
AS
BEGIN
select 
	tblgeoref.georefid,
    tblcoveragesegment.lat1 as lat,
    tblcoveragesegment.lon1 as lon
from tblgeoref
    inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
    inner join tblCoverageSegment on tblCoverageSegment.georefid = tblgeoref.georefid
    inner join tblcoveragesegmentmap on tblcoveragesegmentmap.CoverageSegmentID = tblcoveragesegment.id
where tblgeorefmap.configurationid = @configurationId
    and tblcoveragesegmentmap.configurationid = @configurationId and tblcoveragesegmentmap.isDeleted=0
    and tblcoveragesegment.segmentid = 1 and tblGeoRefMap.IsDeleted=0
order by tblgeoref.georefid
END
GO