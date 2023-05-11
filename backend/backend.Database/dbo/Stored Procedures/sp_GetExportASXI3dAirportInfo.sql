GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportASXI3dAirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportASXI3dAirportInfo]
END
GO
CREATE PROC sp_GetExportASXI3dAirportInfo
@configurationId INT
AS
BEGIN
select
	FourLetID as FourLetId,
	ThreeLetID as ThreeLetId,
	Lat,
	Lon, 
	tblAirportInfo.GeoRefID as PointGeoRefId,
	null as AirportGeoRefId,
	0 as CustomChangeBit
from tblairportinfo
    inner join tblgeoref on tblgeoref.georefid = tblairportinfo.georefid
	inner join tblairportinfomap as apmap on apmap.AirportInfoID = tblairportinfo.AirportInfoID
    inner join tblgeorefmap as grmap on grmap.GeoRefID = tblgeoref.id
where
    tblgeoref.georefid not between 200172 and 200239 and
	tblgeoref.georefid not between 300000 and 307840 and
	apmap.ConfigurationID = @configurationId and apmap.isDeleted=0 and
	grmap.ConfigurationID = @configurationId and grmap.isDeleted=0
order by tblairportinfo.FourLetID
END

GO 