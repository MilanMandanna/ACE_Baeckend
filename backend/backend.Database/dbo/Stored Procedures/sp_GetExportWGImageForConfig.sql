GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGImageForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGImageForConfig]
END
GO
CREATE PROC sp_GetExportWGImageForConfig
@configurationId INT
AS
BEGIN

select
  -1 as ImageId,
  null as Filename
union
select
	tblwgImage.ImageId,
	Filename
from tblwgimage
	inner join tblwgimagemap on tblwgimagemap.ImageID = tblwgimage.ImageID
where
	tblwgimagemap.ConfigurationID = @configurationId

END

GO