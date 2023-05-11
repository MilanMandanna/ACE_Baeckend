GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dGeoRefIdTbTzStrip]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dGeoRefIdTbTzStrip]
END
GO
CREATE PROC sp_GetExportASXI3dGeoRefIdTbTzStrip
@configurationId INT
AS
BEGIN

select 
	tblgeoref.GeoRefId,
	tbltimezonestrip.IdVer2 as TimeZoneStrip
from tblTimeZoneStrip
	inner join tblgeoref on tblgeoref.TZStripId = tblTimeZoneStrip.TZStripID
	inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
	inner join tblTimeZoneStripMap as tzsmap on tzsmap.TimeZoneStripID = tblTimeZoneStrip.ID
where
	tblgeoref.georefid not between 200172 and 200239 and
	tblgeoref.georefid not between 300000 and 307840 and
	grmap.ConfigurationID = @configurationId and grmap.IsDeleted=0 and
	tzsmap.ConfigurationID = @configurationId and tzsmap.isDeleted=0
order by georefid

END

GO