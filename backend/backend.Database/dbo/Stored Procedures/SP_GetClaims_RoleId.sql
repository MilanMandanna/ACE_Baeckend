
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padniarapurayil
-- Create date: 5/24/2022
--Description :this query returns multiple colums from dbo.UserRoles based on RoleID given
--Sample EXEC: exec [dbo].[SP_GetClaims_RoleId] '383D4F04-8F3A-408B-BF52-05EFF3674BDB'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetClaims_RoleId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetClaims_RoleId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetClaims_RoleId]
			@roleId  uniqueidentifier
			
AS
BEGIN
		
		SELECT dbo.UserClaims.ID, dbo.UserClaims.Name, dbo.UserClaims.Description, dbo.UserClaims.ScopeType FROM dbo.UserRoles INNER JOIN dbo.UserRoleClaims ON dbo.UserRoles.ID = dbo.UserRoleClaims.RoleID INNER JOIN dbo.UserClaims ON dbo.UserRoleClaims.ClaimID = dbo.UserClaims.ID WHERE dbo.UserRoles.ID = @roleId
		
END
GO
