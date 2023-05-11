SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajna Hegde
-- Create date: 2/03/2022
-- Description:	Get Features details from FeatureSet table
-- Sample EXEC [dbo].[SP_Feature_GetFeatures] , 'all'
-- Sample EXEC [dbo].[SP_Feature_GetFeatures] , 'featureName'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Feature_GetFeatures]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Feature_GetFeatures]
END
GO

CREATE PROCEDURE [dbo].[SP_Feature_GetFeatures]
	@configurationId INT,
	@featureName NVARCHAR(250)
AS
BEGIN
	IF (@featureName = 'all')
	BEGIN 
		SELECT dbo.tblFeatureSet.Name, 
         dbo.tblFeatureSet.Value
        FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
         AND dbo.tblConfigurations.ConfigurationID = @configurationId 
	END
    ELSE IF (@featureName != 'all')
    BEGIN
       SELECT dbo.tblFeatureSet.Name, 
         dbo.tblFeatureSet.Value
        FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
        INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
        AND dbo.tblConfigurations.ConfigurationID = @configurationId
        WHERE dbo.tblFeatureSet.Name = @featureName
    END
END
GO
