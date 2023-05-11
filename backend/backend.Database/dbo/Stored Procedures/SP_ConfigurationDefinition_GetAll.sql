SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/12/2022
-- Description:	Get Configuration definition  information for given user
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetAll] '4dbed025-b15f-4760-b925-34076d13a10a'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetAll]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetAll]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetAll]
	@userId uniqueidentifier
AS
BEGIN
	SELECT DISTINCT * FROM
            (select 
           
            tblconfigurationdefinitions.*,

            case when  tblProducts.Name is not null then tblProducts.Name  
            when tblPlatforms.Name is not null then tblPlatforms.Name  
            when tblGlobals.Name is not null then tblGlobals.Name  
            end as Name,  

            case when  UserClaims.name = 'ManageProductConfiguration' then 'Product'  
            when  UserClaims.name = 'ManagePlatformConfiguration' then 'Platform' 
            when UserClaims.name = 'Manage Global Configuration' then 'Global' 
            end as ConfigurationDefinitionType,

			case when  tblFeatureSet.value like 'true' then 1
            when  tblFeatureSet.value like 'false' then 0 
            end as Editable 

            from(aspnetusers 
            inner join UserRoleAssignments on UserRoleAssignments.userid = aspnetusers.id 
            inner join UserRoleClaims on UserRoleClaims.roleid = UserRoleAssignments.roleid 
            inner join UserClaims on UserClaims.id = UserRoleClaims.claimid 
            inner join tblconfigurationdefinitions on tblconfigurationdefinitions.ConfigurationDefinitionID = UserRoleClaims.ConfigurationDefinitionID or UserRoleClaims.ConfigurationDefinitionID is null and tblconfigurationdefinitions.active = 1
			INNER JOIN tblFeatureSet on tblFeatureSet.FeatureSetID = tblConfigurationDefinitions.FeatureSetID ) 
            LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManageProductConfiguration' 

            LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 

            LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'ManagePlatformConfiguration' 
            LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 

            LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID and UserClaims.name = 'Manage Global Configuration' 
            LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

            where 
            UserClaims.name in ('ManagePlatformConfiguration', 'ManageProductConfiguration', 'Manage Global Configuration') and tblFeatureSet.name like '%IsEditable%'
            and aspnetusers.Id = @userId) as A WHERE A.Name is not null
END
GO