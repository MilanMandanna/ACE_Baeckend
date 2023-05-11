
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Mohan Abhishek Padinarapurayil		
-- Create date: 5/24/2022
-- Description:	This query returns the number of count from UserRoleClaims table based on the claimID and roleID
--Sample EXEC :SP_GetClaimsCountByRoleId 'D3CC19CD-F347-4FAE-A03C-31EA39478282','C9F1DD7A-C408-47F3-9DF1-4395B4C903B6'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetClaimsCountByRoleId]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetClaimsCountByRoleId]
END
GO
CREATE PROCEDURE [dbo].[SP_GetClaimsCountByRoleId]
			@roleId uniqueidentifier,
			@claimId uniqueidentifier
			
AS
BEGIN
		
		SELECT count(*) FROM dbo.UserRoleClaims WHERE RoleID = @roleId AND ClaimID = @claimId
END
GO
