SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_InfoSpelling] 9
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_InfoSpelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_InfoSpelling]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_InfoSpelling]
		@configid INT
AS
BEGIN
 --For new records  
 DECLARE @CurrentInfoSpellingID INT, @existingInfoSpellingId INT, @newInfoSpellingId INT, @tempInfoId INT, @tempLangID INT,@tempInfoSpelling NVARCHAR(MAX);  
 DECLARE @dml AS NVARCHAR(MAX);
 DECLARE @ColumnName AS NVARCHAR(MAX);  
 DECLARE @tempNewInfoSpellingWithIDs TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL, LangTwoLetter NVARCHAR(2) NULL,LangID INT NULL, InfoItem NVARCHAR(MAX)); 
 DECLARE @tempNewInfoSpelling TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL,LangID INT NULL, InfoItem NVARCHAR(MAX));  
 DECLARE @tempUpdateInfoSpelling TABLE (InfoSpellingId INT IDENTITY (1,1) NOT NULL, InfoId INT NULL,LangID INT NULL, InfoItem NVARCHAR(MAX)); 
  
 SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(name) from sys.columns c
	where c.object_id = OBJECT_ID('dbo.AsxiInfotbinfospelling') and name LIKE '%Lang%'
  
	SET @dml = 
			N'(SELECT InfoId,(SELECT RIGHT( LangTwoLetter, 2 )), InfoItem  
	FROM   
	(SELECT InfoId, ' +@ColumnName +'
	
	FROM AsxiInfotbinfospelling) p  
	UNPIVOT  
	(InfoItem FOR LangTwoLetter IN   
		(' + @ColumnName + ')  
	)AS unpvtAsxiInfotbinfospelling)'	

	
	INSERT INTO @tempNewInfoSpellingWithIDs(InfoId,LangTwoLetter,InfoItem) EXEC sp_executesql @dml  
  
  --Updating two letter codes
 UPDATE T1   
 SET T1.LangID = T2.LanguageID  
 FROM @tempNewInfoSpellingWithIDs AS T1 INNER JOIN AsxiInfotblanguage T2  
 ON T1.LangTwoLetter = t2.TwoLetterID  

 --For New Records
 INSERT INTO @tempNewInfoSpelling(InfoId,LangID,InfoItem)
 SELECT TBIS.InfoId,TBIS.LangID, TBIS.InfoItem FROM @tempNewInfoSpellingWithIDs TBIS
 WHERE CAST(TBIS.InfoId as varchar)+'_'+CAST(TBIS.LangID as varchar) NOT IN (SELECT CAST(TBLIS.InfoId as varchar)+'_'+CAST(TBLIS.LanguageId as varchar)
 FROM config_tblInfoSpelling(@configid) TBLIS)

  --For update Records
 INSERT INTO @tempUpdateInfoSpelling(InfoId,LangID,InfoItem)
 SELECT TBIS.InfoId,TBIS.LangID, TBIS.InfoItem FROM @tempNewInfoSpellingWithIDs TBIS
	WHERE CAST(TBIS.InfoId as varchar)+'_'+CAST(TBIS.LangID as varchar) 
		IN (SELECT CAST(TBLIS.InfoId as varchar)+'_'+CAST(TBLIS.LanguageId as varchar)
				FROM config_tblInfoSpelling(@configid) as TBLIS WHERE TBIS.InfoItem != TBLIS.Spelling)

 	--Iterating to the new temp tables and adding it to the tblInfoSpelling and tblInfoSpellingMap
	WHILE(SELECT COUNT(*) FROM @tempNewInfoSpelling) > 0
	BEGIN		
		SET @CurrentInfoSpellingID = (SELECT TOP 1 InfoSpellingId FROM @tempNewInfoSpelling)
		SET @tempInfoId = (SELECT TOP 1 InfoId FROM @tempNewInfoSpelling)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempNewInfoSpelling)
		SET @tempInfoSpelling = (SELECT TOP 1 InfoItem FROM @tempNewInfoSpelling)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbInfoSpellingID INT;
		INSERT INTO tblInfoSpelling(InfoId,LanguageID,Spelling)
		VALUES (@tempInfoId,@tempLangID,@tempInfoSpelling) 
		SET @newtbInfoSpellingID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblInfoSpelling', @newtbInfoSpellingID

		DELETE FROM @tempNewInfoSpelling WHERE InfoSpellingId = @CurrentInfoSpellingID
	END

	--Iterating to the udate temp tables and adding it to the tblInfoSpelling and tblInfoSpellingMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateInfoSpelling) > 0
	BEGIN		
		SET @CurrentInfoSpellingID = (SELECT TOP 1 InfoSpellingId FROM @tempUpdateInfoSpelling)
		SET @tempInfoId = (SELECT TOP 1 InfoId FROM @tempUpdateInfoSpelling)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempUpdateInfoSpelling)
		SET @tempInfoSpelling = (SELECT TOP 1 InfoItem FROM @tempUpdateInfoSpelling)

		--Update the tblFont Table and and its Maping Table
		SET @existingInfoSpellingId = (SELECT tbInfoSpell.InfoSpellingID FROM config_tblInfoSpelling(@configid) as tbInfoSpell
		WHERE tbInfoSpell.LanguageId = @tempLangID AND tbInfoSpell.InfoId = @tempInfoId)

		DECLARE @updateInfoSpellKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblInfoSpelling', @existingInfoSpellingId, @updateInfoSpellKey out
		SET NOCOUNT OFF
		UPDATE tblInfoSpelling
		SET Spelling = @tempInfoSpelling
		WHERE InfoSpellingID = @updateInfoSpellKey

		DELETE FROM @tempUpdateInfoSpelling WHERE InfoSpellingId = @CurrentInfoSpellingID
	END
 DELETE @tempNewInfoSpelling 
 DELETE @tempUpdateInfoSpelling
END