IF OBJECT_ID('[dbo].[SP_UpdateTask]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_UpdateTask]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateTask] 	
	 @TaskId  uniqueidentifier,		
	 @TaskStatusId  int,
	 @PercentageComplete float,
	 @DetailedStatus  nvarchar	 
AS
BEGIN
	DECLARE
		@LASTID   uniqueidentifier
		DECLARE @ReturnValue int
	BEGIN		
		SET @ReturnValue = 1;
		 Update [dbo].[tblTasks] SET TaskStatusID = @TaskStatusId
           ,DateLastUpdated = GETDATE(),PercentageComplete = @PercentageComplete,DetailedStatus = @DetailedStatus
				WHERE ID = @TaskId	  
		 select tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus from tblTasks where tblTasks.ID = @TaskId;
		  return @ReturnValue
	END	
END

GO