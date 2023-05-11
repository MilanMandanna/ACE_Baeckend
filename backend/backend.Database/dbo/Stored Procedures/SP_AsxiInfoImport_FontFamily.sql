SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_FontFamily] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_FontFamily]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_FontFamily]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_FontFamily]
		@configid INT
AS
BEGIN
	--For new records
	--DECLARE @tempNewFontFamilyCounter INT, @existingFontFamilyID INT, @newFontFamilyID INT, @CurrentFontFamilyID INT;
	DECLARE @TempId INT,@TempFontFaceID INT, @TempFaceName NVARCHAR(512), @TempFileName NVARCHAR(512),@existingFontFamilyID INT;
	DECLARE @tempNewFontFamily TABLE(ID INT IDENTITY(1,1) NOT NULL,FontFaceID INT NOT NULL, FaceName NVARCHAR(512) NULL,FileName NVARCHAR(512) NULL)
	DECLARE @tempUpdateFontFamily TABLE(ID INT IDENTITY(1,1) NOT NULL,FontFaceID INT NOT NULL, FaceName NVARCHAR(512) NULL,FileName NVARCHAR(512) NULL)

	--For New records
	INSERT INTO @tempNewFontFamily(FontFaceID, FaceName, FileName)
	SELECT TBF.FontFaceId, TBF.FaceName, TBF.FileName FROM AsxiInfotbfontfamily TBF 
	WHERE TBF.FontFaceId NOT IN (SELECT FontFamily.FontFaceId FROM config_tblFontFamily(@configid) AS FontFamily);

	--For Modified records
	INSERT INTO @tempUpdateFontFamily(FontFaceID, FaceName, FileName)
	SELECT TBF.FontFaceId, TBF.FaceName, TBF.FileName FROM AsxiInfotbfontfamily TBF 
	WHERE TBF.FontFaceId IN (SELECT FontFamily.FontFaceId FROM config_tblFontFamily(@configid) AS FontFamily 
				WHERE FontFamily.FaceName != TBF.FaceName OR FontFamily.FileName != TBF.FileName)
	

	--Iterating to the new temp tables and adding it to the tblFontFamilyID and tblFontFamilyMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontFamily) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempNewFontFamily)
		SET @TempFontFaceID= (SELECT TOP 1 FontFaceID FROM @tempNewFontFamily)
		SET @TempFaceName= (SELECT TOP 1 FaceName FROM @tempNewFontFamily)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempNewFontFamily)

		DECLARE @newtbFontFamilyID INT;
		INSERT INTO tblFontFamily(FontFaceID,FaceName,FileName)
		VALUES (@TempFontFaceID,@TempFaceName,@TempFileName) 
		SET @newtbFontFamilyID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontFamily', @newtbFontFamilyID

		DELETE FROM @tempNewFontFamily WHERE ID = @TempId
	END

	--Iterating to the new temp tables and adding it to the tblFontFamilyID and tblFontFamilyMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontFamily) > 0
	BEGIN
		
		SET @TempId = (SELECT TOP 1 ID FROM @tempUpdateFontFamily)
		SET @TempFontFaceID= (SELECT TOP 1 FontFaceID FROM @tempUpdateFontFamily)
		SET @TempFaceName= (SELECT TOP 1 FaceName FROM @tempUpdateFontFamily)
		SET @TempFileName= (SELECT TOP 1 FileName FROM @tempUpdateFontFamily)

		--Update the tblFontFamily Table and and its Maping Table
		SET @existingFontFamilyId = (SELECT TBFM.FontFamilyID FROM dbo.config_tblFontFamily(@configid) AS TBFM 
		WHERE TBFM.FontFaceId = @TempFontFaceID)

		DECLARE @updateFontFamilyKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontFamily', @existingFontFamilyId, @updateFontFamilyKey out
		SET NOCOUNT OFF
		UPDATE tblFontFamily
		SET   FaceName = @TempFaceName, FileName = @TempFileName
		WHERE FontFamilyID = @updateFontFamilyKey

		DELETE FROM @tempUpdateFontFamily WHERE ID = @TempId
	END

	DELETE @tempNewFontFamily
	DELETE @tempUpdateFontFamily
END


