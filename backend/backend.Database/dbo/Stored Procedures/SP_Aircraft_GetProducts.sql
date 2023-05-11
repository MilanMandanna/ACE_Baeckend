SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 05/18/2022
-- Description:	returns list of products associated with aircrafts 
-- Sample EXEC [dbo].[SP_Aircraft_GetProducts] '4a2ee015-9da3-4583-aa1f-31a11006a53b'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Aircraft_GetProducts]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Aircraft_GetProducts]
END
GO

CREATE PROCEDURE [dbo].[SP_Aircraft_GetProducts]
    @aircraftId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT DISTINCT 
	CASE WHEN dbo.tblProducts.ProductID is not null THEN dbo.tblProducts.ProductID 
		WHEN dbo.tblPlatforms.PlatformID is not null THEN dbo.tblPlatforms.PlatformID 
		WHEN dbo.tblGlobals.GlobalID is not null THEN dbo.tblGlobals.GlobalID 
		END AS ProductID, 

		CASE WHEN dbo.tblProducts.ProductID is not null THEN dbo.tblProducts.Name 
		WHEN dbo.tblPlatforms.PlatformID is not null THEN dbo.tblPlatforms.Name 
	WHEN dbo.tblGlobals.GlobalID is not null THEN dbo.tblGlobals.Name 
	END AS Name, 

	CASE WHEN dbo.tblProducts.ProductID is not null THEN dbo.tblProducts.Description 
	WHEN dbo.tblPlatforms.PlatformID is not null THEN dbo.tblPlatforms.Description 
	WHEN dbo.tblGlobals.GlobalID is not null THEN dbo.tblGlobals.Description 
	END AS Description, 

	CASE WHEN dbo.tblProducts.ProductID is not null THEN dbo.tblProducts.LastModifiedBy 

	END AS LastModifiedBy,
	dbo.tblConfigurationDefinitions.ConfigurationDefinitionID AS ConfigurationDefinitionID,

	dbo.tblProducts.TopLevelPartnumber AS TopLevelPartnumber

	FROM dbo.tblAircraftConfigurationMapping 

	INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblAircraftConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID 

	LEFT OUTER JOIN dbo.tblProductConfigurationMapping on dbo.tblProductConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionParentID 
	LEFT OUTER JOIN dbo.tblProducts on dbo.tblProducts.ProductID = dbo.tblProductConfigurationMapping.ProductID 

	LEFT OUTER JOIN tblPlatformConfigurationMapping on tblPlatformConfigurationMapping.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionParentID 
	LEFT OUTER JOIN dbo.tblPlatforms on dbo.tblPlatforms.PlatformID = dbo.tblPlatformConfigurationMapping.PlatformID 

		LEFT OUTER JOIN tblGlobalConfigurationMapping on tblGlobalConfigurationMapping.ConfigurationDefinitionID = tblconfigurationdefinitions.ConfigurationDefinitionID 
	LEFT OUTER JOIN dbo.tblGlobals on tblGlobals.GlobalID = tblGlobalConfigurationMapping.GlobalID 

	LEFT OUTER JOIN dbo.tblConfigurationDefinitions as CD ON CD.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionParentID 

	WHERE dbo.tblAircraftConfigurationMapping.AircraftID = @aircraftId;
END
GO