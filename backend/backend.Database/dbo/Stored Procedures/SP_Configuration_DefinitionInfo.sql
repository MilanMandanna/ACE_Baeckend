SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Returns configuration definition info for the given configuration id
-- Sample EXEC [dbo].[SP_Configuration_DefinitionInfo] 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_Configuration_DefinitionInfo]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Configuration_DefinitionInfo]
END
GO

CREATE PROCEDURE [dbo].[SP_Configuration_DefinitionInfo]
	@configurationId INT
AS
BEGIN
	SELECT 
    dbo.tblConfigurations.ConfigurationDefinitionID, 

    CASE 
    WHEN dbo.tblGlobals.GlobalID is not null then dbo.tblGlobals.GlobalID 
    WHEN dbo.tblProducts.ProductID is not null then dbo.tblProducts.ProductID 
    WHEN dbo.tblPlatforms.PlatformID is not null then dbo.tblPlatforms.PlatformID 
    END as ConfigurationDefinitionTypeID, 

    CASE 
    WHEN dbo.tblGlobals.GlobalID is not null then 'Global' 
    WHEN dbo.tblProducts.ProductID is not null then 'Product' 
    WHEN dbo.tblPlatforms.PlatformID is not null then 'Platform' 
    END as ConfigurationDefinitionType 

    FROM 
    dbo.tblConfigurations 

    LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurations.ConfigurationDefinitionID 
    LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

    LEFT OUTER JOIN tblProductConfigurationMapping on tblProductConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurations.ConfigurationDefinitionID 
    LEFT OUTER JOIN dbo.tblProducts on tblProducts.ProductID = tblProductConfigurationMapping.ProductID 

    LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurations.ConfigurationDefinitionID 
    LEFT OUTER JOIN dbo.tblPlatforms on tblPlatforms.PlatformID = tblPlatformConfigurationMapping.PlatformID 

    WHERE dbo.tblConfigurations.ConfigurationID = @configurationId;
END
GO