
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mohan Abhishek Padinarapurayil
-- Create date: 5/26/2022
-- =============================================
IF OBJECT_ID('[dbo].[SP_GetBuildTasks]','P') IS NOT NULL
BEGIN
		DROP PROC [dbo].[SP_GetBuildTasks]
END
GO
CREATE PROCEDURE [dbo].[SP_GetBuildTasks]
			@userId  uniqueidentifier	
AS
BEGIN
		SELECT dbo.tblTasks.ID ,
        dbo.tblTaskStatus.Name as BuildStatus, 
        dbo.tblTasks.PercentageComplete ,
        case when  tblProducts.Name is not null then tblProducts.Name    
        when tblPlatforms.Name is not null then tblPlatforms.Name    
        when tblGlobals.Name is not null then tblGlobals.Name    
        end as DefiniationName,
        dbo.tblConfigurations.Version as ConfigurationVersion,
        dbo.tblConfigurations.ConfigurationID 
		FROM ((((((((dbo.tblTasks
        INNER JOIN dbo.tblTaskStatus ON dbo.tblTaskStatus.ID = dbo.tblTasks.TaskStatusID)
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationID =  dbo.tblTasks.ConfigurationID)
        LEFT OUTER JOIN tblProductConfigurationMapping ON tblProductConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID )
        LEFT OUTER JOIN dbo.tblProducts ON tblProducts.ProductID = tblProductConfigurationMapping.ProductID)   
        LEFT OUTER JOIN tblPlatformConfigurationMapping ON tblPlatformConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblPlatforms ON tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID)   
        LEFT OUTER JOIN tblGlobalConfigurationMapping ON tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblTasks.ConfigurationDefinitionID)
        LEFT OUTER JOIN dbo.tblGlobals ON tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID)   
        WHERE dbo.tblTasks.StartedByUserID = @userId OR (dbo.tblTasks.ConfigurationID IN ( 
        select distinct tblConfigurations.ConfigurationID 
           from(aspnetusers 
           INNER JOIN UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id 
           INNER JOIN UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid 
           INNER JOIN UserClaims on UserClaims.id = UserRoleClaims.claimid 
           INNER JOIN tblconfigurationdefinitions on tblconfigurationdefinitions.ConfigurationDefinitionID = UserRoleClaims.ConfigurationDefinitionID or UserRoleClaims.ConfigurationDefinitionID is null and tblconfigurationdefinitions.active = 1 
           INNER JOIN tblConfigurations on tblconfigurationdefinitions.ConfigurationDefinitionID = tblConfigurations.ConfigurationDefinitionID ) 
           LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManageProductConfiguration' 
           LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 
           LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManagePlatformConfiguration' 
           LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 
           LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'Manage Global Configuration' 
           LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 
           where 
           UserClaims.name in ('ManagePlatformConfiguration', 'ManageProductConfiguration', 'Manage Global Configuration') 
           and aspnetusers.Id = @userId) )
END
GO
