GO 

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportCESHTSEAirportInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportCESHTSEAirportInfo]
END
GO
CREATE PROC sp_GetExportCESHTSEAirportInfo
@configurationId INT
AS 
BEGIN

select
	FourLetId,
	case
		when ThreeLetId is null then 'ZZZ'
		else ThreeLetId
	end as ThreeLetId,
	Lat,
	Lon,
	GeoRefID as PointGeoRefId,
	null as ACARS
from tblAirportInfo
	inner join tblAirportInfoMap as apmap on apmap.AirportInfoID = tblAirportInfo.AirportInfoID
where
	apmap.ConfigurationID = @configurationId and apmap.IsDeleted=0
order by FourLetID

END

GO