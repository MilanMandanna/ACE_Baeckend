IF OBJECT_ID('[dbo].[SP_CreateTask]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_CreateTask]
END
GO

CREATE   PROCEDURE [dbo].[SP_CreateTask] 	
	 @TaskTypeId  uniqueidentifier,	
	 @UserId  uniqueidentifier,
	 @TaskStatusId  int,
	 @DetailedStatus  nvarchar(500),
	 @AzureBuildId int
AS
BEGIN
	DECLARE
		@LASTID   uniqueidentifier
		DECLARE @ReturnValue int
	BEGIN
		BEGIN TRANSACTION
			SET @LASTID = NEWID();
			SET @ReturnValue = 1;

		INSERT INTO [dbo].[tblTasks] (ID, TaskTypeID,StartedByUserID,TaskStatusID
			   ,DateStarted,DateLastUpdated,PercentageComplete,DetailedStatus
			   ,AzureBuildID)
		 VALUES
			   (@LASTID, @TaskTypeId, @UserId ,@TaskStatusId, GETDATE()
			   , GETDATE(),0.2,@DetailedStatus,@AzureBuildId)	;
		 

		select tblTasks.ID, tblTasks.TaskStatusID, tblTasks.DetailedStatus from tblTasks where tblTasks.ID = @LASTID;		
		COMMIT	
	END		
END

GO