GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontTextEffectForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontTextEffectForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontTextEffectForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	Name
from tblFontTextEffect
	inner join tblFontTextEffectMap on tblFontTextEffectMap.FontTextEffectID = tblFontTextEffect.FontTextEffectID
where
	tblFontTextEffectMap.ConfigurationID = @configurationId

END

GO