SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_FontMarker] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_FontMarker]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_FontMarker]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_FontMarker]
		@configid INT
AS
BEGIN
	--For new records
	--DECLARE @tempNewFontMarkerCounter INT, @existingFontMarkerID INT, @newFontMarkerID INT, @CurrentFontMarkerID INT;
	DECLARE @TempId INT,@TempMarkerID INT, @TempFileName NVARCHAR(512),@existingFontMarkerID INT;
	DECLARE @tempNewFontMarker TABLE(ID INT IDENTITY(1,1) NOT NULL,MarkerID INT NOT NULL,FileName NVARCHAR(512) NULL)
	DECLARE @tempUpdateFontMarker TABLE(ID INT IDENTITY(1,1) NOT NULL,MarkerID INT NOT NULL,FileName NVARCHAR(512) NULL)

	--For New records
	INSERT INTO @tempNewFontMarker(MarkerID, FileName)
	SELECT TBF.MarkerID,TBF.FileName FROM AsxiInfotbfontMarker TBF 
	WHERE TBF.MarkerID NOT IN (SELECT FontMarker.MarkerID FROM config_tblFontMarker(@configid) AS FontMarker);

	--For Modified records
	INSERT INTO @tempUpdateFontMarker(MarkerID,FileName)
	SELECT TBF.MarkerID,TBF.FileName FROM AsxiInfotbfontMarker TBF 
	WHERE TBF.MarkerID IN (SELECT FontMarker.MarkerID FROM config_tblFontMarker(@configid) AS FontMarker 
				WHERE  FontMarker.FileName != TBF.FileName)
	

	--Iterating to the new temp tables and adding it to the tblFontMarkerID and tblFontMarkerMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontMarker) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempNewFontMarker)
		SET @TempMarkerID= (SELECT TOP 1 MarkerID FROM @tempNewFontMarker)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempNewFontMarker)

		DECLARE @newtbFontMarkerID INT;
		INSERT INTO tblFontMarker(MarkerID,FileName)
		VALUES (@TempMarkerID,@TempFileName) 
		SET @newtbFontMarkerID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontMarker', @newtbFontMarkerID

		DELETE FROM @tempNewFontMarker WHERE ID = @TempId
	END

	--Iterating to the new temp tables and adding it to the tblFontMarkerID and tblFontMarkerMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontMarker) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempUpdateFontMarker)
		SET @TempMarkerID= (SELECT TOP 1 MarkerID FROM @tempUpdateFontMarker)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempUpdateFontMarker)

		--Update the tblFontMarker Table and and its Maping Table
		SET @existingFontMarkerId = (SELECT TBFM.FontMarkerID FROM dbo.config_tblFontMarker(@configid) AS TBFM 
		WHERE TBFM.MarkerID = @TempMarkerID)

		DECLARE @updateFontMarkerKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontMarker', @existingFontMarkerId, @updateFontMarkerKey out
		SET NOCOUNT OFF
		UPDATE tblFontMarker
		SET FileName = @TempFileName
		WHERE FontMarkerID = @updateFontMarkerKey

		DELETE FROM @tempUpdateFontMarker WHERE ID = @TempId
	END

	DELETE @tempNewFontMarker
	DELETE @tempUpdateFontMarker
END


