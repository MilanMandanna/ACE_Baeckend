
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aiyappa, Brinda Chindamada
-- Create date: 5/24/2022
-- Description:	Get language based on language code and configurationID
-- Sample: [dbo].[SP_global_AddLanguagesCode] 'SP',112
-- =============================================
IF OBJECT_ID('[dbo].[SP_global_AddLanguagesCode]','P') IS NOT NULL

BEGIN
        DROP PROC [dbo].[SP_global_AddLanguagesCode]
END
GO

CREATE PROCEDURE [dbo].[SP_global_AddLanguagesCode]
        @languageCode NVARCHAR(100),
		@configurationId Int
       
AS

BEGIN
  
 IF NOT EXISTS(SELECT 1 FROM  dbo.tblLanguages INNER JOIN dbo.tblLanguagesMap ON dbo.tblLanguagesMap.LanguageID = dbo.tblLanguages.ID  WHERE dbo.tblLanguages.[2LetterID_ASXi] = @languageCode 
 AND dbo.tblLanguagesMap.ConfigurationID = @configurationId )
 BEGIN
       DECLARE @LanguageID INT
       SET @LanguageID =(SELECT ID   from dbo.tblLanguages  WHERE dbo.tblLanguages.[2LetterID_ASXi] = @languageCode)
	   INSERT INTO dbo.tblLanguagesMap(ConfigurationID,LanguageID,Action)values(@configurationId,@LanguageID,'adding')
	   SELECT  LOWER(dbo.tblLanguages.Name) as languages FROM dbo.tblLanguages 
       INNER JOIN dbo.tblLanguagesMap ON dbo.tblLanguagesMap.LanguageID = dbo.tblLanguages.ID 
       WHERE dbo.tblLanguages.[2LetterID_ASXi] = @languageCode AND dbo.tblLanguagesMap.ConfigurationID = @configurationId
 END
 ELSE
 BEGIN
                SELECT  LOWER(dbo.tblLanguages.Name) as languages FROM dbo.tblLanguages 
                INNER JOIN dbo.tblLanguagesMap ON dbo.tblLanguagesMap.LanguageID = dbo.tblLanguages.ID 
                WHERE dbo.tblLanguages.[2LetterID_ASXi] = @languageCode AND dbo.tblLanguagesMap.ConfigurationID = @configurationId
				END
END
GO

