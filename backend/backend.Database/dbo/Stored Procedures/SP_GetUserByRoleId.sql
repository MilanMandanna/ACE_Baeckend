
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Mohan Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	this query selects the number of rows from aspNetUsers based on the condition and roleID
--Sample EXEC: exec [dbo].[SP_GetUserByRoleId] '512661BD-A474-4BE5-942A-401FEAE04A65'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetUserByRoleId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetUserByRoleId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetUserByRoleId]
			@roleId uniqueidentifier
			
AS
BEGIN
		
		SELECT * FROM dbo.AspNetUsers INNER JOIN dbo.UserRoleAssignments ON dbo.AspNetUsers.Id = dbo.UserRoleAssignments.UserID WHERE dbo.UserRoleAssignments.RoleID = @roleId
		
END
GO
