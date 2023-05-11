SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Prajna Hegde
-- Create date: 15/06/2022
-- Description:	deletes the build with given id, also unlocks the configuration if required
-- Sample EXEC [dbo].[SP_Build_Delete] 'ed8032dd-ad8f-42af-9895-c941a57993dd'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Build_Delete]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_Delete]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_Delete]
	@taskId UNIQUEIDENTIFIER
	AS
BEGIN
	
	UPDATE
	dbo.tblConfigurations
	SET Locked = 0
	WHERE dbo.tblConfigurations.ConfigurationID IN (SELECT ConfigurationID FROM dbo.tblTasks WHERE ID = @taskId)

	DELETE 
	FROM dbo.tblTasks
	WHERE ID = @taskId
	
END

GO