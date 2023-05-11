using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryExport
    {

        public static string SQL_GetProductExport = @"
select 
  tblTasks.*,
  tblTaskType.Name
from tblTasks
  inner join tblTaskType on tblTaskType.ID = tblTasks.TaskTypeID
  inner join tblTaskStatus on tblTaskStatus.Id = tblTasks.TaskStatusID
where
  configurationId = @configurationID
  and tblTaskType.Name in ('Export Product Database - Thales', 'Export Product Database - PAC3D', 'Export Product Database - AS4XXX', 'Export Product Database - CESHTSE')
  and tblTaskStatus.Name not in ('Failed')";

        public static string SQL_GetLatestConfiguration = @"
select 
  tblConfigurations.*
from tblConfigurations
where configurationid = (
  select
    max(configurationid)
  from tblConfigurations
  where
    ConfigurationDefinitionID = @configurationDefinitionId
)";

        public static string SQL_GetBuildTasksForUser = @"SELECT dbo.tblTasks.ID ,
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

LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID )
LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID)   

LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID =  dbo.tblTasks.ConfigurationDefinitionID)
LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID)   

LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblTasks.ConfigurationDefinitionID)
LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID)   


WHERE dbo.tblTasks.StartedByUserID = @userId OR (dbo.tblTasks.ConfigurationID IN ( 
   
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
           and aspnetusers.Id = @userId) 
 
)";
    }


}
