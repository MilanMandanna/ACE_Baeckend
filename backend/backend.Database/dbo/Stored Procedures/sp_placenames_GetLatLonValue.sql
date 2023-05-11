-- =============================================
-- Author:		Abhishek
-- Create date: 9/14/2022
-- Description:	returns the lat and lon values
-- =============================================

GO
IF OBJECT_ID('[dbo].[sp_placenames_GetLatLonValue]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_GetLatLonValue]
END
GO
CREATE PROC  [dbo].[sp_placenames_GetLatLonValue]
       @placeNameId INT,
       @geoRefId INT

AS
BEGIN
	DECLARE @tempGeoRef int
	IF(@placeNameId != 0)
		BEGIN
		SET	@tempGeoRef =( select GeoRefId from tblGeoRef where ID =@placeNameId)
			SELECT Lat1 AS Lat ,Lon1 AS Lon FROM tblCoverageSegment WHERE GeoRefID = @tempGeoRef 
		END
	ELSE IF(@geoRefId != 0)
		BEGIN
			SELECT Lat1 AS Lat ,Lon1 AS Lon FROM tblCoverageSegment WHERE GeoRefID = @geoRefId 
		END
END
GO