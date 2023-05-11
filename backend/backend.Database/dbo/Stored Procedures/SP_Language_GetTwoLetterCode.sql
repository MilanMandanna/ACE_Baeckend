
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Lakshmikanth G R
-- Create date: 5/26/2022
-- Description:	Get language and 2 letter code 
-- Sample: EXEC [dbo].[SP_Language_GetTwoLetterCode] 'English,French,Spanish,Simp_chinese'
-- =============================================
IF OBJECT_ID('[dbo].[SP_Language_GetTwoLetterCode]','P') IS NOT NULL
BEGIN
DROP PROC [dbo].[SP_Language_GetTwoLetterCode]
END
GO
CREATE PROCEDURE [dbo].[SP_Language_GetTwoLetterCode]
@combindedString NVARCHAR(500)

AS
BEGIN
SELECT Distinct dbo.tblLanguages.Name as LanguageName,[2LetterID_ASXi] as TwoletterID FROM dbo.tblLanguages
WHERE [2LetterID_ASXi] is not null and
LOWER(dbo.tblLanguages.Name) IN(SELECT Item
FROM dbo.SplitString(@combindedString, ','))
END
GO
