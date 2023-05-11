
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Mohan Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	This query will return the roles based on userID
--Sample EXEC: SP_GetRolesByUserId '410D1BAA-B6E6-44EA-A230-D80E869905A1'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetRolesByUserId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetRolesByUserId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetRolesByUserId]
			@userId uniqueidentifier
			
AS
BEGIN
		
		SELECT * FROM dbo.UserRoles INNER JOIN dbo.UserRoleAssignments ON dbo.UserRoles.ID = dbo.UserRoleAssignments.RoleID WHERE dbo.UserRoleAssignments.UserID = @userId
END
GO
