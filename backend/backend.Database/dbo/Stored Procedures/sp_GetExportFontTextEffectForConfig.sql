GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontTextEffectForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontTextEffectForConfig]
END
GO
CREATE PROC sp_GetExportFontTextEffectForConfig
@configurationId INT
AS
BEGIN

select
	tblFontTextEffect.FontTextEffectID AS TextEffectId,
	Name
from tblFontTextEffect
	inner join tblFontTextEffectMap on tblFontTextEffectMap.FontTextEffectID = tblFontTextEffect.FontTextEffectID
where
	tblFontTextEffectMap.ConfigurationID = @configurationId

END

GO