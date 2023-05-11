
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Aiyappa, Brinda Chindamada
-- Create date: 5/26/2022
-- Description:	Get language and 2 letter code 
-- Sample: EXEC [dbo].[SP_script_GetLang] 'English,French,Spanish,Simp_chinese'
-- =============================================
IF OBJECT_ID('[dbo].[SP_script_GetLang]','P') IS NOT NULL
BEGIN
DROP PROC [dbo].[SP_script_GetLang]
END
GO
CREATE PROCEDURE [dbo].[SP_script_GetLang]
@combindedString NVARCHAR(250)

AS
BEGIN
SELECT Distinct LOWER(dbo.tblLanguages.Name) as LanguageName,[2LetterID_4xxx] as TwoletterID FROM dbo.tblLanguages
WHERE [2LetterID_4xxx] is not null and
LOWER(dbo.tblLanguages.Name) IN(SELECT Item
FROM dbo.SplitString(@combindedString, ','))
END
GO
