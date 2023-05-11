GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportFontMarkerForConfigPAC3D]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportFontMarkerForConfigPAC3D]
END
GO
CREATE PROC sp_GetExportFontMarkerForConfigPAC3D
@configurationId INT
AS
BEGIN

select
	MarkerId,
	Filename
from tblFontMarker
	inner join tblFontMarkerMap on tblFontMarkerMap.FontMarkerID = tblFontMarker.FontMarkerID
where
	tblFontMarkerMap.ConfigurationID = @configurationId

END

GO