
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Mohan Abhishek Padinarapuaryil
-- Create date: <29/5/2022>
-- Description:	this query returns only the distinct value based on userId
--Sample EXEC:exec [dbo].[SP_GetClaims_UserId] 'EE35E2A0-0ED7-4575-AA95-12B0000E7AC5'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetClaims_UserId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetClaims_UserId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetClaims_UserId]
			@userId  uniqueidentifier
			
AS
BEGIN
		
		SELECT DISTINCT dbo.UserClaims.ID, dbo.UserClaims.Name, dbo.UserClaims.Description, dbo.UserClaims.ScopeType FROM (dbo.UserRoleAssignments INNER JOIN dbo.UserRoleClaims ON dbo.UserRoleAssignments.RoleID = dbo.UserRoleClaims.RoleID) INNER JOIN dbo.UserClaims ON dbo.UserRoleClaims.ClaimID = dbo.UserClaims.ID WHERE dbo.UserRoleAssignments.UserID = @userId
END
GO