SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Updates selected view enable status
-- Sample EXEC EXEC [dbo].[SP_Views_UpdateSelectedView] 18, 'Landscape', 'true'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_UpdateSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_UpdateSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_UpdateSelectedView]
@configurationId INT,
@viewName NVARCHAR(500),
@updateValue NVARCHAR(200)
AS
BEGIN
	DECLARE @count INT, @xmlData INT
	declare @mappedMenuId int	
	declare @updateKey int

	SET @count = (SELECT CONVERT (INT, CONVERT(VARCHAR(MAX),FS.Value)) FROM tblFeatureSet FS 
        INNER JOIN dbo.tblConfigurationDefinitions CD ON FS.FeatureSetID = CD.FeatureSetID
        INNER JOIN dbo.tblConfigurations C ON C.ConfigurationDefinitionID = CD.ConfigurationDefinitionID
        WHERE FS.Name = 'CustomConfig-ViewsMaxPresets' AND C.ConfigurationID = @configurationId)

    SELECT @xmlData = COUNT(ISNULL(Nodes.item.value('(./@quick_select)[1]', 'varchar(max)'), ''))
		FROM cust.config_tblMenu(@configurationId) as M
        CROSS APPLY M.Perspective.nodes('//item') AS Nodes(item)
        WHERE Nodes.item.value('(./@quick_select)[1]', 'varchar(max)') = 'true'
	IF (@updateValue = 'true')
	BEGIN
		IF (@count > @xmlData)
		BEGIN
			 set @mappedMenuId = (select MenuID from cust.tblMenuMap where configurationId = @configurationId)
			if not @mappedMenuId is null
			begin
				
				exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @mappedMenuId, @updateKey out

				UPDATE M 
				SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")') 
				FROM cust.config_tblMenu(@configurationId) as M
				WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true' and M.MenuID = @updateKey
			end
			SELECT 1 AS returnValue
		END
		ELSE
		BEGIN
			SELECT 2 AS returnValue
		END
	END
	ELSE
	BEGIN
	
		 set @mappedMenuId  = (select MenuID from cust.tblMenuMap where configurationId = @configurationId)
		if not @mappedMenuId is null
		begin
			exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @mappedMenuId, @updateKey out

			UPDATE M 
			SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")') 
			FROM cust.config_tblMenu(@configurationId) as M
			WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true' and M.MenuID = @updateKey
		end
		SELECT 1 AS returnValue
	END
END
GO