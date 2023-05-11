SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lakshmikanth G R
-- Create date: 06/24/2022
-- Description:	Import Fonts from Asxiinfo.sqlite
-- Sample EXEC [dbo].[SP_AsxiInfoImport_Country] 1
-- =============================================
IF OBJECT_ID('[dbo].[SP_AsxiInfoImport_Country]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_AsxiInfoImport_Country]
END
GO

CREATE PROCEDURE [dbo].[SP_AsxiInfoImport_Country]
		@configid INT
AS
BEGIN
	--For new records  
	DECLARE @CurrentCountryID INT, @existingCountryId INT, @newCountryId INT, @tempCountryId INT, @tempLangID INT,@tempCountry NVARCHAR(MAX);  
	
	DECLARE @tempNewCountryWithIDs TABLE (Id INT IDENTITY (1,1) NOT NULL,CountryId INT NOT NULL, Description NVARCHAR(MAX) NOT NULL, LangTwoLetter NVARCHAR(2) NULL,LangID INT NULL); 
	DECLARE @tempNewCountry TABLE (Id INT IDENTITY (1,1) NOT NULL,CountryId INT NOT NULL, Description NVARCHAR(MAX) NOT NULL,LangID INT NULL);  
	DECLARE @tempUpdateCountry TABLE (Id INT IDENTITY (1,1) NOT NULL,CountryId INT NOT NULL, Description NVARCHAR(MAX) NOT NULL,LangID INT NULL); 
	DECLARE @dml AS NVARCHAR(MAX);  
	DECLARE @ColumnName AS NVARCHAR(MAX);  
		
	SELECT @ColumnName= ISNULL(@ColumnName + ',','')   
		+ QUOTENAME(name) from sys.columns c  
	where c.object_id = OBJECT_ID('dbo.AsxiInfotbCountry') and name LIKE '%Lang%'  
	SET @dml =   
	N'(SELECT CountryId, Description, (SELECT RIGHT( LangTwoLetter, 2 ))  
	FROM     
	(SELECT CountryId, ' +@ColumnName +'     
	
	FROM AsxiInfotbCountry) p    
	UNPIVOT    
	(Description FOR LangTwoLetter IN     
	(' + @ColumnName + ')     
	)AS unpvtAsxiInfotbCountry) '  
		
	INSERT INTO @tempNewCountryWithIDs(CountryId,Description,LangTwoLetter)  EXEC sp_executesql @dml  
	--Updating two letter codes
	UPDATE T1   
	SET T1.LangID = T2.LanguageID  
	FROM @tempNewCountryWithIDs AS T1 INNER JOIN AsxiInfotblanguage T2  
	ON T1.LangTwoLetter = t2.TwoLetterID  
	
	--For New Records
	INSERT INTO @tempNewCountry(CountryId,LangID,Description)
	SELECT TBCS.CountryId,TBCS.LangID, TBCS.Description FROM @tempNewCountryWithIDs TBCS
	WHERE CAST(TBCS.Description as nvarchar)+CAST(TBCS.LangID as nvarchar) NOT IN (SELECT CAST(FCS.CountryName as nvarchar)+CAST(FCS.LanguageId as nvarchar)
	FROM dbo.config_tblCountrySpelling(@configid) FCS)
	
	--For update Records
	INSERT INTO @tempUpdateCountry(CountryId,LangID,Description)
	SELECT TBCS.CountryId,TBCS.LangID, TBCS.Description FROM @tempNewCountryWithIDs TBCS
		WHERE CAST(TBCS.Description as nvarchar)+CAST(TBCS.LangID as nvarchar) 
			IN (SELECT CAST(FCS.CountryName as nvarchar)+CAST(FCS.LanguageId as nvarchar)
					FROM dbo.config_tblCountrySpelling(@configid) as FCS WHERE CAST(TBCS.Description as nvarchar)!= CAST(FCS.CountryName as nvarchar));
	
	

		--Iterating to the new temp tables and adding it to the tblCountrySpelling and tblCountrySpellingMap
		WHILE(SELECT COUNT(*) FROM @tempNewCountry) > 0
	BEGIN		
		SET @CurrentCountryID = (SELECT TOP 1 CountryId FROM @tempNewCountry)
		SET @tempCountryId = (SELECT TOP 1 CountryId FROM @tempNewCountry)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempNewCountry)
		SET @tempCountry = (SELECT TOP 1 Description FROM @tempNewCountry)

		--Insert tblFont Table and and its Maping Table
		DECLARE @newtbCountryID INT;
		INSERT INTO tblCountrySpelling(CountryId,LanguageID,CountryName)
		VALUES (@tempCountryId,@tempLangID,@tempCountry) 
		SET @newtbCountryID = SCOPE_IDENTITY();
		EXEC SP_ConfigManagement_HandleAdd @configid, 'tblCountrySpelling', @newtbCountryID

		DELETE FROM @tempNewCountry WHERE CountryId = @CurrentCountryID
	END

	--Iterating to the udate temp tables and adding it to the tblCountrySpelling and tblCountrySpellingMap
	WHILE(SELECT COUNT(*) FROM @tempUpdateCountry) > 0
	BEGIN		
		SET @CurrentCountryID = (SELECT TOP 1 CountryId FROM @tempUpdateCountry)
		SET @tempCountryId = (SELECT TOP 1 CountryId FROM @tempUpdateCountry)
		SET @tempLangID = (SELECT TOP 1 LangID FROM @tempUpdateCountry)
		SET @tempCountry = (SELECT TOP 1 Description FROM @tempUpdateCountry)

		--Update the tblFont Table and and its Maping Table
		SET @existingCountryId = (SELECT tbCountrySpell.CountryID FROM config_tblCountrySpelling(@configid) as tbCountrySpell
		WHERE tbCountrySpell.LanguageId = @tempLangID AND tbCountrySpell.CountryId = @tempCountryId)

		DECLARE @updateSpellKey INT
		exec dbo.SP_ConfigManagement_HandleUpdate @configid, 'tblCountrySpelling', @existingCountryId, @updateSpellKey out
		SET NOCOUNT OFF
		UPDATE tblCountrySpelling
		SET CountryName = @tempCountry
		WHERE CountryID = @updateSpellKey

		DELETE FROM @tempUpdateCountry WHERE CountryId = @CurrentCountryID
	END

END  