GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetExportScreenSizeForConfig]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetExportScreenSizeForConfig]
END
GO
CREATE PROC sp_GetExportScreenSizeForConfig 
@configurationId INT
AS
BEGIN

select 
	tblScreenSize.ScreenSizeID as id,
	Description as description
from tblScreenSize
	inner join tblScreenSizeMap on tblScreenSizeMap.ScreenSizeID = tblScreenSize.ScreenSizeID
where
	tblScreenSizeMap.ConfigurationID = @configurationId

END

GO