
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		< Mohan ,Abhishek Padinarapurayil>
-- Create date: 28/6/2022
-- Description: this query count the number of records from UserRoleAssignments based on the userID and RoleID given
--Sample EXEC: SP_GetCountbyuser_RoleId '3CD9AEB9-564F-41A4-AC03-00EF897F29F7','3A638B85-7F31-4E6A-BFA1-40C6003AC404'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetCountbyuser_RoleId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetCountbyuser_RoleId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetCountbyuser_RoleId]
			@userId  uniqueidentifier,
			@roleId  uniqueidentifier
			
AS
BEGIN
		
		 SELECT COUNT(*) FROM dbo.UserRoleAssignments WHERE dbo.UserRoleAssignments.UserID = @userId AND dbo.UserRoleAssignments.RoleID = @roleId
		
END
GO