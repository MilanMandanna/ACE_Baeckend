GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontDefaultCategoryForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontDefaultCategoryForConfig]
END
GO
CREATE PROC sp_GetExportFontDefaultCategoryForConfig
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