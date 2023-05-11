SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/27/2022
-- Description:	Get Maps layers details
-- Sample EXEC [dbo].[SP_Maps_GetLayers] 112, 'all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Maps_GetLayers]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Maps_GetLayers]
END
GO

CREATE PROCEDURE [dbo].[SP_Maps_GetLayers]
	@configurationId INT,
	@type NVARCHAR(250)
AS
BEGIN
	 DECLARE @featuresetID INT
	   SET @featuresetID =( SELECT DISTINCT dbo.tblFeatureSet.FeatureSetID 
         FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
         INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
         AND dbo.tblConfigurations.ConfigurationID = @configurationId)

	IF (@type = 'layers')
	BEGIN 
		SELECT
        Nodes.LayerItem.value('(./@name)[1]','varchar(max)') as Name, 
        isnull(Nodes.LayerItem.value('(./@active)[1]','varchar(max)'),'false') as Active, 
        isnull(Nodes.LayerItem.value('(./@enable)[1]','varchar(max)'),'false') as Enabled
        FROM
        cust.tblMenu as Menu
        cross apply Menu.Layers.nodes('/category/item') as Nodes(LayerItem)
        INNER JOIN cust.tblMenuMap ON cust.tblMenuMap.MenuID = Menu.MenuID
        WHERE cust.tblMenuMap.ConfigurationID = @configurationId
	END
    ELSE IF (@type = 'all')
    BEGIN
        SELECT
        NameTable.Name as Name,
        DisplayNameTable.DisplayName as DisplayName
        FROM
        (SELECT 
        dbo.tblFeatureSet.Value as Name
        FROM 
        dbo.tblFeatureSet
        WHERE dbo.tblFeatureSet.Name = 'CustomConfig-Maps-LayersList'AND dbo.tblFeatureSet.FeatureSetID = @featuresetID) as NameTable,
        (SELECT 
        dbo.tblFeatureSet.Value as DisplayName
        FROM 
        dbo.tblFeatureSet
        WHERE dbo.tblFeatureSet.Name = 'CustomConfig-Maps-LayersDisplayList'AND dbo.tblFeatureSet.FeatureSetID = @featuresetID) as DisplayNameTable
    END
END
GO
