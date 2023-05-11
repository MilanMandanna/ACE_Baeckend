DROP PROC IF EXISTS sp_infoSpelling_insertupdateInfoSpelling
GO
CREATE PROC sp_infoSpelling_insertupdateInfoSpelling 
@configurationId INT,
@infoId INT,
@languageId INT,
@spelling NVARCHAR(MAX)
AS
BEGIN
BEGIN TRY
DECLARE @updateKey int,@infoSepllingId INT

SELECT @infoSepllingId=InfoSpellingId FROM config_tblInfoSpelling(@configurationId) WHERE InfoId=@infoId and LanguageId=@languageId

IF @infoSepllingId > 0
BEGIN
	EXEC dbo.SP_ConfigManagement_HandleUpdate @configurationId, 'tblinfospelling',@infoSepllingId,@updateKey out

	UPDATE tblInfoSpelling SET Spelling=@spelling WHERE InfoSpellingId=@updateKey
END
ELSE
BEGIN
	SELECT @infoSepllingId=MAX(InfoSpellingId)+1 FROM tblInfoSpelling;
	IF @infoId =0
		SELECT @infoId=MAX(InfoId)+1 FROM tblInfoSpelling;
	SET IDENTITY_INSERT tblInfoSpelling ON
	INSERT INTO tblInfoSpelling(InfoSpellingId,InfoId,LanguageId,Spelling)
	VALUES(@infoSepllingId,@infoId,@languageId,@spelling);
	SET IDENTITY_INSERT tblInfoSpelling OFF
	EXEC dbo.SP_ConfigManagement_HandleAdd @configurationId,'tblInfoSpelling',@infoSepllingId;
END
select @infoId as Infoid
END TRY
BEGIN CATCH
          SELECT  ERROR_LINE() AS ErrorLine  
          ,ERROR_MESSAGE() AS ErrorMessage;  
END CATCH
END
GO

