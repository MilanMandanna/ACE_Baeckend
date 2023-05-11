SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_font] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_font]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_font]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_font]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @tempNewFontCounter INT, @existingFontId INT, @newFontId INT, @CurrentFontID INT, @tbFontID INT, @tempID INT;
	DECLARE @tbFontFontID INT, @tbFontSize INT,@tbFontDescription NVARCHAR(255), @tbFontColor NVARCHAR(8), @tbFontShadowColor NVARCHAR(8), @tbFontFontFaceId INT, @tbFontFontStyle INT;
	--CREATE TABLE @tempNewFontWithIDs (ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId NVARCHAR(11),FontStyle NVARCHAR(10));
	DECLARE @tempNewFont TABLE(ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId INT NULL,FontStyle INT NULL);
	DECLARE @tempUpdateFont TABLE (ID INT IDENTITY (1,1) NOT NULL, FontID INT NULL, Description NVARCHAR(255) NULL,Size INT NULL,Color NVARCHAR(8), ShadowColor NVARCHAR(8),FontFaceId INT NULL,FontStyle INT NULL);
 

	INSERT INTO @tempNewFont (FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle) 
	SELECT TBF.FontId,TBF.Description, TBF.Size,TBF.Color,TBF.ShadowColor,TBF.FontFaceId, TBF.FontStyle
	FROM AsxiInfotbfont  TBF WHERE TBF.FontId NOT IN 
		(SELECT tbFont.FontID FROM config_tblFont(@configid) as tbFont)


	--For Modified records
	INSERT INTO @tempUpdateFont (FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle) 
	SELECT TBF.FontId,TBF.Description, TBF.Size,TBF.Color,TBF.ShadowColor,TBF.FontFaceId, TBF.FontStyle
	FROM AsxiInfotbfont TBF WHERE TBF.FontId IN
			(SELECT tbFont.FontID FROM config_tblFont(@configid) as tbFont
				WHERE TBF.Description != tbFont.Description OR
							TBF.Size != tbFont.Size OR
							TBF.Color != tbFont.Color OR
							TBF.ShadowColor != tbFont.ShadowColor OR
							TBF.FontFaceId != tbFont.FontFaceId OR
							TBF.FontStyle != tbFont.FontStyle);

	--Iterating to the new temp tables and adding it to the tblFont and tblFontMap
	WHILE(SELECT COUNT(*) FROM @tempNewFont) > 0
	BEGIN
		
		SET @tempID = (SELECT TOP 1 ID FROM @tempNewFont)
		SET @tbFontID = (SELECT TOP 1 FontID FROM @tempNewFont)	
		SET @tbFontDescription = (SELECT TOP 1 Description FROM @tempNewFont)	
		SET @tbFontSize = (SELECT TOP 1 Size FROM @tempNewFont)
		SET @tbFontColor = (SELECT TOP 1 Color FROM @tempNewFont)
		SET @tbFontShadowColor = (SELECT TOP 1 ShadowColor FROM @tempNewFont)
		SET @tbFontFontFaceId = (SELECT TOP 1 FontFaceId FROM @tempNewFont)
		SET @tbFontFontStyle = (SELECT TOP 1 FontStyle FROM @tempNewFont)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbFontID INT;
		INSERT INTO tblFont(FontID,Description,Size,Color,ShadowColor,FontFaceId,FontStyle)
		VALUES (@tbFontID,@tbFontDescription, @tbFontSize,@tbFontColor,@tbFontShadowColor,@tbFontFontFaceId,@tbFontFontStyle) 
		SET @newtbFontID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblFont', @newtbFontID

		DELETE FROM @tempNewFont WHERE ID = @tempID
	END

	--Iterating to the new temp tables and adding it to the tblFont and tblFontMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateFont) > 0
	BEGIN
		
		SET @tempID = (SELECT TOP 1 ID FROM @tempUpdateFont)	
		SET @tbFontID = (SELECT TOP 1 FontID FROM @tempUpdateFont)	
		SET @tbFontDescription = (SELECT TOP 1 Description FROM @tempUpdateFont)	
		SET @tbFontSize = (SELECT TOP 1 Size FROM @tempUpdateFont)
		SET @tbFontColor = (SELECT TOP 1 Color FROM @tempUpdateFont)
		SET @tbFontShadowColor = (SELECT TOP 1 ShadowColor FROM @tempUpdateFont)
		SET @tbFontFontFaceId = (SELECT TOP 1 FontFaceId FROM @tempUpdateFont)
		SET @tbFontFontStyle = (SELECT TOP 1 FontStyle FROM @tempUpdateFont)


		--Update the tblFont Table and and its Maping Table
		SET @existingFontId = (SELECT tbFont.ID FROM dbo.config_tblFont(@configid) AS tbFont 
		WHERE tbFont.FontID = @tbFontID)

		print @existingFontId

		DECLARE @updateFontKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblFont', @existingFontId, @updateFontKey out
		SET NOCOUNT OFF
		print @updateFontKey
		UPDATE tblFont
		SET   Size = @tbFontSize, Color = @tbFontColor, ShadowColor = @tbFontShadowColor, FontFaceId = @tbFontFontFaceId, FontStyle = @tbFontFontStyle,Description = @tbFontDescription
		WHERE ID = @updateFontKey

		DELETE FROM @tempUpdateFont WHERE ID = @tempID
	END

	DELETE @tempNewFont
	DELETE @tempUpdateFont
END




