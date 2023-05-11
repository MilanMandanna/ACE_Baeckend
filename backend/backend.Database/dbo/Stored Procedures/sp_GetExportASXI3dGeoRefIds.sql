GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dGeoRefIds]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dGeoRefIds]
END
GO
CREATE PROC sp_GetExportASXI3dGeoRefIds
@configurationId INT,
@languages VARCHAR(MAX)
AS
BEGIN
DECLARE @sql NVARCHAR(MAX)
SET @sql='select 
		*
from (
	select 
		tblgeoref.georefid,
		tblgeoref.description,
		tblgeoref.AsxiCatTypeId as GeoRefIdCatTypeId,
		tblgeoref.regionid,
		tblgeoref.countryid,
		tblgeoref.MapStatsAppearance as LayerDisplay,
		tblgeoref.isInteractiveSearch as ISearch,
		tblgeoref.isrlipoi as RLIPOI,
		tblgeoref.isInteractivePoi as IPOI,
		tblgeoref.isWorldClockPoi as WCPOI,
		tblgeoref.isClosestPoi as ClosestPOI,
		tblgeoref.ismakkahpoi as MakkahPOI,
		tblgeoref.customchangebitmask as CustomChangeBit,
		tblcoveragesegment.lat1 as Lat,
		tblcoveragesegment.lon1 as Lon,
		tbllanguages.[2LetterID_ASXi] as code, 
		tblspelling.unicodestr as spelling,
		elevation.elevation as elevation,
		population.Population as population,
		tblgeoref.Priority as Priority
	from tblgeoref
		inner join tblgeorefmap on tblgeorefmap.georefid = tblgeoref.id
		inner join tblspelling on tblspelling.georefid = tblgeoref.georefid
		inner join tblspellingmap on tblspellingmap.spellingid = tblspelling.spellingid
		inner join tbllanguages on tbllanguages.languageid = tblspelling.languageid
		inner join tbllanguagesmap on tbllanguagesmap.languageid = tbllanguages.id
		inner join tblcoveragesegment on tblcoveragesegment.GeoRefID = tblgeoref.georefid
		inner join tblCoverageSegmentMap on tblCoverageSegmentMap.CoverageSegmentID = tblCoverageSegment.id
		left join (
			select tblelevation.* from tblelevation inner join tblelevationmap on tblelevationmap.elevationid = tblelevation.id
			where tblelevationmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblelevationmap.IsDeleted=0
		) as elevation on elevation.georefid = tblgeoref.georefid
		left join (
			select tblcitypopulation.* from tblCityPopulation inner join tblCityPopulationMap on tblCityPopulationMap.CityPopulationID = tblCityPopulation.CityPopulationID
			where tblCityPopulationMap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblCityPopulationMap.IsDeleted=0
		) as population on population.GeoRefID = tblgeoref.GeoRefId
	where tblgeorefmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and
		tblgeoref.georefid not between 200172 and 200239 and
		tblgeoref.georefid not between 300000 and 307840 and
		tblspellingmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblspellingmap.isDeleted=0 and
		tbllanguagesmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tbllanguagesmap.IsDeleted=0 and
		tblcoveragesegmentmap.configurationid = '+Cast(@configurationId AS NVARCHAR)+' and tblcoveragesegmentmap.IsDeleted=0 and
		tblcoveragesegment.SegmentID = 1
) as sourcetable
pivot(
    max(spelling)
    for code in ('+@languages+')
) as pivottable
order by georefid'

EXECUTE sp_executesql @sql;


END

GO