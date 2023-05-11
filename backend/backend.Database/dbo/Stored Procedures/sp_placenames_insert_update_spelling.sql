-- =============================================
-- Author:		Sathya
-- Create date: 31-May-2022
-- Description:	inserts or updates spelling for the given config and spelling id (if place name added all spelling will be same)
-- =============================================

GO

IF OBJECT_ID('[dbo].[sp_placenames_insert_update_spelling]', 'P') IS NOT NULL
BEGIN
	DROP PROC [dbo].[sp_placenames_insert_update_spelling]
END
GO
CREATE PROC sp_placenames_insert_update_spelling
@configurationId INT,
@geoRefId INT,
@placeName NVARCHAR(MAX)=NULL,
@spellingId INT

AS
BEGIN
IF @spellingId IS NULL OR @spellingId=0

BEGIN

DECLARE @max_spellingId INT=0;--DECLARE @spellingId INT=0

SELECT @max_spellingId=MAX(SpellingID) FROM tblSpelling(nolock);
SET @spellingId=@max_spellingId+1;

DROP TABLE IF EXISTS #temp_georef;
CREATE TABLE #temp_georef(SpellingID INT,GeoRefID INT,LanguageID INT,UnicodeStr NVARCHAR(MAX));

INSERT INTO #temp_georef(SpellingID,GeoRefID,LanguageID,UnicodeStr) 
SELECT @max_spellingId + ROW_NUMBER() OVER (ORDER BY languageId) ID,@geoRefId,languageId,@placeName FROM config_tblLanguage(@configurationId)


DECLARE @cur_spelId INT,@cur_langId INT
--SET IDENTITY_INSERT [dbo].[tblSpelling] ON
DECLARE cur_tbl CURSOR  FOR SELECT SpellingID,languageId FROM #temp_georef
OPEN cur_tbl

            FETCH next FROM cur_tbl INTO @cur_spelId,@cur_langId

            WHILE @@FETCH_STATUS = 0
              BEGIN

			  --INSERT INTO DATA TABLE
				 DECLARE @ident_spellingID INT
			     INSERT INTO tblSpelling(GeoRefID,LanguageID,UnicodeStr) 
				 VALUES(@geoRefId,@cur_langId,@placeName);
				 SELECT @ident_spellingID=SCOPE_IDENTITY();

			 --INSERT INTO MAPPING TABLE
				 EXEC [dbo].[SP_ConfigManagement_HandleAdd] @configurationId,'tblSpelling',@ident_spellingID;
			     FETCH next FROM cur_tbl INTO @cur_spelId,@cur_langId
			  END
			 CLOSE cur_tbl
			 --SET IDENTITY_INSERT [dbo].[tblSpelling] OFF
END
ELSE
BEGIN
		declare @updateKey int
		exec dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblSpelling', @spellingId, @updateKey out

		UPDATE tblSpelling SET UnicodeStr=@placeName WHERE SpellingID=@updateKey;

END

END

GO
