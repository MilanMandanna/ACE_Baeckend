SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Gets all views for configuration ID
-- Sample EXEC [dbo].[SP_Views_GetAllViewDetails] 223, 'all'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_GetAllViewDetails]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_GetAllViewDetails]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_GetAllViewDetails]
@configurationId INT,
@type NVARCHAR(100)
AS
BEGIN

	DECLARE @tblViewsMenu TABLE (name NVARCHAR(100), preset NVARCHAR(50))
	DECLARE @viewsMenu NVARCHAR(500),@featureset NVARCHAR(500)
	--todo get featureset id from configurationdefnitiontable based on configurationID
	SET @featureset = (SELECT DISTINCT dbo.tblFeatureSet.FeatureSetID 
					   FROM dbo.tblFeatureSet INNER JOIN dbo.tblConfigurationDefinitions ON dbo.tblFeatureSet.FeatureSetID = dbo.tblConfigurationDefinitions.FeatureSetID 
					   INNER JOIN dbo.tblConfigurations ON dbo.tblConfigurations.ConfigurationDefinitionID = dbo.tblConfigurationDefinitions.ConfigurationDefinitionID
						AND dbo.tblConfigurations.ConfigurationID = @configurationId )
	
	SET @viewsMenu = (SELECT Value FROM tblFeatureSet WHERE Name = 'CustomConfig-ViewsDisplayList' AND FeatureSetID = @featureset)
	 


	IF (@type = 'all')
	BEGIN
		INSERT INTO @tblViewsMenu
			SELECT ISNULL(Nodes.item.value('(./@name)[1]', 'varchar(max)'), '') AS name,
			ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), '') AS preset
			FROM cust.config_tblMenu(@configurationId) as M
			CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
			WHERE Nodes.item.value('(./@enable)[1]', 'varchar(max)') = 'true'
	END
	ELSE IF (@type = 'disabled')
	BEGIN
		INSERT INTO @tblViewsMenu
			SELECT ISNULL(Nodes.item.value('(./@name)[1]', 'varchar(max)'), '') AS name,
			ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), '') AS preset
			FROM cust.config_tblMenu(@configurationId) as M
			CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
			WHERE Nodes.item.value('(./@enable)[1]', 'varchar(max)') = 'false'


		INSERT INTO @tblViewsMenu
			SELECT value, 'false' FROM STRING_SPLIT(@viewsMenu, ',') AS names WHERE value NOT IN
			(SELECT ISNULL(Nodes.item.value('(./@name)[1]', 'varchar(max)'), '') AS name
			FROM cust.config_tblMenu(@configurationId) as M
			CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item))
	END

	SELECT name,preset FROM @tblViewsMenu
END
GO