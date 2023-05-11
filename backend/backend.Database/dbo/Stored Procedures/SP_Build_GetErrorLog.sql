SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 04/03/2022
-- Description:	The procedure is used to get errors logs for given task
-- Sample EXEC [dbo].[SP_Build_GetErrorLog] 'ed8032dd-ad8f-42af-9895-c941a57993dd'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_GetErrorLog]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_GetErrorLog]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_GetErrorLog]
	@taskId UNIQUEIDENTIFIER
	AS
BEGIN
	
	SELECT
	CASE 
		WHEN tblTasks.DetailedStatus = 'Failed due to cancellation' THEN tblTasks.DetailedStatus
		WHEN tbltasks.ErrorLog is NULL THEN 'Build failed' ELSE tbltasks.ErrorLog END
	FROM tbltasks(nolock) WHERE ID = @taskId ORDER BY DateLastUpdated DESC
END

GO