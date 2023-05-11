SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Adds new views if needed to custom config menu
-- Sample EXEC [dbo].[SP_AddNewConfigurationView] 'Rotating POI,Flight Info,Panorama,Flight Data,Diagnostics,Global Zoom', 1
-- =============================================

IF OBJECT_ID('[dbo].[SP_AddNewConfigurationView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AddNewConfigurationView]
END
GO

CREATE PROCEDURE [dbo].[SP_AddNewConfigurationView]
@configurationId INT,
@type NVARCHAR(150),
@xml XML = NULL
AS
BEGIN

	DECLARE @menuID INT, @updateKey INT
	IF (@type = 'get')
	BEGIN
		SELECT Perspective FROM cust.config_tblMenu(@configurationId)
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM cust.config_tblMenu(@configurationId))
		BEGIN
			INSERT INTO cust.tblMenu (Perspective) VALUES (@xml)
			
			SET @menuID = (SELECT MAX(MenuId) FROM cust.tblMenu)
			EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId, 'tblMenu', @menuID 
		END
		ELSE
		BEGIN
			SET @menuId = (SELECT cust.tblMenuMap.MenuID FROM cust.tblMenuMap WHERE cust.tblMenuMap.ConfigurationID = @configurationId)
			EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @menuId, @updateKey out
			
			UPDATE cust.tblMenu SET Perspective = @xml WHERE MenuID = @updateKey
		END
	END
END
GO