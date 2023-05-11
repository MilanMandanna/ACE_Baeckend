GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontFamilyForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontFamilyForConfig]
END
GO
CREATE PROC sp_GetExportFontFamilyForConfig
@configurationId INT
AS
BEGIN

select
	FontFaceId,
	FaceName AS Name
from tblFontFamily
	inner join tblFontFamilyMap on tblFontFamilyMap.FontFamilyID = tblFontFamily.FontFamilyId
where
	tblFontFamilyMap.ConfigurationID = @configurationId

END

GO