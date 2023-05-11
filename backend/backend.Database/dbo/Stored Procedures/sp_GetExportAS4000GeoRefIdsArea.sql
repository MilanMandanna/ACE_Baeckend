GO

-- =============================================
-- Author:		Sathya
-- Create date: 19-May-2022
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportAS4000GeoRefIdsArea]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportAS4000GeoRefIdsArea]
END
GO
CREATE PROC sp_GetExportAS4000GeoRefIdsArea
@configurationId INT
AS
BEGIN

SELECT 
	georefid,
	Area
from tblArea
	inner join tblAreaMap as amap on amap.AreaID = tblArea.AreaID
where
	amap.ConfigurationID = @configurationId and amap.IsDeleted=0

END

GO