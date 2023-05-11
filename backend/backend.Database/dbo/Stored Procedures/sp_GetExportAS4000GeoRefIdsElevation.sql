-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsElevation]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsElevation]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsElevation
@configurationId INT
AS
BEGIN

SELECT
	georefid,
	Elevation 
from tblElevation
	inner join tblElevationMap as emap on emap.ElevationID = tblElevation.ID
where
	emap.ConfigurationID = @configurationId and emap.IsDeleted=0

END

GO