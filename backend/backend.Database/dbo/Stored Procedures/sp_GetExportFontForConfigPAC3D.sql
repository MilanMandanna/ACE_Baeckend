GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	tblFont.FontId,
	Description,
	Size,
	Color,ShadowColor,
	FontFaceId,
	FontStyle
from tblFont
	inner join tblFontMap on tblFontMap.FontID = tblFont.ID
where
	tblFontMap.ConfigurationID = @configurationId

END

GO