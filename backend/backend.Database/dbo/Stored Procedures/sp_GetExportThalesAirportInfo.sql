GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportThalesAirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportThalesAirportInfo]
END
GO
CREATE PROC sp_GetExportThalesAirportInfo
@configurationId INT
AS
BEGIN

select
	FourLetId,
	ThreeLetId,
	Lat,
	Lon,
	GeoRefID as PointGeoRefId,
	null as ACARS
from tblAirportInfo
	inner join tblAirportInfoMap as apmap on apmap.AirportInfoID = tblAirportInfo.AirportInfoID
where
	apmap.ConfigurationID = @configurationId and apmap.isDeleted=0
order by FourLetID

END

GO