
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padinarapurayil
-- Create date: 5/25/2022
-- Description:	This will select the scoptype that is sent as a parameter  based on the userId and ClaimID
--Sample EXEC: EXEC SP_GetScopeValueForUserinput '4dbed025-b15f-4760-b925-34076d13a10a', '65faa542-665b-41ff-8cda-b2fa05b41176'
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetScopeValueForUserinput]','P') IS NOT NULL

BEGIN

DROP PROC [dbo].[SP_GetScopeValueForUserinput]
END
GO
CREATE PROCEDURE [dbo].[SP_GetScopeValueForUserinput]
   @userId uniqueidentifier,
   @claimId uniqueidentifier

AS
BEGIN
  SELECT dbo.UserRoleClaims.OperatorID FROM dbo.UserRoleClaims
         INNER JOIN dbo.UserRoleAssignments on UserRoleClaims.RoleID = dbo.UserRoleAssignments.RoleID
         AND dbo.UserRoleClaims.ClaimID =@claimId AND dbo.UserRoleAssignments.UserID =@userId 

END

GO