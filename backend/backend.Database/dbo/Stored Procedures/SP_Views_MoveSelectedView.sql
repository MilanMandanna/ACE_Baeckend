SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek Narasimha Prasad
-- Create date: 1/24/2022
-- Description:	Select and Update command to move particular view location
-- Sample EXEC [dbo].[SP_Views_MoveSelectedView] 223, 'update'
-- =============================================

IF OBJECT_ID('[dbo].[SP_Views_MoveSelectedView]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Views_MoveSelectedView]
END
GO

CREATE PROCEDURE [dbo].[SP_Views_MoveSelectedView]
@configurationId INT,
@type NVARCHAR(150),
@xmlValue XML = NULL
AS
BEGIN
	IF (@type = 'get')
		BEGIN
			SELECT M.perspective as xmlData
			FROM cust.config_tblMenu(@configurationId) as M

		END
	ELSE IF (@type = 'update')
		BEGIN
			declare @mappedMenuId int	
			declare @updateKey int
			set @mappedMenuId = (select MenuID from cust.tblMenuMap where configurationId = @configurationId)
			if not @mappedMenuId is null
			begin
				print 'inside'
				exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblMenu', @mappedMenuId, @updateKey out
				--UPDATE M
				--SET perspective = @xmlValue FROM  cust.tblMenu as M WHERE M.MenuID = @updateKey
				update cust.tblMenu set perspective = @xmlValue WHERE MenuID = @updateKey
				SELECT 1 AS returnValue
			end	
		END
END
GO