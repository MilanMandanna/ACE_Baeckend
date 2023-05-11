
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- SAMPLE:[dbo].[SP_GetRoleClaim_Mapuser] '1A374C06-6B00-4853-86B1-7551534D6130','410D1BAA-B6E6-44EA-A230-D80E869905A1','DC0D5974-1E1B-4EDF-B4AB-3C82F8D3B143'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetRoleClaim_Mapuser]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetRoleClaim_Mapuser]
END
GO
CREATE PROCEDURE [dbo].[SP_GetRoleClaim_Mapuser]
			@roleId uniqueidentifier,
			@userId uniqueidentifier,
			@claimId uniqueidentifier
			
AS
BEGIN
		SELECT COUNT(*) FROM dbo.UserRoleAssignments INNER JOIN dbo.UserRoleClaims ON dbo.UserRoleAssignments.RoleID = dbo.UserRoleClaims.RoleID WHERE dbo.UserRoleAssignments.UserID = @userId AND dbo.UserRoleClaims.RoleID = @roleId AND dbo.UserRoleClaims.ClaimID = @claimId
END
GO
