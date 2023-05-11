SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Updates enable status to false for that view
-- Sample EXEC [dbo].[SP_Views_UpdateSelectedView] 18, 'Landscape', 'false'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_DisableSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_DisableSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_DisableSelectedView]
@configurationId INT,
@viewName NVARCHAR(500),
@updateValue NVARCHAR(200)
AS
BEGIN
	declare @mappedMenuId int	
	declare @updateKey int

	 set @mappedMenuId = (select MenuID from cust.tblMenuMap where configurationId = @configurationId)
	if not @mappedMenuId is null
	begin

		exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @mappedMenuId, @updateKey out

		UPDATE M
		SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@enable)[1] with sql:variable("@updateValue")')
		FROM cust.config_tblMenu(@configurationId) as M
		WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true' and M.MenuID = @updateKey

		UPDATE M
		SET Perspective.modify('replace value of (/category/item[@label = sql:variable("@viewName")]/@quick_select)[1] with sql:variable("@updateValue")')
		FROM cust.config_tblMenu(@configurationId) as M
		WHERE Perspective.exist('/category/item[@label = sql:variable("@viewName")]') = 'true' and M.MenuID = @updateKey
	end	
END
GO