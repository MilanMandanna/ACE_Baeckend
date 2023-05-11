
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/27/2022
-- Description:	this query will return total number of count from dbo.UserRoleAssignments table based on the RoleID,UserId ,and ClaimId given
--Sample EXEC:EXEC [dbo].[SP_GetUserRoleClaimsby_RoleclaimId] '5A99A6B6-B8A3-45D1-A6DF-FB6DA8F51EDE','68B6EEE4-9439-4FA2-ABF4-C597E63CA983','DC0D5974-1E1B-4EDF-B4AB-3C82F8D3B143'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetUserRoleClaimsby_RoleclaimId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetUserRoleClaimsby_RoleclaimId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetUserRoleClaimsby_RoleclaimId]
			@roleId  uniqueidentifier,
			@userId uniqueidentifier,
			@claimId uniqueidentifier
AS
BEGIN
		SELECT COUNT(*) FROM dbo.UserRoleAssignments INNER JOIN dbo.UserRoleClaims ON dbo.UserRoleAssignments.RoleID = dbo.UserRoleClaims.RoleID WHERE dbo.UserRoleAssignments.UserID = @userId AND dbo.UserRoleClaims.RoleID = @roleId AND dbo.UserRoleClaims.ClaimID = @claimId
		
END
GO