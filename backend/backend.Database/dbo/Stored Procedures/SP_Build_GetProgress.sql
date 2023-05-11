SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 15/06/2022
-- Description:	returns progress and task id for given list of task ids(comma seperated string)
-- Sample EXEC [dbo].[SP_Build_GetProgress] "893252a8-c80d-41ee-81fc-11c5b477d778,47285d00-1bef-449c-b890-b3d3da4dab84"
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_GetProgress]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_GetProgress]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_GetProgress]
	@taskIds VARCHAR(MAX)
	AS
BEGIN
	
	DECLARE @temp TABLE(taskId UNIQUEIDENTIFIER)
	INSERT INTO @temp SELECT * FROM STRING_SPLIT(@taskIds, ',')

	SELECT dbo.tblTasks.ID, dbo.tbltasks.PercentageComplete, dbo.tblTasks.DetailedStatus, FORMAT(dbo.tblTasks.DateStarted, 'MM/dd/yyyy') AS DateStarted
	FROM dbo.tblTasks (nolock) WHERE dbo.tblTasks.ID IN (SELECT * FROM @temp)
	
	
	
END

GO