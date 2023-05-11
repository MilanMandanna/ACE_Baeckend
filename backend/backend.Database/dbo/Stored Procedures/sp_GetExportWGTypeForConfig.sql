GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportWGTypeForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportWGTypeForConfig]
END
GO
CREATE PROC sp_GetExportWGTypeForConfig
@configurationId INT
AS
BEGIN

select 
	TypeId,
	Description,
	Layout,
	ImageWidth,
	ImageHeight
from tblwgtype
	inner join tblWGTypeMap on tblwgtypemap.WGTypeID = tblwgtype.WGTypeID
where
	tblwgtypemap.ConfigurationID = @configurationId
order by TypeId

END

GO