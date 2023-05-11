GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGContentForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGContentForConfig]
END
GO
CREATE PROC sp_GetExportWGContentForConfig
@configurationId INT
AS
BEGIN

select
	tblWgContent.WGContentId,
	GeoRefId,
	TypeId,
	ImageId,
	TExtId
from tblWGContent
	inner join tblWGContentMap on tblWGContentMap.WGContentID = tblwgcontent.WGContentID
where
	tblWGContentMap.ConfigurationID = @configurationId

END

GO