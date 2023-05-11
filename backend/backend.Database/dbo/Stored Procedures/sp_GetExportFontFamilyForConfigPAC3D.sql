GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontFamilyForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontFamilyForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontFamilyForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	FontFaceId,
	FaceName,
	FileName
from tblFontFamily
	inner join tblFontFamilyMap on tblFontFamilyMap.FontFamilyID = tblFontFamily.FontFamilyId
where
	tblFontFamilyMap.ConfigurationID = @configurationId

END

GO