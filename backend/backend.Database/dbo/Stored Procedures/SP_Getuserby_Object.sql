
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan,Abhishek Padinarapurayil
-- Create date: 5/24/2022
-- Description:	return number of rows based on the ObjectFieldname  and based on given objectID ,manageclaimID and ViewClaimID
--Sample EXEC:exec [dbo].[SP_Getuserby_Object] '71E1A0FD-091A-441C-AA29-21F811951AD3','7C08EC0E-1916-4C61-B386-FB817FF4A8AE','7C08EC0E-1916-4C61-B386-FB817FF4A8AE','AircraftID'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Getuserby_Object]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_Getuserby_Object]
END
GO
CREATE PROCEDURE [dbo].[SP_Getuserby_Object]
			@objectID  uniqueidentifier,
			@manageClaimId uniqueidentifier,
			@viewClaimId uniqueidentifier,
			 @objectIDFieldName NVARCHAR(300)
AS
BEGIN
		DECLARE @sql NVARCHAR(MAX)
		DECLARE @params NVARCHAR(4000) = '@manageClaimId VARCHAR(255), @viewClaimId VARCHAR(255),@objectID VARCHAR(255)'
		SET  @sql =' SELECT DISTINCT dbo.AspNetUsers.ID, dbo.AspNetUsers.DateCreated ,dbo.AspNetUsers.DateModified, dbo.AspNetUsers.Fax, dbo.AspNetUsers.FirstName,    dbo.AspNetUsers.IsDeleted, dbo.AspNetUsers.IsPasswordChangeRequired, dbo.AspNetUsers.IsRememberMe, dbo.AspNetUsers.IsSubscribedForNewsLetter, dbo.AspNetUsers.IsSystemuser, dbo.AspNetUsers.LastName, dbo.AspNetUsers.Company, dbo.AspNetUsers.LastResetDate, dbo.AspNetUsers.ModifiedBy, dbo.AspNetUsers.ResetToken, dbo.AspNetUsers.ResetTokenExpirationTime, dbo.AspNetUsers.SelectedOperatorId, dbo.AspNetUsers.Email, dbo.AspNetUsers.EmailConfirmed, dbo.AspNetUsers.PasswordHash, dbo.AspNetUsers.SecurityStamp, dbo.AspNetUsers.PhoneNumber,dbo.AspNetUsers.PhoneNumberConfirmed, dbo.AspNetUsers.TwoFactorEnabled, dbo.AspNetUsers.LockoutEndDateUtc, dbo.AspNetUsers.LockoutEnabled, dbo.AspNetUsers.AccessFailedCount, dbo.AspNetUsers.UserName FROM (dbo.AspNetUsers INNER JOIN dbo.UserRoleAssignments ON dbo.AspNetUsers.Id = dbo.UserRoleAssignments.UserID) 
              INNER JOIN dbo.UserRoleClaims ON dbo.UserRoleAssignments.RoleID = dbo.UserRoleClaims.RoleID  
               WHERE (dbo.UserRoleClaims.ClaimID = @manageClaimId  OR dbo.UserRoleClaims.ClaimID =@viewClaimId )
               AND (dbo.UserRoleClaims.'+ @objectIDFieldName + ' =@objectID OR dbo.UserRoleClaims.' + @objectIDFieldName + ' IS NULL) AND (dbo.AspNetUsers.IsDeleted = 0)'
        --print @sql
        EXEC sys.Sp_executesql @sql ,@params,@manageClaimId = @manageClaimId,@viewClaimId = @viewClaimId,@objectID=@objectID

END
GO