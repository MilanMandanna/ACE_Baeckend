SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_Language] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_Language]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_Language]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_Language]
		@configid INT
AS
BEGIN
	--For new records
	DECLARE @tempNewLanguageCounter INT, @existingLanguageId INT, @newLanguageId INT, @CurrentLanguageID INT;

	SELECT TempAsxi.* INTO  #tempNewLanguage FROM AsxiInfotblanguage as TempAsxi WHERE TempAsxi.LanguageId NOT IN
			(SELECT T.LanguageID FROM tblLanguages T INNER JOIN tblLanguagesMap TMap ON T.ID = TMap.LanguageID
				WHERE TMap.ConfigurationID = @configid);
	
	--For Modified records
	SELECT TempAsxi.* INTO  #tempUpdateLanguage FROM AsxiInfotblanguage as TempAsxi WHERE TempAsxi.LanguageId IN
			(SELECT T.LanguageID FROM tblLanguages T INNER JOIN tblLanguagesMap TMap ON T.ID = TMap.LanguageID
				WHERE (TempAsxi.Name != T.Name OR
							TempAsxi.TwoLetterID != T.[2LetterID_ASXi] OR
							TempAsxi.ThreeLetterID != T.[3LetterID_ASXi] OR
							TempAsxi.HorizontalOrder != T.HorizontalOrder OR
							TempAsxi.HorizontalScroll != T.HorizontalScroll OR
							TempAsxi.VerticalOrder != T.VerticalOrder OR
							TempAsxi.VerticalScroll != T.VerticalScroll) AND TMap.ConfigurationID = @configid);

	--Iterating to the new temp tables and adding it to the tblLanguage and tblLanguageMap
	WHILE(SELECT COUNT(*) FROM #tempNewLanguage) > 0
	BEGIN
		
		SET @CurrentLanguageID = (SELECT TOP 1 LanguageId FROM #tempNewLanguage)

		INSERT INTO tblLanguages(LanguageID,Name,[2LetterID_ASXi],[3LetterID_ASXi],HorizontalOrder,HorizontalScroll,VerticalOrder,VerticalScroll)
		SELECT @CurrentLanguageID,TN.Name,TN.TwoLetterID,TN.ThreeLetterID,TN.HorizontalOrder,TN.HorizontalScroll,TN.VerticalOrder,TN.VerticalScroll 
		FROM #tempNewLanguage TN WHERE TN.LanguageId = @CurrentLanguageID

		SET @newLanguageId = (SELECT COALESCE((SELECT Max(ID) FROM tblLanguages), 0 ) )

		INSERT INTO tblLanguagesMap(ConfigurationID,LanguageID,PreviousLanguageID,IsDeleted)
		VALUES (@configid,@newLanguageId,0, 0)

		DELETE FROM #tempNewLanguage WHERE LanguageId = @CurrentLanguageID
	END

	--Iterating to the new temp tables and adding it to the tblLanguage and tblLanguageMap
	WHILE(SELECT COUNT(*) FROM #tempUpdateLanguage) > 0
	BEGIN
		
		SET @CurrentLanguageID = (SELECT TOP 1 LanguageId FROM #tempUpdateLanguage)
		SET @existingLanguageId = (SELECT MAX(ID) FROM tblLanguages WHERE LanguageID = @CurrentLanguageID)

		INSERT INTO tblLanguages(LanguageID,Name,[2LetterID_ASXi],[3LetterID_ASXi],HorizontalOrder,HorizontalScroll,VerticalOrder,VerticalScroll)
		SELECT @CurrentLanguageID,TN.Name,TN.TwoLetterID,TN.ThreeLetterID,TN.HorizontalOrder,TN.HorizontalScroll,TN.VerticalOrder,TN.VerticalScroll 
		FROM #tempUpdateLanguage TN WHERE TN.LanguageId = @CurrentLanguageID

		SET @newLanguageId = (SELECT COALESCE((SELECT Max(ID) FROM tblLanguages), 0 ) )
		
		UPDATE tblLanguagesMap
		SET LanguageID = @newLanguageId,PreviousLanguageID = @existingLanguageId WHERE LanguageID = @existingLanguageId

		DELETE FROM #tempUpdateLanguage WHERE LanguageId = @CurrentLanguageID
	END

	DROP TABLE #tempNewLanguage
	DROP TABLE #tempUpdateLanguage
END


