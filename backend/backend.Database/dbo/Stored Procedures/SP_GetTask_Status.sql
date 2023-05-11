
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Abhishek Mohan
-- Create date: 3/31/2023
-- Description:	get Task Details
--Sample: EXEC [dbo].[SP_GetTask_Status] 1,'en'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetTask_Status]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_GetTask_Status]
END
GO

CREATE PROCEDURE [dbo].[SP_GetTask_Status]
        @TaskTypeID NVARCHAR(Max),
		@userId NVARCHAR(Max)
		
       
AS

BEGIN
    select * from tblTasks where StartedByUserID =@userId and TaskTypeID =@TaskTypeID and TaskStatusID IN(1,2)
END
GO

