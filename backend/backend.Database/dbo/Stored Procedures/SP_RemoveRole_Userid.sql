
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	deletes the record from userRoleAssignments based on userID ,and roleid
--Sample EXEC: exec [dbo].[SP_RemoveRole_Userid] '3CD9AEB9-564F-41A4-AC03-00EF897F29F7','3A638B85-7F31-4E6A-BFA1-40C6003AC404','3A638B85-7F31-4E6A-BFA1-40C6003AC404'
-- ===========================================
IF OBJECT_ID('[dbo].[SP_RemoveRole_Userid]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_RemoveRole_Userid]
END
GO
CREATE PROCEDURE [dbo].[SP_RemoveRole_Userid]
			@userId  uniqueidentifier,
			@manageRoleId uniqueidentifier,
			@viewRoleId uniqueidentifier
			
AS
BEGIN
		
		DELETE FROM dbo.UserRoleAssignments WHERE dbo.UserRoleAssignments.UserID = @userId AND (dbo.UserRoleAssignments.RoleID = @manageRoleId OR dbo.UserRoleAssignments.RoleID = @viewRoleId)
		
END
GO