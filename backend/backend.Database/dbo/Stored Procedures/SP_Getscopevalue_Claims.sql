
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padinarapurayil
-- Create date: 5/25/2022
--description : This query will return the particular UserRoleClaimID that is passed as a parameter based on the roleId and ClaimID
--Sample EXEC:   EXEC [dbo].[SP_Getscopevalue_Claims] 'D3CC19CD-F347-4FAE-A03C-31EA39478282','7C08EC0E-1916-4C61-B386-FB817FF4A8AE','AircraftID'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Getscopevalue_Claims]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_Getscopevalue_Claims]
END
GO
CREATE PROCEDURE [dbo].[SP_Getscopevalue_Claims]
			@roleId  uniqueidentifier,
			@claimId uniqueidentifier,
			@param NVARCHAR(300)
			
AS
BEGIN
		DECLARE @sql NVARCHAR(MAX)
		IF(@param ='AircraftID')
		BEGIN
		SELECT dbo.UserRoleClaims.AircraftID FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID  
        WHERE dbo.UserRoleClaims.RoleID =@roleId AND dbo.UserRoleClaims.ClaimID =@claimId
		END
		ELSE IF(@param ='OperatorID')
		BEGIN
		SELECT dbo.UserRoleClaims.OperatorID FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID  
        WHERE dbo.UserRoleClaims.RoleID =@roleId AND dbo.UserRoleClaims.ClaimID =@claimId
		END
		ELSE IF(@param ='ConfigurationDefinitionID')
		BEGIN
		SELECT dbo.UserRoleClaims.ConfigurationDefinitionID FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID  
        WHERE dbo.UserRoleClaims.RoleID =@roleId AND dbo.UserRoleClaims.ClaimID =@claimId
		END
		ELSE IF(@param ='UserRoleID')
		BEGIN
		SELECT dbo.UserRoleClaims.UserRoleID FROM dbo.UserRoleClaims 
        left join dbo.UserClaims on UserClaims.ID = dbo.UserRoleClaims.ClaimID  
        WHERE dbo.UserRoleClaims.RoleID =@roleId AND dbo.UserRoleClaims.ClaimID =@claimId
		END
END
GO