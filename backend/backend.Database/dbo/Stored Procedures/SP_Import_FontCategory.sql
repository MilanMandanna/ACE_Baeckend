SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Abhishek
-- Create date: 06/24/2022
-- Description:	Import Fonts from csv file
-- Sample EXEC [dbo].[SP_Import_FontCategory] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_Import_FontCategory]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Import_FontCategory]
END
GO

CREATE PROCEDURE [dbo].[SP_Import_FontCategory]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @existingFontCategoryId INT, @CurrentFontCategoryID INT;
	DECLARE @tbFontCatLangID INT,@tbFontCatMarkerID INT, @tbFontCatIMarkerID INT,@tbFontCatGeoRefIdCatTypeId INT,@tbFontCatFontID INT;
	--DECLARE  @tempNewFontCategoryWithIDs TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);
	DECLARE  @tempNewFontCategory TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);
	DECLARE  @tempUpdateFontCategory TABLE (FontCategoryId INT IDENTITY (1,1) NOT NULL, GeoRefIdCatTypeID INT NULL, LanguageID INT NULL,FontID INT NULL,MarkerID INT NULL,IMarkerID INT NULL);


	--For new records
	INSERT INTO  @tempNewFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID) 
	SELECT TBFC.GeoRefIdCatTypeId,TBFC.LanguageId,TBFC.FontId, TBFC.MarkerId, TBFC.IMarkerId
	FROM tblTempFontsCategory TBFC WHERE CAST(TBFC.GeoRefIdCatTypeId AS NVARCHAR)+CAST(TBFC.FontId AS NVARCHAR)  NOT IN 
		(SELECT CAST(tbFontCat.GeoRefIdCatTypeID AS NVARCHAR)+CAST(tbFontCat.FontID AS NVARCHAR) FROM config_tblFontCategory(@configid) as tbFontCat)
	
	--For Modified records
	INSERT INTO  @tempUpdateFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID) 
	SELECT TBFC.GeoRefIdCatTypeId,TBFC.LanguageId,TBFC.FontId, TBFC.MarkerId, TBFC.IMarkerId
	FROM tblTempFontsCategory TBFC WHERE CAST(TBFC.GeoRefIdCatTypeId AS NVARCHAR)+CAST(TBFC.FontId AS NVARCHAR) IN 
		(SELECT CAST(tbFontCat.GeoRefIdCatTypeID AS NVARCHAR)+CAST(tbFontCat.FontID AS NVARCHAR) FROM config_tblFontCategory(@configid) as tbFontCat 
			WHERE TBFC.LanguageID != tbFontCat.LanguageID OR
							TBFC.MarkerID != tbFontCat.MarkerID OR
							TBFC.IMarkerID != tbFontCat.IMarkerID);

	--Iterating to the new temp tables and adding it to the tblFontCategory and tblFontCategoryMap
	WHILE(SELECT COUNT(*) FROM @tempNewFontCategory) > 0
	BEGIN		
		SET @CurrentFontCategoryID = (SELECT TOP 1 FontCategoryId FROM @tempNewFontCategory)
		SET @tbFontCatGeoRefIdCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM @tempNewFontCategory)
		SET @tbFontCatLangID = (SELECT TOP 1 LanguageID FROM @tempNewFontCategory)
		SET @tbFontCatFontID = (SELECT TOP 1 FontID FROM @tempNewFontCategory)
		SET @tbFontCatMarkerID = (SELECT TOP 1 MarkerID FROM @tempNewFontCategory)
		SET @tbFontCatIMarkerID = (SELECT TOP 1 IMarkerID FROM @tempNewFontCategory)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbFontCatID INT;
		INSERT INTO tblFontCategory(GeoRefIdCatTypeID,LanguageID,FontID,MarkerID,IMarkerID)
		VALUES (@tbFontCatGeoRefIdCatTypeId,@tbFontCatLangID, @tbFontCatFontID,@tbFontCatMarkerID,@tbFontCatIMarkerID) 
		SET @newtbFontCatID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFontCategory', @newtbFontCatID

		DELETE FROM @tempNewFontCategory WHERE FontCategoryId = @CurrentFontCategoryID
	END

	--Iterating to the new temp tables and adding it to the tblFontCategory and tblFontCategoryMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFontCategory) > 0
	BEGIN		
		SET @CurrentFontCategoryID = (SELECT TOP 1 FontCategoryId FROM @tempUpdateFontCategory)
		SET @tbFontCatGeoRefIdCatTypeId = (SELECT TOP 1 GeoRefIdCatTypeId FROM @tempUpdateFontCategory)
		SET @tbFontCatLangID = (SELECT TOP 1 LanguageID FROM @tempUpdateFontCategory)
		SET @tbFontCatFontID = (SELECT TOP 1 FontID FROM @tempUpdateFontCategory)
		SET @tbFontCatMarkerID = (SELECT TOP 1 MarkerID FROM @tempUpdateFontCategory)
		SET @tbFontCatIMarkerID = (SELECT TOP 1 IMarkerID FROM @tempUpdateFontCategory)

		--Update the tblFont Table and and its Maping Table
		SET @existingFontCategoryId = (SELECT tbFontCat.FontCategoryID FROM config_tblFontCategory(@configid) as tbFontCat
		WHERE tbFontCat.FontID = @tbFontCatFontID AND tbFontCat.GeoRefIdCatTypeID = @tbFontCatGeoRefIdCatTypeId)

		DECLARE @updateFontCatKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFontCategory', @existingFontCategoryId, @updateFontCatKey out
		SET NOCOUNT OFF
		UPDATE tblFontCategory
		SET LanguageID = @tbFontCatLangID, MarkerID = @tbFontCatMarkerID, IMarkerID = @tbFontCatIMarkerID
		WHERE FontCategoryID = @updateFontCatKey

		DELETE FROM @tempUpdateFontCategory WHERE FontCategoryId = @CurrentFontCategoryID
	END

	DELETE @tempNewFontCategory
	DELETE @tempUpdateFontCategory
END



