GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontCategoryForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontCategoryForConfig]
END
GO
CREATE PROC sp_GetExportFontCategoryForConfig
@configurationId INT
AS
BEGIN

select
	GeoRefIdCatTypeId,
	LanguageId,
	FontId,
	MarkerId,
	Resolution,
	SphereFontId,
	AtlasMarkerId,
	SphereMarkerId
from tblFontCategory
	inner join tblFontCategoryMap on tblFontCategoryMap.FontCategoryID = tblFontCategory.FontCategoryID
where
	tblFontCategoryMap.ConfigurationID = @configurationId

END

GO