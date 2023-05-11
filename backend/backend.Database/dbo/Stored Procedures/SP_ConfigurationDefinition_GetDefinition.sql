SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/17/2022
-- Description:	Get all Configuration definition information for given definition type and id
-- Sample EXEC [dbo].[SP_ConfigurationDefinition_GetDefinition] 'product', 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_ConfigurationDefinition_GetDefinition]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_ConfigurationDefinition_GetDefinition]
END
GO

CREATE PROCEDURE [dbo].[SP_ConfigurationDefinition_GetDefinition]
	@definitionType VARCHAR(Max),
    @definitionId INT
AS
BEGIN
	IF(@definitionType = 'product')
	BEGIN
        SELECT Products.*,Configuration.ConfigurationDefinitionID
        FROM dbo.tblConfigurationDefinitions AS Configuration
        INNER JOIN dbo.tblProductConfigurationMapping AS Product ON Product.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID
        INNER JOIN dbo.tblProducts AS Products on Products.ProductID = Product.ProductID 
        WHERE Configuration.ConfigurationDefinitionID = @definitionId
    END
    ELSE IF (@definitionType = 'platform')
    BEGIN
       SELECT Platforms.*,  Configuration.ConfigurationDefinitionID
        FROM dbo.tblConfigurationDefinitions AS Configuration
        INNER JOIN dbo.tblPlatformConfigurationMapping AS Platform ON Platform.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID   
        INNER JOIN dbo.tblPlatforms AS Platforms on Platforms.PlatformID = Platform.PlatformID
        WHERE Configuration.ConfigurationDefinitionID =@definitionId
    END
    ELSE IF(@definitionType = 'global')
    BEGIN
        SELECT Globals.*, Configuration.ConfigurationDefinitionID 
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblGlobalConfigurationMapping AS Global ON Global.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblGlobals AS Globals on Globals.GlobalID = Global.GlobalID 
        WHERE Configuration.ConfigurationDefinitionID = @definitionId
    END
	ELSE IF (@definitionType = 'child platform')
    BEGIN
        SELECT Platforms.*, ot.PartNumberCollectionID, Configuration.ConfigurationDefinitionID 
        FROM dbo.tblConfigurationDefinitions AS Configuration 
        INNER JOIN dbo.tblPlatformConfigurationMapping AS Platform ON Platform.ConfigurationDefinitionID = Configuration.ConfigurationDefinitionID 
        INNER JOIN dbo.tblPlatforms AS Platforms on Platforms.PlatformID = Platform.PlatformID 
		INNER JOIN dbo.tblOutputTypes AS OT ON OT.OutputTypeID = Configuration.OutputTypeID
        WHERE Configuration.ConfigurationDefinitionParentID = @definitionId
    END
END
GO