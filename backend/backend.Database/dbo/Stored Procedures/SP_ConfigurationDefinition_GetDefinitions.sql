SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Get all Configuration definition information for given definition type
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetDefinitions] 'products'
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetDefinitions]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetDefinitions]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetDefinitions]
	@definitionType VARCHAR(Max)
AS
BEGIN
	IF(@definitionType = 'products')
	BEGIN
        SELECT Configuration.*
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblProductConfigurationMapping AS Product ON Product.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblProducts AS Products on Products.ProductID = Product.ProductID;
    END
    ELSE IF (@definitionType = 'platforms')
    BEGIN
        SELECT Configuration.* 
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblPlatformConfigurationMapping AS Platform ON Platform.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblPlatforms AS Platforms on Platforms.PlatformID = Platform.PlatformID;
    END
    ELSE IF(@definitionType = 'global')
    BEGIN
        SELECT Configuration.*
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblGlobalConfigurationMapping AS Global ON Global.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblGlobals AS Globals on Globals.GlobalID = Global.GlobalID;
    END
END
GO