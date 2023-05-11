GO
-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000AirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000AirportInfo]
END
GO
CREATE PROC sp_GetExportAS4000AirportInfo
@configurationId INT
AS
BEGIN

select
	FourLetId,
	ThreeLetId,
	Lat,
	Lon,
	GeoRefId as PointGeoRefId,
	null as Include,
	null as ACARS,
	null as DispDest
from tblAirportInfo
	inner join tblAirportInfoMap on tblAirportInfoMap.AirportInfoID = tblAirportInfo.AirportInfoID
where
	tblAirportInfoMap.ConfigurationID = @configurationId and tblAirportInfoMap.isDeleted=0

END

GO