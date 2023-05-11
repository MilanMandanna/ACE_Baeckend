-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the place name information with LON and LAN
-- =============================================

GO
IF OBJECT_ID('[dbo].[sp_placenames_getplacenameinfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getplacenameinfo]
END
GO
CREATE PROC sp_placenames_getplacenameinfo
@configurationId INT,
@placeNameId INT
AS
BEGIN

DECLARE @ENG_lang_id INT
SELECT @ENG_lang_id=LanguageID FROM config_tblLanguage(@configurationId) WHERE [2LetterID_4xxx]='EN';

select distinct seg.ID as SegId,seg.Lat1,seg.Lon1,seg.Lat2,seg.Lon2,ctry.CountryID,ctry.Description,rgn.RegionID,rgn.RegionName,geoRef.ID,geoRef.GeoRefId
from config_tblGeoRef(@configurationId) geoRef 
INNER JOIN config_tblCoverageSegment(@configurationId) seg ON seg.GeoRefID=geoRef.GeoRefID
LEFT JOIN config_tblCountry(@configurationId) ctry ON ctry.CountryID=geoRef.CountryID
LEFT JOIN config_tblRegion(@configurationId) rgn ON rgn.RegionID=georef.RegionID AND rgn.LanguageId=@ENG_lang_id
WHERE geoRef.ID=@placeNameId AND seg.SegmentID=1

END


GO