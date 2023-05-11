
DROP PROCEDURE IF EXISTS [dbo].[SP_GetMenus_UserId]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_GetMenus_UserId]
			@userId UNIQUEIDENTIFIER
			
AS
BEGIN
		--DECLARE @userId UNIQUEIDENTIFIER
		--SELECT @userId = Id FROM AspNetUsers WHERE UserName = @userName
		DROP TABLE IF EXISTS #TEMP_CLAIMS
		CREATE TABLE #TEMP_CLAIMS (ClaimID UNIQUEIDENTIFIER, Name NVARCHAR(max), Description NVARCHAR(max), Scope NVARCHAR(MAX))
		INSERT INTO #TEMP_CLAIMS EXEC SP_GetClaims_UserId @userId
		
		SELECT DISTINCT dbo.tblUserMenus.*, dbo.tblMenuClaims.AccessLevel FROM dbo.tblUserMenus 
		INNER JOIN dbo.tblMenuClaims ON dbo.tblUserMenus.MenuId = dbo.tblMenuClaims.MenuID 
		WHERE dbo.tblMenuClaims.ClaimID IN (SELECT ClaimID FROM #TEMP_CLAIMS)
END
GO


