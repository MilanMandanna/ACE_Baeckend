SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 06/13/2022
-- Description:	Procedure to get the file ID from tasks table based on configuration ID and tasktype ID
-- Sample EXEC [dbo].[SP_GetFileIDFromTaskID] '67','755DC050-137C-4BFB-BE7C-8BB0F1441224'
-- =============================================

IF OBJECT_ID('[dbo].[SP_GetFileIDFromTaskID]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_GetFileIDFromTaskID]
END
GO

CREATE PROCEDURE [dbo].[SP_GetFileIDFromTaskID]
	@configurationId INT,
	@taskId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT TOP 1 ID FROM tblTasks WHERE TaskTypeID = @taskId AND ConfigurationID = @configurationId ORDER BY DateStarted DESC
END
GO

