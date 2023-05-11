
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padniarapurayil
-- Create date: 28/5/2022
-- Description:	this will select the userRoleClaims from UserRoleclaims table based on the userID that is passed
--Sample EXEC:[dbo].[SP_GetClaimsforuser_Aircraftconfig] '4DBED025-B15F-4760-B925-34076D13A10A'

-- =============================================
IF OBJECT_ID('[dbo].[SP_GetClaimsforuser_Aircraftconfig]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetClaimsforuser_Aircraftconfig]
END
GO
CREATE PROCEDURE [dbo].[SP_GetClaimsforuser_Aircraftconfig]
			@userId  uniqueidentifier	
AS
BEGIN

		SELECT dbo.UserRoleClaims.* FROM dbo.UserRoleClaims
        INNER JOIN dbo.UserRoleAssignments on UserRoleClaims.RoleID = dbo.UserRoleAssignments.RoleID
        inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = dbo.UserRoleClaims.AircraftID
        inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID 
        and tblconfigurationdefinitions.active = 1 AND dbo.UserRoleAssignments.UserID = @userId
END
GO
