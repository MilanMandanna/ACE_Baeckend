GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontCategoryForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontCategoryForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontCategoryForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	GeoRefIdCatTypeId,
	LanguageId,
	FontId,
	MarkerId,
	IMarkerId
from tblFontCategory
	inner join tblFontCategoryMap on tblFontCategoryMap.FontCategoryID = tblFontCategory.FontCategoryID
where
	tblFontCategoryMap.ConfigurationID = @configurationId

END

GO