SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Returns the list of operators associated with configuration definitions that the user has access to as determined by the claims associated with the given user
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetOperators] '4dbed025-b15f-4760-b925-34076d13a10a'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetOperators]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetOperators]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetOperators]
	@userId UNIQUEIDENTIFIER,
	@configurationDefinitionID INT,
	@operatorType NVARCHAR(255)

AS
BEGIN
	IF(@operatorType = 'global')
	BEGIN
	select  

    distinct operator.*  

    from aspnetusers  
    inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id  
    inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid  
    inner join UserClaims on UserClaims.id = UserRoleClaims.claimid  


    inner join operator on operator.id = UserRoleClaims.operatorid or UserRoleClaims.operatorid is null  
    inner join aircraft on aircraft.operatorid = operator.id  
    inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id  
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1  

    where  
    UserClaims.name in ('Manage Operator', 'View Operator', 'Administer Operator')  
        and  
        aspnetusers.Id =  @userId  

        UNION  

    select  
    distinct operator.*  

    from aspnetusers  
    inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id  
    inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid  
    inner join UserClaims on UserClaims.id = UserRoleClaims.claimid  


    inner join aircraft on aircraft.id = UserRoleClaims.aircraftid or UserRoleClaims.aircraftid is null  
    inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id  
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1  
    inner join operator on aircraft.operatorid = operator.id  

    where  
    UserClaims.name in ('Manage Aircraft', 'Administer Aircraft')  and  aspnetusers.Id =  @userId;
	END
	ELSE IF(@operatorType ='platform')
	BEGIN
	select  

    distinct operator.*  

    from aspnetusers  
    inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id  
    inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid  
    inner join UserClaims on UserClaims.id = UserRoleClaims.claimid  


    inner join operator on operator.id = UserRoleClaims.operatorid or UserRoleClaims.operatorid is null  
    inner join aircraft on aircraft.operatorid = operator.id  
    inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id  
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1  

    where  
    UserClaims.name in ('Manage Operator', 'View Operator', 'Administer Operator')  
        and  
        aspnetusers.Id =  @userId  and tblConfigurationDefinitions.ConfigurationDefinitionParentID =@configurationdefinitionID

        UNION  

    select  
    distinct operator.* 

    from aspnetusers  
    inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id  
    inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid  
    inner join UserClaims on UserClaims.id = UserRoleClaims.claimid  


    inner join aircraft on aircraft.id = UserRoleClaims.aircraftid or UserRoleClaims.aircraftid is null  
    inner join tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.aircraftid = aircraft.id  
    inner join tblconfigurationdefinitions on tblConfigurationDefinitions.ConfigurationDefinitionID = tblAircraftConfigurationMapping.ConfigurationDefinitionID and tblconfigurationdefinitions.active = 1  
    inner join operator on aircraft.operatorid = operator.id  

    where  
    UserClaims.name in ('Manage Aircraft', 'Administer Aircraft')  and  aspnetusers.Id =  @userId and tblConfigurationDefinitions.ConfigurationDefinitionParentID =@configurationdefinitionID
	END

END
GO