IF OBJECT_ID('[dbo].[SP_GetPendingTasks]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetPendingTasks]
END
GO

CREATE PROCEDURE [dbo].[SP_GetPendingTasks] 	
	 @ID  uniqueidentifier,	
	 @IDType nvarchar	 
AS
BEGIN
	DECLARE
		@sql   nvarchar(max)
		DECLARE @ReturnValue int
	BEGIN
	 
	 IF UPPER(@IDType) = 'USER'
		 BEGIN
			SELECT tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus FROM dbo.tblTasks WHERE 
			StartedByUserID = @ID 
			and TaskStatusID NOT IN (Select ID from dbo.tblTaskStatus where [Name] in ('Complete'));		
		 END
	 --ELSE IF UPPER(@IDType) = 'AIRCRAFT'
		--BEGIN
		--	SELECT *  FROM dbo.tblTasks INNER JOIN [tblTaskData ] 			
		--	WHERE 
		--	StartedByUserID = @ID 
		--	and TaskStatusID NOT IN (Select ID from dbo.tblTaskStatus where [Name] in ('Complete'));
		--END
	END	
END

GO