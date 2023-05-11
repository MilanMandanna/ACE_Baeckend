GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontDefaultCategoryForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontDefaultCategoryForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontDefaultCategoryForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	GeoRefIdCatTypeId,
	FontId,
	MarkerId,
	Resolution,
	SphereFontId,
	AtlasMarkerId,
	SphereMarkerId
from tblFontDefaultCategory
	inner join tblFontDefaultCategoryMap on tblFontDefaultCategoryMap.FontDefaultCategoryID = tblFontDefaultCategory.FontDefaultCategoryID
where
	tblFontDefaultCategoryMap.ConfigurationID = @configurationId

END

GO