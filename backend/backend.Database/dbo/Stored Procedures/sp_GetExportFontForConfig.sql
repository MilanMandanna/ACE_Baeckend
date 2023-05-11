GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontForConfig]
END
GO
CREATE PROC sp_GetExportFontForConfig
@configurationId INT
AS
BEGIN

select distinct
	tblFont.FontId,
	Description,
	Size,
	Color,ShadowColor,
	FontFaceId,
	FontStyle,
	PxSize,TextEffectId
from tblFont
	inner join tblFontMap on tblFontMap.FontID = tblFont.ID
where
	tblFontMap.ConfigurationID = @configurationId and tblFontMap.IsDeleted=0

END

GO