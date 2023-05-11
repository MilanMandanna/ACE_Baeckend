
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Mohan Abhishek Padinarapurayil		
-- Create date: 5/24/2022
-- Description:	this query returns all the userroleclaims from the UserRoleClaims table based on the RoleID and ClamID given
--Sample EXEC:SP_GetUserRoleClaims 'D3CC19CD-F347-4FAE-A03C-31EA39478282','7C08EC0E-1916-4C61-B386-FB817FF4A8AE'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetUserRoleClaims]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetUserRoleClaims]
END
GO
CREATE PROCEDURE [dbo].[SP_GetUserRoleClaims]
			@roleId uniqueidentifier,
			@claimId uniqueidentifier
			
AS
BEGIN
		
		SELECT dbo.UserRoleClaims.*, dbo.UserClaims.Name FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID 
        WHERE dbo.UserRoleClaims.RoleID = @roleId AND dbo.UserRoleClaims.ClaimID = @claimId
END
GO
