GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- Description:	Returns spelling for AS4000
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000Spellings]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000Spellings]
END
GO
CREATE PROC sp_GetExportAS4000Spellings
@configurationId INT
AS
BEGIN

SELECT 
	tblspelling.GeoRefID, 
	languageid as Language, 
	FontID,
	SequenceID,
	UnicodeStr, 
	SphereMapFontID, 
	POISpelling, 
	tblgeoref.PoiPanelStatsAppearance as POIGroup 
from dbo.tblSpelling 
	inner join tblspellingmap as smap on smap.SpellingID = tblSpelling.SpellingID
	inner join tblgeoref on tblgeoref.georefid = dbo.tblspelling.georefid
	inner join tblgeorefmap as grmap on grmap.GeoRefId = tblgeoref.ID
WHERE 
	smap.ConfigurationID = @configurationId and smap.IsDeleted=0
	and grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0
and tblspelling.georefid in 
(
	select tblgeoref.georefid
	from dbo.tblGeoRef 
		inner join tblgeorefmap on tblgeorefmap.GeoRefID = tblgeoref.id
	where tblgeoref.georefid < 510000 
		AND tblgeoref.georefid NOT BETWEEN 20000 AND 20162 
		AND tblgeoref.georefid NOT BETWEEN 20200 AND 25189 
		AND tblgeoref.georefid NOT BETWEEN 200172 AND 200239 
		AND tblgeoref.georefid NOT BETWEEN 250001 AND 250017
		and tblgeorefmap.configurationid = @configurationId and tblgeorefmap.IsDeleted=0
)

END

GO