SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Abhishek Narasimha Prasad
-- Create date: 09/14/2022
-- Description:	Get data to build modlist JSON file
-- Sample EXEC [dbo].[SP_UpdateModlistData] '1499,2956,1496,2953'
-- =============================================

IF OBJECT_ID('[dbo].[SP_UpdateModlistData]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_UpdateModlistData]
END
GO

CREATE PROCEDURE [dbo].[SP_UpdateModlistData]
	@configurationId INT,
	@modlistData [Type_ModListJson] READONLY
AS
BEGIN
	DECLARE @modListTable TABLE(ID INT, FileJSON NVARCHAR(MAX), Row INT, Col INT, Resolution INT)
	DECLARE @id INT, @row INT, @col INT, @resolution INT, @fileJSON NVARCHAR(MAX), @maxModListId INT

	INSERT INTO @modListTable SELECT * FROM @modlistData
	
	SET NOCOUNT OFF
	WHILE (SELECT COUNT(*) FROM @modListTable) > 0
	BEGIN
		SET @id = (SELECT TOP 1 ID FROM @modListTable)
		SET @resolution = (SELECT Resolution FROM @modListTable WHERE ID = @id)
		SET @row = (SELECT Row FROM @modListTable WHERE ID = @id)
		SET @col = (SELECT Col FROM @modListTable WHERE ID = @id)
		SET @fileJSON = (SELECT FileJSON FROM @modListTable WHERE ID = @id)

		IF EXISTS (SELECT 1 FROM tblModList M INNER JOIN tblModListMap MM ON M.ModlistID = MM.ModlistID WHERE M.Row = @row AND M.Col = @col AND M.Resolution = @resolution AND MM.ConfigurationID = @configurationId)
		BEGIN
			UPDATE M 
			SET FileJSON = @fileJSON, M.isDirty = 0 
			FROM tblModList M INNER JOIN tblModListMap MM ON M.MODLISTiD = MM.MODLISTID
			WHERE M.Row = @ROW AND M.Col = @COL AND M.Resolution = @resolution AND MM.ConfigurationID = @configurationId
		END
		ELSE
		BEGIN
			INSERT INTO tblModList(FileJSON, Row, Col, Resolution, isDirty) VALUES (@fileJSON, @row, @col, @resolution, 0)
			SET @maxModListId = (SELECT MAX(ModlistID) FROM tblModList)
            EXEC SP_ConfigManagement_HandleAdd @configurationId, 'tblModList',@maxModListId
		END

		DELETE FROM @modListTable WHERE ID = @id
	END
END
GO