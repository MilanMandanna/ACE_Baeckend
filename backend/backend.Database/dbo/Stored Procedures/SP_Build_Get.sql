
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 09/06/2022
-- Description:	Returns list of all/in progress  builds for the given user
-- EXEC dbo.SP_Build_Get '4dbed025-b15f-4760-b925-34076d13a10a','all'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Build_Get]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Build_Get]
END
GO

CREATE PROCEDURE [dbo].[SP_Build_Get]
	@userId UNIQUEIDENTIFIER,
    @type VARCHAR(MAX)
AS
BEGIN

    IF (@type = 'all')
    BEGIN

        SELECT dbo.tblTasks.ID ,
        dbo.tblTaskStatus.Name as BuildStatus, 
        dbo.tblTasks.PercentageComplete ,
        case
            when  tblProducts.Name is not null then tblProducts.Name    
            when tblPlatforms.Name is not null then tblPlatforms.Name    
            when tblGlobals.Name is not null then tblGlobals.Name
            when Aircraft.Id is not null then Aircraft.TailNumber   
        end as DefinitionName,
        dbo.tblTasks.DateStarted,
        dbo.tblConfigurations.Version as ConfigurationVersion,
        dbo.tblConfigurations.ConfigurationID,
        dbo.tblConfigurations.ConfigurationDefinitionID,
		dbo.tblTaskType.Name AS TaskTypeName


        FROM (((((((((((dbo.tblTasks (nolock)

        INNER JOIN dbo.tblTaskStatus ON dbo.tblTaskStatus.ID = dbo.tblTasks.TaskStatusID )
        INNER JOIN dbo.tblTaskType ON dbo.tblTasks.TaskTypeID = dbo.tblTaskType.ID AND dbo.tblTaskType.ShouldShowInBuildDashboard = 1)
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationID =  dbo.tblTasks.ConfigurationID)

        LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID )
        LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID)   

        LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID)   

        LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID)   

        LEFT OUTER JOIN tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID)
        LEFT OUTER JOIN Aircraft ON Aircraft.Id = tblAircraftConfigurationMapping.AircraftID)

        WHERE 
        dbo.tblTasks.ConfigurationDefinitionID <> 1 AND( dbo.tblTasks.StartedByUserID = @userId  
        OR dbo.tblTasks.ConfigurationID IN ( 
   
           select distinct tblConfigurations.ConfigurationID
         
           from(aspnetusers 
           inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id 
           inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid 
           inner join UserClaims on UserClaims.id = UserRoleClaims.claimid 
           inner join tblconfigurationdefinitions on tblconfigurationdefinitions.ConfigurationDefinitionID = UserRoleClaims.ConfigurationDefinitionID or UserRoleClaims.ConfigurationDefinitionID is null and tblconfigurationdefinitions.active = 1 
           inner join tblConfigurations on tblconfigurationdefinitions.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID ) 
 
           LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManageProductConfiguration' 

           LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 

           LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManagePlatformConfiguration' 
           LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 

           LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'Manage Global Configuration' 
           LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

           where 
           UserClaims.name in ('ManagePlatformConfiguration', 'ManageProductConfiguration', 'Manage Global Configuration') 
           and aspnetusers.Id = @userId
		   ))order by dbo.tblProducts.Name, dbo.tblPlatforms.Name, dbo.Aircraft.TailNumber
 
 

    END
    ELSE
    BEGIN

        SELECT dbo.tblTasks.ID ,
        dbo.tblTaskStatus.Name as BuildStatus, 
        dbo.tblTasks.PercentageComplete ,
        case
            when  tblProducts.Name is not null then tblProducts.Name    
            when tblPlatforms.Name is not null then tblPlatforms.Name    
            when tblGlobals.Name is not null then tblGlobals.Name
            when Aircraft.Id is not null then Aircraft.TailNumber   
        end as DefinitionName,
        dbo.tblTasks.DateStarted,
        dbo.tblConfigurations.Version as ConfigurationVersion,
        dbo.tblConfigurations.ConfigurationID,
        dbo.tblConfigurations.ConfigurationDefinitionID,
		dbo.tblTaskType.Name AS TaskTypeName
        FROM (((((((((((dbo.tblTasks(nolock)

        INNER JOIN dbo.tblTaskStatus ON dbo.tblTaskStatus.ID = dbo.tblTasks.TaskStatusID AND (dbo.tblTaskStatus.Name = 'In Progress' OR dbo.tblTaskStatus.Name = 'Not Started'))
        INNER JOIN dbo.tblTaskType ON dbo.tblTasks.TaskTypeID = dbo.tblTaskType.ID AND dbo.tblTaskType.ShouldShowInBuildDashboard = 1)
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationID =  dbo.tblTasks.ConfigurationID)

        LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID )
        LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID)   

        LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID)   

        LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID)   

        LEFT OUTER JOIN tblAircraftConfigurationMapping on tblAircraftConfigurationMapping.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID)
        LEFT OUTER JOIN Aircraft ON Aircraft.Id = tblAircraftConfigurationMapping.AircraftID)

        WHERE 
        dbo.tblTasks.ConfigurationDefinitionID <> 1 AND(dbo.tblTasks.StartedByUserID = @userId  
        OR dbo.tblTasks.ConfigurationID IN ( 
   
           select distinct tblConfigurations.ConfigurationID
         
           from(aspnetusers 
           inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id 
           inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid 
           inner join UserClaims on UserClaims.id = UserRoleClaims.claimid 
           inner join tblconfigurationdefinitions on tblconfigurationdefinitions.ConfigurationDefinitionID = UserRoleClaims.ConfigurationDefinitionID or UserRoleClaims.ConfigurationDefinitionID is null and tblconfigurationdefinitions.active = 1 
           inner join tblConfigurations on tblconfigurationdefinitions.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID ) 
 
           LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManageProductConfiguration' 

           LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 

           LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManagePlatformConfiguration' 
           LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 

           LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'Manage Global Configuration' 
           LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

           where 
           UserClaims.name in ('ManagePlatformConfiguration', 'ManageProductConfiguration', 'Manage Global Configuration') 
           and aspnetusers.Id = @userId
		   ))
 

    END


END

GO