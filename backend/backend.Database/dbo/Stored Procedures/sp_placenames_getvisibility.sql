-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	returns the list of placename visibility for given config id and georef id
-- =============================================
GO
IF OBJECT_ID('[dbo].[sp_placenames_getvisibility]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_getvisibility]
END
GO
CREATE PROC sp_placenames_getvisibility
@geoRefId INT,
@configurationId INT
AS
BEGIN

SELECT appearnce.appearanceid,
		appearnce.ResolutionMpp as resolution,
		appearnce.Priority,
		cast(appearnce.exclude as int) as exclude
FROM config_tblGeoRef(@configurationId) geoRef INNER JOIN config_tblappearance(@configurationId) appearnce
ON appearnce.GeoRefID=geoRef.GeoRefId WHERE geoRef.GeoRefId=@geoRefId AND appearnce.ResolutionMpp <>0 ORDER BY appearnce.ResolutionMpp
END


GO
