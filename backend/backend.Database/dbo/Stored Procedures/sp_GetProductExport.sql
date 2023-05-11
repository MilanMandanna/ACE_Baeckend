GO

-- =============================================
-- Author:		Logesh
-- Create date: 06-Feb-2023
-- =============================================
IF OBJECT_ID('[dbo].[sp_GetProductExport]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_GetProductExport]
END
GO
CREATE PROC sp_GetProductExport
@configurationId INT
AS
BEGIN

select 
  tblTasks.*,
  tblTaskType.Name
from tblTasks
  inner join tblTaskType on tblTaskType.ID = tblTasks.TaskTypeID
  inner join tblTaskStatus on tblTaskStatus.Id = tblTasks.TaskStatusID
where
  configurationId = @configurationID
  and tblTaskType.Name in ('Export Product Database - Thales', 'Export Product Database - PAC3D', 'Export Product Database - AS4XXX', 'Export Product Database - CESHTSE'
  ,'Venue Next','Venue Hybrid')
  and tblTaskStatus.Name not in ('Failed')

END

GO