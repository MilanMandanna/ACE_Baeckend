SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 15/06/2022
-- Description:	marks the cancelled attribute as true for given task id
-- Sample EXEC [dbo].[SP_Build_Cancel] 'ed8032dd-ad8f-42af-9895-c941a57993dd'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_Cancel]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_Cancel]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_Cancel]
	@taskId UNIQUEIDENTIFIER
	AS
BEGIN
	
	UPDATE dbo.tblTasks SET Cancelled = 1 WHERE ID = @taskId
END

GO