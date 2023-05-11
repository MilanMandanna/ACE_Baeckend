-- =============================================
-- Author:		Sathya
-- Create date: 06/24/2022
-- Description:	Update the task status by its id to give status id with percentage completion.
-- =============================================

GO
IF OBJECT_ID('[dbo].[SP_updateTaskStatus]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_updateTaskStatus]
END
GO

CREATE PROC SP_updateTaskStatus  
@taskId UNIQUEIDENTIFIER, 
@percentage FLOAT,
@taskStatus INT
AS  
BEGIN  
  
  UPDATE tblTasks SET TaskStatusID=@taskStatus,PercentageComplete=@percentage, DateLastUpdated=GETDATE() WHERE ID=@taskId;  
  
END

GO